import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { prompt } = await req.json();
    // Use specialized key for comics if available, otherwise fallback to default
    const apiKey = Deno.env.get('GEMINI_COMIC_API_KEY') || Deno.env.get('GEMINI_API_KEY');
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || "";
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || "";

    if (!apiKey) {
      throw new Error('Neither GEMINI_COMIC_API_KEY nor GEMINI_API_KEY is set in Supabase secrets');
    }

    // Initialize Supabase Client for storage
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // List of free/preview models that support multimodal image generation via generateContent
    // These are ordered by expected availability/quality in free tiers
    const freeImageModels = [
      'gemini-2.0-flash',             // Standard 2.0 (Often has multimodal output enabled)
      'gemini-2.5-flash',             // Standard 2.5
      'gemini-3.1-flash-image-preview', // Nano Banana 2
      'gemini-3-pro-image-preview',     // Nano Banana Pro
      'gemini-2.5-flash-image'        // Nano Banana (falling back to this as it hit quota)
    ];

    let base64Image = null;
    let lastError = null;

    for (const modelId of freeImageModels) {
      try {
        console.log(`Attempting image generation with model: ${modelId}`);
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelId}:generateContent?key=${apiKey}`;
        
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ 
              parts: [{ text: `Generate a comic-style image based on this scenario: ${prompt}` }] 
            }],
            generationConfig: {
              temperature: 1.0,
            }
          }),
        });

        const resText = await response.text();
        if (!response.ok) {
          console.warn(`Model ${modelId} returned error ${response.status}: ${resText}`);
          lastError = `Status ${response.status}: ${resText}`;
          continue;
        }

        let data;
        try {
          data = JSON.parse(resText);
        } catch (e) {
          console.error(`Failed to parse JSON for ${modelId}: ${resText}`);
          lastError = `Malformed JSON: ${resText.substring(0, 100)}`;
          continue;
        }
        
        if (data.error) {
          console.warn(`Model ${modelId} API error: ${data.error.message}`);
          lastError = data.error.message;
          continue; 
        }

        const candidate = data.candidates?.[0];
        const imagePart = candidate?.content?.parts?.find((p: any) => p.inlineData);
        base64Image = imagePart?.inlineData?.data;

        if (base64Image) {
          console.log(`Successfully generated image with model: ${modelId}`);
          break; // Success!
        } else {
          const textResponse = candidate?.content?.parts?.[0]?.text;
          console.warn(`Model ${modelId} returned text instead of image: ${textResponse?.substring(0, 100)}...`);
          lastError = `Model ${modelId} returned text instead of image.`;
        }
      } catch (e: any) {
        console.error(`Error with model ${modelId}:`, e.message);
        lastError = e.message;
      }
    }

    if (!base64Image) {
      console.warn("All Gemini models failed. Falling back to Pollinations.ai (Free/No-Key)...");
      try {
        const pollPrompt = prompt.length > 800 ? prompt.substring(0, 800) + '...' : prompt;
        const pollUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(pollPrompt)}?width=1024&height=1024&seed=${Date.now()}&model=flux`;
        const pollRes = await fetch(pollUrl);
        if (pollRes.ok) {
          const blob = await pollRes.blob();
          const buffer = await blob.arrayBuffer();
          const bytes = new Uint8Array(buffer);
          
          // Jump straight to upload since we have bytes
          return await uploadAndReturn(supabase, bytes, corsHeaders);
        } else {
          throw new Error(`Pollinations fallback failed with status ${pollRes.status}`);
        }
      } catch (pollErr: any) {
        throw new Error(`Failed to generate image after trying all Gemini models and Pollinations fallback. Last Gemini error: ${lastError}. Pollinations error: ${pollErr.message}`);
      }
    }

    // Convert base64 to Uint8Array (for Gemini success case)
    const binary = atob(base64Image);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }

    return await uploadAndReturn(supabase, bytes, corsHeaders);
  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

/**
 * Helper to upload bytes to Supabase Storage and return the public URL
 */
async function uploadAndReturn(supabase: any, bytes: Uint8Array, corsHeaders: any) {
  const fileName = `ai_portrait_${Date.now()}.png`;
  const filePath = `generated/${fileName}`;
  
  const { error: uploadError } = await supabase.storage
    .from('comic_avatars')
    .upload(filePath, bytes.buffer, {
      contentType: 'image/png',
      upsert: true
    });

  if (uploadError) {
    throw new Error(`Upload Error: ${uploadError.message}`);
  }

  const { data: { publicUrl } } = supabase.storage
    .from('comic_avatars')
    .getPublicUrl(filePath);

  return new Response(
    JSON.stringify({ url: publicUrl }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}
