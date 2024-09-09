// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

// Import createClient to interact with Supabase
import { createClient } from "https://esm.sh/@supabase/supabase-js";

// Initialize Supabase Client for Account B (recipe management)
const supabase = createClient(
  Deno.env.get("SUPABASE_URL_ACCOUNT_B"),
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY_ACCOUNT_B")
);

Deno.serve(async (req) => {
  try {
    const { method } = req;

    if (method === "POST") {
      const { user_id, name, description, zutaten, kochanweisungen } = await req.json();

      // Insert a new recipe into Account B's `Rezepte` table
      const { data, error } = await supabase
        .from('rezepte')
        .insert([{ benutzer_id: user_id, name, beschreibung: description, zutaten, kochanweisungen }]);

      if (error) throw error;

      return new Response(JSON.stringify({ data }), {
        headers: { "Content-Type": "application/json" },
        status: 200
      });
    } else if (method === "GET") {
      // Fetch recipes for a specific user
      const url = new URL(req.url);
      const userId = url.searchParams.get('user_id');

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

    return new Response('Method not allowed', { status: 405 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500
    });
  }
});
