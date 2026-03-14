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

    // Call Gemini Imagen 3
    // Note: Model ID might vary, using a standard stable one
    const url = `https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict?key=${apiKey}`;
    
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        instances: [{ prompt: prompt }],
        parameters: { sampleCount: 1 }
      }),
    });

    const data = await response.json();
    
    if (data.error) {
      throw new Error(data.error.message);
    }

    const base64Image = data.predictions?.[0]?.bytesBase64Encoded;
    if (!base64Image) {
      console.error("Gemini Response:", JSON.stringify(data));
      throw new Error('Fallback: No image data returned from Gemini');
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
