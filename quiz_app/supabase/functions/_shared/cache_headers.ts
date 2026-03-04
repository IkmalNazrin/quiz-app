/**
 * Shared utility for Supabase Edge Functions to manage 
 * Cache-Control headers effectively.
 */
export const CACHE_STRATEGIES = {
    // Static content: Cache at edge for 1 hour, browser for 15 mins
    STATIC_ASSETS: {
        'Cache-Control': 'public, s-maxage=3600, max-age=900, stale-while-revalidate=300',
    },
    // Dynamic but heavy: Cache at edge for 1 min
    SHORT_LIVED: {
        'Cache-Control': 'public, s-maxage=60, max-age=10, stale-while-revalidate=30',
    },
    // Private: No edge caching
    PRIVATE: {
        'Cache-Control': 'private, no-cache, no-store, must-revalidate',
    }
};

/**
 * Returns a Response with the appropriate cache headers.
 */
export function withCache(response: Response, strategy: keyof typeof CACHE_STRATEGIES): Response {
    const newResponse = new Response(response.body, response);
    Object.entries(CACHE_STRATEGIES[strategy]).forEach(([k, v]) => {
        newResponse.headers.set(k, v);
    });
    return newResponse;
}
