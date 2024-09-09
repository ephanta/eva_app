import "jsr:@supabase/functions-js/edge-runtime.d.ts"
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

    console.log('Request received:', method, url.href);

    // Basic auth check (JWT from Account A)
    const authHeader = req.headers.get('Authorization');
    console.log('Authorization header:', authHeader);

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('Unauthorized request: Missing or invalid auth header');
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { "Content-Type": "application/json" }
      });
    }

    switch (method) {
      case "POST": {
        const body = await req.json();
        console.log('POST request body:', body);

        const { user_id, name, beschreibung, zutaten, kochanweisungen } = body;
        if (!user_id || !name) {
          console.log('POST request missing required fields:', { user_id, name });
          return new Response(JSON.stringify({ error: 'Missing required fields' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }

        const { data, error } = await supabase
          .from('Rezepte') // Account B table
          .insert([{ benutzer_id: user_id, name, beschreibung, zutaten, kochanweisungen }])
          .select();

        if (error) {
          console.error('Error inserting recipe:', error);
          throw error;
        }

        console.log('Recipe inserted successfully:', data);
        return new Response(JSON.stringify({ data }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }

      case "GET": {
        const userId = url.searchParams.get('user_id');
        console.log('GET request user_id:', userId);

        if (!userId) {
          console.log('GET request missing user_id parameter');
          return new Response(JSON.stringify({ error: 'Missing user_id parameter' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }

        const { data, error } = await supabase
          .from('Rezepte') // Account B table
          .select('*')
          .eq('benutzer_id', userId);

        if (error) {
          console.error('Error fetching recipes:', error);
          throw error;
        }

        console.log('Recipes fetched successfully:', data);
        return new Response(JSON.stringify({ data }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }

      case "PUT": {
        const recipeId = url.searchParams.get('id');
        const body = await req.json();
        console.log('PUT request recipeId:', recipeId, 'body:', body);

        if (!recipeId) {
          console.log('PUT request missing id parameter');
          return new Response(JSON.stringify({ error: 'Missing id parameter' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }

        const { name, beschreibung, zutaten, kochanweisungen } = body;
        const { data, error } = await supabase
          .from('Rezepte') // Account B table
          .update({ name, beschreibung, zutaten, kochanweisungen })
          .eq('id', recipeId)
          .select();

        if (error) {
          console.error('Error updating recipe:', error);
          throw error;
        }

        console.log('Recipe updated successfully:', data);
        return new Response(JSON.stringify({ data }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }

      case "DELETE": {
        const recipeId = url.searchParams.get('id');
        console.log('DELETE request recipeId:', recipeId);

        if (!recipeId) {
          console.log('DELETE request missing id parameter');
          return new Response(JSON.stringify({ error: 'Missing id parameter' }), {
            status: 400,
            headers: { "Content-Type": "application/json" }
          });
        }

        const { data, error } = await supabase
          .from('Rezepte') // Account B table
          .delete()
          .eq('id', recipeId);

        if (error) {
          console.error('Error deleting recipe:', error);
          throw error;
        }

        console.log('Recipe deleted successfully:', data);
        return new Response(JSON.stringify({ message: "Recipe deleted successfully" }), {
          headers: { "Content-Type": "application/json" },
          status: 200
        });
      }

      default:
        console.log('Method not allowed:', method);
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
