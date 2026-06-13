// @ts-ignore
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

// @ts-ignore - Deno es global en el runtime de Supabase Edge Functions
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
// @ts-ignore
const SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY")!;

const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

interface LoginRequest {
  username: string;
  password: string;
}

interface LoginResponse {
  success: boolean;
  user?: {
    id: string;
    auth_id: string | null;
    username: string;
    nombre: string;
    apellidos?: string | null;
    telefono?: string | null;
    email?: string | null;
    empresa_id?: string | null;
    rol_id?: string | null;
    activo: boolean;
    created_at: string;
  };
  error?: string;
}

serve(async (req: Request) => {
  if (req.method !== "POST") {
    const resp: LoginResponse = { success: false, error: "Method not allowed" };
    return new Response(JSON.stringify(resp), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const { username, password }: LoginRequest = await req.json();

    if (!username || !password) {
      const resp: LoginResponse = { success: false, error: "Usuario y contraseña requeridos" };
      return new Response(JSON.stringify(resp), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // 1. Validar login usando PostgreSQL crypt (bcrypt nativo)
    const { data: rpcData, error: rpcError } = await supabaseAdmin.rpc(
      "validar_login_bcrypt",
      {
        p_username: username,
        p_password: password,
      }
    );

    if (rpcError) {
      console.error("RPC validar_login_bcrypt error:", rpcError);
      const resp: LoginResponse = { success: false, error: "Usuario o contraseña incorrectos" };
      return new Response(JSON.stringify(resp), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = rpcData as { success: boolean; user?: LoginResponse["user"]; error?: string };

    if (!result || result.success !== true) {
      const errorMsg = result?.error || "Usuario o contraseña incorrectos";
      const resp: LoginResponse = { success: false, error: errorMsg };
      return new Response(JSON.stringify(resp), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const userData = result.user;
    if (!userData) {
      const resp: LoginResponse = { success: false, error: "Datos de usuario incompletos" };
      return new Response(JSON.stringify(resp), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // 2. Responder con datos del usuario (login validado, no usamos auth.users)
    const resp: LoginResponse = {
      success: true,
      user: userData,
    };

    return new Response(JSON.stringify(resp), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("login-custom error:", error);
    const resp: LoginResponse = {
      success: false,
      error: error instanceof Error ? error.message : "Error interno",
    };
    return new Response(JSON.stringify(resp), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
