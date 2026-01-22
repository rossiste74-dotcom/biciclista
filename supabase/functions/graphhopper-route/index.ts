// GraphHopper Routing Proxy Edge Function
// Keeps API key secure on server-side

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const GRAPHHOPPER_API_KEY = Deno.env.get('GRAPHHOPPER_API_KEY')
const GRAPHHOPPER_BASE_URL = 'https://graphhopper.com/api/1/route'

interface RouteRequest {
    start: { lat: number; lon: number }
    end: { lat: number; lon: number }
    vehicle?: string
    elevation?: boolean
    avoid?: string
    weighting?: string
    details?: string
}

serve(async (req) => {
    // CORS headers
    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    }

    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Parse request body
        const body: RouteRequest = await req.json()

        if (!body.start || !body.end) {
            return new Response(
                JSON.stringify({ error: 'Missing start or end coordinates' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Build GraphHopper API URL with bike-optimized parameters
        const params = new URLSearchParams({
            'point': `${body.start.lat},${body.start.lon}`,
            'vehicle': body.vehicle || 'bike',
            'key': GRAPHHOPPER_API_KEY!,
            'points_encoded': 'false',
            'elevation': String(body.elevation !== false),
            'details': body.details || 'road_class',
            'ch.disable': 'true', // Disable Contraction Hierarchies for flexible bike routing
        })

        // Add second point (URLSearchParams allows duplicate keys)
        params.append('point', `${body.end.lat},${body.end.lon}`)

        // Add bike-specific optimizations
        if (body.vehicle === 'mtb') {
            // MTB: prefer unpaved trails and alternative routes
            params.append('algorithm', 'alternative_route')
            params.append('alternative_route.max_paths', '3')
        }

        if (body.avoid) {
            params.append('avoid', body.avoid)
        }
        if (body.weighting) {
            params.append('weighting', body.weighting)
        }

        // Call GraphHopper API
        const graphhopperUrl = `${GRAPHHOPPER_BASE_URL}?${params.toString()}`
        const response = await fetch(graphhopperUrl)
        const data = await response.json()

        if (!response.ok) {
            return new Response(
                JSON.stringify({ error: 'GraphHopper API error', details: data }),
                { status: response.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Return GraphHopper response
        return new Response(
            JSON.stringify(data),
            {
                status: 200,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})
