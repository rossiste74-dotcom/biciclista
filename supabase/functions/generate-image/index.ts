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
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || "";
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || "";

    if (!apiKey) {
      throw new Error('GEMINI_API_KEY not set in Supabase secrets');
    }

    // Initialize Supabase Client for storage
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Use Gemini 2.5 Flash Image (Nano Banana) which supports image generation in free/preview tier
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${apiKey}`;
    
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

    const data = await response.json();
    
    if (data.error) {
      throw new Error(data.error.message);
    }

    // Parse image from multimodal output
    // Looking for content.parts[1].inlineData or similar if it's the second part
    const candidate = data.candidates?.[0];
    const imagePart = candidate?.content?.parts?.find((p: any) => p.inlineData);
    const base64Image = imagePart?.inlineData?.data;

    if (!base64Image) {
      console.error("Gemini Response:", JSON.stringify(data));
      // Fallback: If no image part found, maybe it errored out or returned text only
      const textResponse = candidate?.content?.parts?.[0]?.text;
      throw new Error(`Fallback: Model did not return an image. Response text: ${textResponse ?? 'empty'}`);
    }

    // Convert base64 to Uint8Array
    const binary = atob(base64Image);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }

    // Upload to Supabase Storage
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

    // Get Public URL
    const { data: { publicUrl } } = supabase.storage
      .from('comic_avatars')
      .getPublicUrl(filePath);

    return new Response(
      JSON.stringify({ url: publicUrl }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
