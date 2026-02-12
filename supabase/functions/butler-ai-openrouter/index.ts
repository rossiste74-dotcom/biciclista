import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Google Gemini API Configuration
const GOOGLE_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models";

// Model Priority Chain (User Specified - Optimized for Stability)
const DEFAULT_MODELS = [
    "models/gemini-2.5-flash-lite",          // Primary (High Availability)
    "models/gemini-2.0-flash-001",           // Backup Stability
    "models/gemini-exp-1206",                // Experimental Backup
    "models/deep-research-pro-preview-12-2025", // Deep Research Backup
    "models/gemma-3-27b-it",                 // Open Model Backup
    "models/gemini-2.0-flash-lite-001",      // Final Backup
    "models/gemini-3-flash-preview"          // Demoted due to empty responses (Jan 2026)
];

const SPECIALIST_MODEL = "models/gemini-2.5-pro"; // For complex tasks

interface RequestPayload {
    messages: { role: string; content: string; image?: string; images?: string[] }[];
    action?: string; // Optional action routing (e.g. 'naming' -> lite)
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const payload = await req.json() as RequestPayload;
        const messages = payload.messages;
        const action = payload.action;

        // Init Supabase for logs
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        );

        // Get API Key
        const apiKey = Deno.env.get('GEMINI_API_KEY');
        if (!apiKey) {
            throw new Error("GEMINI_API_KEY not set in Supabase Secrets");
        }

        // --- TRANSFORM: OpenRouter/OpenAI Messages -> Gemini Contents ---
        let systemInstruction: any = undefined;
        const geminiContents: any[] = [];

        for (const msg of messages) {
            if (msg.role === 'system') {
                systemInstruction = {
                    parts: [{ text: msg.content }]
                };
            } else {
                const role = msg.role === 'assistant' ? 'model' : 'user';
                const parts: any[] = [{ text: msg.content }];

                // Handle Multiple Image Input (Base64)
                if ((msg as any).images && Array.isArray((msg as any).images)) {
                    for (const imgBase64 of (msg as any).images) {
                        parts.push({
                            inlineData: {
                                mimeType: "image/jpeg",
                                data: imgBase64
                            }
                        });
                    }
                } else if ((msg as any).image) {
                    // Legacy single image support
                    parts.push({
                        inlineData: {
                            mimeType: "image/jpeg",
                            data: (msg as any).image
                        }
                    });
                }

                geminiContents.push({
                    role: role,
                    parts: parts
                });
            }
        }

        // Determine Model Strategy
        let modelsToTry = [...DEFAULT_MODELS];

        // Simple heuristic for task routing (if client sends action)
        if (action === 'generate_name' || action === 'simple') {
            // prioritize lite
            modelsToTry = [
                "models/gemini-2.5-flash-lite",
                "models/gemini-2.5-flash"
            ];
        } else if (action === 'deep_analysis' || action === 'biomechanics_analysis') {
            // prioritize pro/flash 2.0
            modelsToTry = [
                "models/gemini-2.0-flash-001",
                SPECIALIST_MODEL,
                "models/gemini-2.5-flash"
            ];
        }

        let responseData: any = null;
        let usedModel = "";
        let finalError = null;
        let diffErrors: string[] = [];

        // --- RETRY LOOP ---
        for (const m of modelsToTry) {
            try {
                console.log(`Attempting Gemini Model: ${m}`);
                // Remove 'models/' prefix for URL if duplicative, but user provided explicitly.
                // Google API typically accepts 'gemini-1.5-flash' OR 'models/gemini-1.5-flash'. 
                // However, the URL construction `${GOOGLE_API_BASE}/${m}` if m has `models/` results in
                // `.../v1beta/models/models/gemini...` which is INVALID.
                // We MUST strip the `models/` prefix from `m` before constructing URL.
                const cleanModelId = m.replace('models/', '');

                const url = `${GOOGLE_API_BASE}/${cleanModelId}:generateContent?key=${apiKey}`;

                const res = await fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        contents: geminiContents,
                        system_instruction: systemInstruction,
                        generationConfig: {
                            temperature: 0.7,
                            maxOutputTokens: 2048,
                        }
                    })
                });

                if (res.ok) {
                    const tempJson = await res.json();
                    console.log(`[DEBUG] Model ${m} Raw Response:`, JSON.stringify(tempJson).substring(0, 500) + "..."); // Validated log

                    // Validate Content Deeply
                    const candidate = tempJson.candidates?.[0];
                    const tempText = candidate?.content?.parts?.[0]?.text;
                    const finishReason = candidate?.finishReason;

                    if (tempText) {
                        responseData = tempJson;
                        usedModel = m;
                        console.log(`[DEBUG] Success with: ${m}. Text length: ${tempText.length}`);
                        break;
                    } else {
                        const reason = finishReason || 'Unknown';
                        console.warn(`[DEBUG] Model ${m} returned 200 but no text. Reason: ${reason}`);
                        diffErrors.push(`${m}: No Text (Reason: ${reason})`);
                        // CONTINUE to next model (fallback)
                    }
                } else {
                    const errText = await res.text();
                    console.warn(`[DEBUG] Model ${m} failed ${res.status}: ${errText}`);
                    diffErrors.push(`${m}: ${res.status} - ${errText}`);
                    finalError = `Status ${res.status}: ${errText}`;
                }
            } catch (e: any) {
                console.error(`Error calling ${m}:`, e);
                diffErrors.push(`${m}: ${e.message}`);
                finalError = e.message;
            }
        }

        if (!responseData) {
            throw new Error(`All Gemini models failed. Details: ${diffErrors.join(', ')}`);
        }

        // --- MAP RESPONSE ---
        const text = responseData.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!text) throw new Error("Empty response from Gemini");

        const usage = responseData.usageMetadata || { promptTokenCount: 0, candidatesTokenCount: 0 };

        // Async Log
        const authHeader = req.headers.get('Authorization');
        if (authHeader) {
            const token = authHeader.replace('Bearer ', '');
            const { data: { user } } = await supabaseClient.auth.getUser(token);
            if (user) {
                await supabaseClient.from('ai_logs').insert({
                    user_id: user.id,
                    request_type: action || 'direct_gemini_chat',
                    provider: 'google',
                    model: usedModel,
                    input_tokens: usage.promptTokenCount,
                    output_tokens: usage.candidatesTokenCount,
                    status: 'success'
                });
            }
        }

        return new Response(JSON.stringify({
            choices: [{
                message: { role: 'assistant', content: text }
            }],
            usage: {
                prompt_tokens: usage.promptTokenCount,
                completion_tokens: usage.candidatesTokenCount,
                total_tokens: (usage.promptTokenCount || 0) + (usage.candidatesTokenCount || 0)
            }
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });

    } catch (e: any) {
        console.error("Global Error:", e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
    }
});
