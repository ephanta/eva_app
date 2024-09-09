// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
// Import createClient to interact with Supabase
import { createClient } from "https://esm.sh/@supabase/supabase-js";

// Initialize Supabase Client for Account B (recipe management)
const supabase = createClient(
  Deno.env.get("SUPABASE_URL_ACCOUNT_B") || "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY_ACCOUNT_B") || ""
);

Deno.serve(async (req) => {
  try {
    const { method } = req;
    const url = new URL(req.url);

    // Basic auth check (you might want to implement a more robust auth check)
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { "Content-Type": "application/json" }
      });
    }

    switch (method) {
      case "POST": {
        const { user_id, name, beschreibung, zutaten, kochanweisungen } = await req.json();
        if (!user_id || !name) {
          return new Response(JSON.stringify({ error: 'Missing required fields' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }
        const { data, error } = await supabase
          .from('rezepte')
          .insert([{ benutzer_id: user_id, name, beschreibung, zutaten, kochanweisungen }])
          .select();
        if (error) throw error;
        return new Response(JSON.stringify({ data }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }
      case "GET": {
        const userId = url.searchParams.get('user_id');
        if (!userId) {
          return new Response(JSON.stringify({ error: 'Missing user_id parameter' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }
        const { data, error } = await supabase
          .from('rezepte')
          .select('*')
          .eq('benutzer_id', userId);
        if (error) throw error;
        return new Response(JSON.stringify({ data }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }
      case "PUT": {
        const recipeId = url.searchParams.get('id');
        if (!recipeId) {
          return new Response(JSON.stringify({ error: 'Missing id parameter' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }
        const { name, beschreibung, zutaten, kochanweisungen } = await req.json();
        const { data, error } = await supabase
          .from('rezepte')
          .update({ name, beschreibung, zutaten, kochanweisungen })
          .eq('id', recipeId)
          .select();
        if (error) throw error;
        return new Response(JSON.stringify({ data }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }
      case "DELETE": {
        const recipeId = url.searchParams.get('id');
        if (!recipeId) {
          return new Response(JSON.stringify({ error: 'Missing id parameter' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }
        const { data, error } = await supabase
          .from('rezepte')
          .delete()
          .eq('id', recipeId);
        if (error) throw error;
        return new Response(JSON.stringify({ message: "Recipe deleted successfully" }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }
      default:
        return new Response('Method not allowed', { status: 405 });
    }
  } catch (error) {
    console.error('Error in edge function:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500
    });
  }
});