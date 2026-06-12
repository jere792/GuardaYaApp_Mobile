-- ============================================
-- GUARDAYA - MIGRACIÓN DE SEGURIDAD COMPLETA
-- ============================================
-- Ejecutar en el SQL Editor de Supabase (Dashboard > SQL Editor)
-- IMPORTANTE: Hacer backup de la base de datos antes de ejecutar.
-- Este script hace 3 cosas:
-- 1. Hashea las contraseñas existentes con bcrypt
-- 2. Migra usuarios a auth.users (JWT nativo de Supabase)
-- 3. Configura triggers y políticas RLS
-- ============================================

-- ============================================
-- 1. HABILITAR EXTENSIÓN PGCrypto (para bcrypt)
-- ============================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- 2. AGREGAR auth_id a la tabla usuarios
-- ============================================
-- Esto enlaza cada usuario con auth.users de Supabase
ALTER TABLE public.usuarios
ADD COLUMN IF NOT EXISTS auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Crear índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_usuarios_auth_id ON public.usuarios(auth_id);

-- ============================================
-- 3. MIGRAR USUARIOS EXISTENTES A auth.users
-- ============================================
-- Este bloque migra TODOS los usuarios existentes a auth.users
-- SOLO ejecutar UNA VEZ. Si ya migraste, saltar este bloque.

DO $$
DECLARE
    usuario_record RECORD;
    v_auth_id UUID;
    v_instance_id UUID;
BEGIN
    -- Obtener instance_id (el ID de tu proyecto Supabase)
    SELECT id INTO v_instance_id FROM auth.instances LIMIT 1;
    
    -- Si no hay instance_id, usar uno genérico
    IF v_instance_id IS NULL THEN
        v_instance_id := '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;

    FOR usuario_record IN 
        SELECT * FROM public.usuarios WHERE auth_id IS NULL
    LOOP
        -- Generar UUID para auth.users
        v_auth_id := gen_random_uuid();
        
        -- Insertar en auth.users (la tabla de autenticación nativa de Supabase)
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_user_meta_data,
            created_at,
            updated_at,
            role,
            confirmation_token,
            recovery_token
        ) VALUES (
            v_auth_id,
            v_instance_id,
            COALESCE(usuario_record.email, usuario_record.username || '@guardaya.local'),
            -- Hashear la contraseña actual con bcrypt
            -- IMPORTANTE: password_hash en tu schema tiene texto plano guardado
            crypt(COALESCE(usuario_record.password_hash, 'changeme123'), gen_salt('bf')),
            NOW(), -- email_confirmed_at (confirmar automáticamente)
            jsonb_build_object(
                'username', usuario_record.username,
                'nombre', usuario_record.nombre,
                'empresa_id', usuario_record.empresa_id,
                'rol_id', usuario_record.rol_id,
                'old_id', usuario_record.id
            ),
            usuario_record.created_at,
            NOW(),
            'authenticated', -- role
            '', -- confirmation_token
            ''  -- recovery_token
        );
        
        -- Actualizar auth_id en public.usuarios
        UPDATE public.usuarios 
        SET auth_id = v_auth_id 
        WHERE id = usuario_record.id;
        
        RAISE NOTICE 'Usuario % migrado a auth.users con ID %', usuario_record.username, v_auth_id;
    END LOOP;
END $$;

-- ============================================
-- 4. LIMPIAR CONTRASEÑAS EN TEXTO PLANO
-- ============================================
-- DESPUÉS de migrar, borramos la columna password_hash (ya no se usa en texto plano
-- porque las contraseñas ahora viven en auth.users hasheadas con bcrypt)
-- ALTER TABLE public.usuarios DROP COLUMN IF EXISTS password_hash;
-- 
-- NOTA: Descomentar la línea de arriba SOLO si ya verificaste que todos los usuarios
-- pueden loguearse con su contraseña actual. Si hay dudas, dejarla comentada.

-- ============================================
-- 5. TRIGGER: Sincronizar auth.users con public.usuarios
-- ============================================
-- Cuando se crea un usuario en auth.users (vía supabase.auth.signUp),
-- automáticamente se crea en public.usuarios

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si ya existe en usuarios (evitar duplicados)
    IF NOT EXISTS (SELECT 1 FROM public.usuarios WHERE auth_id = NEW.id) THEN
        INSERT INTO public.usuarios (
            auth_id,
            username,
            nombre,
            email,
            empresa_id,
            rol_id,
            activo,
            created_at
        ) VALUES (
            NEW.id,
            COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
            COALESCE(NEW.raw_user_meta_data->>'nombre', split_part(NEW.email, '@', 1)),
            NEW.email,
            (NEW.raw_user_meta_data->>'empresa_id')::UUID,
            (NEW.raw_user_meta_data->>'rol_id')::UUID,
            true,
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Activar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 6. FUNCIÓN RPC: Obtener usuario completo después del login
-- ============================================
-- Esta función se llama DESPUÉS de hacer supabase.auth.signInWithPassword()
-- Devuelve los datos de la empresa, colores y rol

CREATE OR REPLACE FUNCTION public.get_usuario_completo()
RETURNS JSONB AS $$
DECLARE
    v_auth_id UUID;
    resultado JSONB;
BEGIN
    -- auth.uid() devuelve el UUID del usuario autenticado (del JWT)
    v_auth_id := auth.uid();
    
    IF v_auth_id IS NULL THEN
        RETURN jsonb_build_object('error', 'No autenticado');
    END IF;
    
    SELECT jsonb_build_object(
        'id', u.id,
        'auth_id', u.auth_id,
        'username', u.username,
        'nombre', u.nombre,
        'email', u.email,
        'empresa_id', u.empresa_id,
        'rol_id', r.nombre,
        'activo', u.activo,
        'created_at', u.created_at,
        'empresa', jsonb_build_object(
            'id', e.id,
            'nombre', e.nombre,
            'color_primario', e.color_primario,
            'color_secundario', e.color_secundario,
            'color_acento', e.color_acento
        )
    ) INTO resultado
    FROM public.usuarios u
    LEFT JOIN public.roles r ON u.rol_id = r.id
    LEFT JOIN public.empresas e ON u.empresa_id = e.id
    WHERE u.auth_id = v_auth_id AND u.activo = true;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7. FUNCIÓN RPC: Crear usuario nuevo (Admin/SuperAdmin)
-- ============================================
-- Ahora crea el usuario en auth.users y el trigger lo replica en public.usuarios

CREATE OR REPLACE FUNCTION public.crear_usuario_seguro(
    p_username TEXT,
    p_password TEXT,
    p_nombre TEXT,
    p_email TEXT DEFAULT NULL,
    p_empresa_id UUID,
    p_rol_nombre TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_rol_id UUID;
    v_auth_id UUID;
    v_instance_id UUID;
BEGIN
    -- Obtener rol_id
    SELECT id INTO v_rol_id FROM public.roles WHERE nombre = p_rol_nombre;
    
    IF v_rol_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Rol no encontrado: ' || p_rol_nombre);
    END IF;
    
    -- Obtener instance_id
    SELECT id INTO v_instance_id FROM auth.instances LIMIT 1;
    IF v_instance_id IS NULL THEN
        v_instance_id := '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;
    
    -- Generar UUID
    v_auth_id := gen_random_uuid();
    
    -- Crear en auth.users
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_user_meta_data,
        created_at,
        updated_at,
        role,
        confirmation_token,
        recovery_token
    ) VALUES (
        v_auth_id,
        v_instance_id,
        COALESCE(p_email, p_username || '@guardaya.local'),
        crypt(p_password, gen_salt('bf')),
        NOW(),
        jsonb_build_object(
            'username', p_username,
            'nombre', p_nombre,
            'empresa_id', p_empresa_id,
            'rol_id', v_rol_id
        ),
        NOW(),
        NOW(),
        'authenticated',
        '',
        ''
    );
    
    -- Actualizar public.usuarios con empresa_id y rol_id correctos
    -- (el trigger ya lo creó, pero sin empresa_id/rol_id si no estaban en metadata)
    UPDATE public.usuarios 
    SET empresa_id = p_empresa_id,
        rol_id = v_rol_id
    WHERE auth_id = v_auth_id;
    
    RETURN jsonb_build_object('success', true, 'auth_id', v_auth_id);
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 8. POLÍTICAS RLS (Row Level Security)
-- ============================================
-- Activar RLS en tablas críticas
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;

-- Política: usuarios solo ven su propia empresa
CREATE POLICY IF NOT EXISTS "usuarios_empresa_policy" ON public.usuarios
    FOR ALL
    USING (
        empresa_id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::UUID
        OR (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID = (SELECT id FROM public.roles WHERE nombre = 'super_admin')
    );

-- Política: ventas solo de la empresa
CREATE POLICY IF NOT EXISTS "ventas_empresa_policy" ON public.ventas
    FOR ALL
    USING (
        empresa_id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::UUID
        OR (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID = (SELECT id FROM public.roles WHERE nombre = 'super_admin')
    );

-- Política: empresas
CREATE POLICY IF NOT EXISTS "empresas_policy" ON public.empresas
    FOR ALL
    USING (
        id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::UUID
        OR (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID = (SELECT id FROM public.roles WHERE nombre = 'super_admin')
    );

-- Política: clientes
CREATE POLICY IF NOT EXISTS "clientes_empresa_policy" ON public.clientes
    FOR ALL
    USING (
        empresa_id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::UUID
        OR (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID = (SELECT id FROM public.roles WHERE nombre = 'super_admin')
    );

-- Política: productos
CREATE POLICY IF NOT EXISTS "productos_empresa_policy" ON public.productos
    FOR ALL
    USING (
        empresa_id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::UUID
        OR (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID = (SELECT id FROM public.roles WHERE nombre = 'super_admin')
    );

-- ============================================
-- 9. FUNCIÓN: Verificar usuario activo (para checkAuth)
-- ============================================
CREATE OR REPLACE FUNCTION public.verify_usuario_activo()
RETURNS JSONB AS $$
DECLARE
    v_auth_id UUID;
    v_activo BOOLEAN;
BEGIN
    v_auth_id := auth.uid();
    
    IF v_auth_id IS NULL THEN
        RETURN jsonb_build_object('activo', false);
    END IF;
    
    SELECT activo INTO v_activo
    FROM public.usuarios
    WHERE auth_id = v_auth_id;
    
    RETURN jsonb_build_object('activo', COALESCE(v_activo, false));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 10. FUNCIÓN RPC: Listar usuarios (usada por admin)
-- ============================================
CREATE OR REPLACE FUNCTION public.listar_usuarios_rpc(p_empresa_id UUID)
RETURNS JSONB AS $$
BEGIN
    RETURN (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', u.id,
                'auth_id', u.auth_id,
                'username', u.username,
                'nombre', u.nombre,
                'email', u.email,
                'rol_id', r.nombre,
                'activo', u.activo,
                'created_at', u.created_at
            )
        )
        FROM public.usuarios u
        LEFT JOIN public.roles r ON u.rol_id = r.id
        WHERE u.empresa_id = p_empresa_id AND u.activo = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 11. FUNCIÓN RPC: Desactivar usuario
-- ============================================
CREATE OR REPLACE FUNCTION public.desactivar_usuario_rpc(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_auth_id UUID;
BEGIN
    -- Obtener auth_id
    SELECT auth_id INTO v_auth_id FROM public.usuarios WHERE id = p_user_id;
    
    -- Desactivar en public.usuarios
    UPDATE public.usuarios SET activo = false WHERE id = p_user_id;
    
    -- También desactivar en auth.users (bloquear login)
    IF v_auth_id IS NOT NULL THEN
        UPDATE auth.users SET raw_app_meta_data = raw_app_meta_data || '{"banned": true}' WHERE id = v_auth_id;
    END IF;
    
    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- INSTRUCCIONES FINALES
-- ============================================
-- 1. Ejecutar este script completo en Supabase SQL Editor
-- 2. Verificar que los usuarios se migraron correctamente:
--    SELECT * FROM public.usuarios WHERE auth_id IS NULL; -- Debe devolver 0 filas
-- 3. Probar login:
--    SELECT * FROM auth.users WHERE email = 'admin1@guardaya.local';
-- 4. Después de verificar que todo funciona, descomentar:
--    ALTER TABLE public.usuarios DROP COLUMN IF EXISTS password_hash;
-- 5. En la app Flutter, actualizar el login para usar:
--    supabase.auth.signInWithPassword(email: username + '@guardaya.local', password: password)
-- 6. Luego de login exitoso, llamar: get_usuario_completo()
