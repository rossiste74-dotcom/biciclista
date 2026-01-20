import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface RequestPayload {
    action: string;
    payload: any;
    model_provider?: 'deepseek' | 'openai' | 'gemini';
}

interface AIResponse {
    content: string;
    tokens: { input: number; output: number };
    model: string;
    provider: string;
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        );

        // Get Request Data
        const { action, payload, model_provider = 'deepseek' } = await req.json() as RequestPayload;

        // Validate User (Optional: if we want to log user_id correctly)
        const authHeader = req.headers.get('Authorization');
        let userId: string | null = null;
        if (authHeader) {
            const token = authHeader.replace('Bearer ', '');
            const { data: { user } } = await supabaseClient.auth.getUser(token);
            userId = user?.id ?? null;
        }

        // Routing Logic with Fallback
        let result: AIResponse | null = null;
        let usedProvider = model_provider;
        let error: any = null;

        try {
            console.log(`Attempting to call ${usedProvider}...`);
            if (usedProvider === 'deepseek') {
                result = await callDeepSeek(payload);
            } else if (usedProvider === 'openai') {
                result = await callOpenAI(payload);
            } else if (usedProvider === 'gemini') {
                result = await callGemini(payload);
            }
        } catch (e) {
            console.error(`${usedProvider} failed:`, e);
            error = e;

            // FALLBACK LOGIC
            // If DeepSeek fails, try OpenAI (gpt-3.5-turbo or gpt-4o-mini)
            if (usedProvider === 'deepseek') {
                console.log('Falling back to OpenAI...');
                try {
                    usedProvider = 'openai';
                    result = await callOpenAI(payload, 'gpt-3.5-turbo'); // Backup model
                } catch (e2) {
                    console.error('Fallback OpenAI also failed:', e2);
                    throw e2; // Both failed
                }
            } else {
                throw e; // No fallback defined for others yet
            }
        }

        if (!result) throw new Error('No result from AI provider');

        // Logging (Async)
        // We don't await this to keep response fast, but Edge Functions might kill bg tasks?
        // standard practice is EdgeRuntime.waitUntil logic if supported, or just await it if fast.
        // Deno runtime usually waits for promises? No, we should await to be safe or use EdgeRuntime.waitUntil
        const logData = {
            user_id: userId,
            request_type: action,
            provider: result.provider,
            model: result.model,
            input_tokens: result.tokens.input,
            output_tokens: result.tokens.output,
            // Simple cost estimation (very rough placeholders)
            cost: calculateCost(result.provider, result.model, result.tokens.input, result.tokens.output),
            status: error ? 'fallback' : 'success', // If we fell back, status is fallback? Or success?
            // actually if we handled error and returned result, status is success but maybe note fallback in provider?
            // Let's say 'success' if we returned something.
        };

        // Insert log
        await supabaseClient.from('ai_logs').insert(logData);

        return new Response(JSON.stringify(result), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });

    } catch (error: any) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }
});

// --- Provider Implementations ---

async function callDeepSeek(payload: any): Promise<AIResponse> {
    const apiKey = Deno.env.get('DEEPSEEK_API_KEY');
    if (!apiKey) throw new Error('DEEPSEEK_API_KEY not set');

    // Map payload to prompt (simplified for demo)
    const messages = payload.messages || [{ role: 'user', content: JSON.stringify(payload) }];

    const res = await fetch('https://api.deepseek.com/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({
            model: 'deepseek-chat',
            messages: messages,
            stream: false
        })
    });

    if (!res.ok) throw new Error(`DeepSeek Error: ${res.status} ${await res.text()}`);

    const data = await res.json();
    return {
        content: data.choices[0].message.content,
        tokens: {
            input: data.usage.prompt_tokens,
            output: data.usage.completion_tokens
        },
        model: 'deepseek-chat',
        provider: 'deepseek'
    };
}

async function callOpenAI(payload: any, modelOverride?: string): Promise<AIResponse> {
    const apiKey = Deno.env.get('OPENAI_API_KEY');
    if (!apiKey) throw new Error('OPENAI_API_KEY not set');

    const messages = payload.messages || [{ role: 'user', content: JSON.stringify(payload) }];
    const model = modelOverride || 'gpt-4o';

    const res = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({
            model: model,
            messages: messages,
        })
    });

    if (!res.ok) throw new Error(`OpenAI Error: ${res.status} ${await res.text()}`);

    const data = await res.json();
    return {
        content: data.choices[0].message.content,
        tokens: {
            input: data.usage.prompt_tokens,
            output: data.usage.completion_tokens
        },
        model: model,
        provider: 'openai'
    };
}

async function callGemini(payload: any): Promise<AIResponse> {
    // Placeholder - Gemini API structure is different
    // skipping full implementation for brevity unless requested
    throw new Error("Gemini implementation pending");
}

function calculateCost(provider: string, model: string, input: number, output: number): number {
    // Placeholder rates (per 1k tokens)
    let inputRate = 0;
    let outputRate = 0;

    if (provider === 'deepseek') {
        inputRate = 0.0001; // Example
        outputRate = 0.0002;
    } else if (provider === 'openai') {
        if (model.includes('gpt-4')) {
            inputRate = 0.01;
            outputRate = 0.03;
        } else {
            inputRate = 0.001;
            outputRate = 0.002;
        }
    }

    return (input * inputRate + output * outputRate) / 1000;
}
