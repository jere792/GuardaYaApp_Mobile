-- ============================================
-- AGREGAR APELLIDOS Y TELEFONO A USUARIOS
-- ============================================

-- 1. Agregar columnas nuevas
ALTER TABLE public.usuarios ADD COLUMN IF NOT EXISTS apellidos TEXT;
ALTER TABLE public.usuarios ADD COLUMN IF NOT EXISTS telefono TEXT;

-- 2. Hacer email nullable (ya lo debería ser)
ALTER TABLE public.usuarios ALTER COLUMN email DROP NOT NULL;
ALTER TABLE public.usuarios ALTER COLUMN empresa_id DROP NOT NULL;
ALTER TABLE public.usuarios ALTER COLUMN rol_id DROP NOT NULL;

-- 3. Actualizar trigger handle_new_user con campos nuevos
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.usuarios WHERE auth_id = NEW.id) THEN
        INSERT INTO public.usuarios (
            auth_id,
            username,
            nombre,
            apellidos,
            telefono,
            email,
            empresa_id,
            rol_id,
            activo,
            created_at
        ) VALUES (
            NEW.id,
            COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
            COALESCE(NEW.raw_user_meta_data->>'nombre', split_part(NEW.email, '@', 1)),
            NULLIF(trim(NEW.raw_user_meta_data->>'apellidos'), ''),
            NULLIF(trim(NEW.raw_user_meta_data->>'telefono'), ''),
            NULLIF(trim(NEW.raw_user_meta_data->>'email_usuario'), ''),
            NULLIF(trim(NEW.raw_user_meta_data->>'empresa_id'), '')::UUID,
            NULLIF(trim(NEW.raw_user_meta_data->>'rol_id'), '')::UUID,
            true,
            NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recrear trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Actualizar función get_usuario_completo
CREATE OR REPLACE FUNCTION public.get_usuario_completo()
RETURNS JSONB AS $$
DECLARE
    v_auth_id UUID;
    resultado JSONB;
BEGIN
    v_auth_id := auth.uid();
    
    IF v_auth_id IS NULL THEN
        RETURN jsonb_build_object('error', 'No autenticado');
    END IF;
    
    SELECT jsonb_build_object(
        'id', u.id,
        'auth_id', u.auth_id,
        'username', u.username,
        'nombre', u.nombre,
        'apellidos', u.apellidos,
        'telefono', u.telefono,
        'email', u.email,
        'empresa_id', u.empresa_id,
        'rol_id', r.nombre,
        'activo', u.activo,
        'created_at', u.created_at,
        'empresa', CASE 
            WHEN u.empresa_id IS NOT NULL THEN jsonb_build_object(
                'id', e.id,
                'nombre', e.nombre,
                'color_primario', e.color_primario,
                'color_secundario', e.color_secundario,
                'color_acento', e.color_acento
            )
            ELSE NULL
        END
    ) INTO resultado
    FROM public.usuarios u
    LEFT JOIN public.roles r ON u.rol_id = r.id
    LEFT JOIN public.empresas e ON u.empresa_id = e.id
    WHERE u.auth_id = v_auth_id AND u.activo = true;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Actualizar función crear_usuario_seguro
CREATE OR REPLACE FUNCTION public.crear_usuario_seguro(
    p_username TEXT,
    p_password TEXT,
    p_nombre TEXT,
    p_apellidos TEXT DEFAULT NULL,
    p_telefono TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_empresa_id UUID DEFAULT NULL,
    p_rol_nombre TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_rol_id UUID;
    v_auth_id UUID;
    v_instance_id UUID;
    v_metadata JSONB;
BEGIN
    SELECT id INTO v_rol_id FROM public.roles WHERE nombre = p_rol_nombre;
    
    IF v_rol_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Rol no encontrado: ' || p_rol_nombre);
    END IF;
    
    SELECT id INTO v_instance_id FROM auth.instances LIMIT 1;
    IF v_instance_id IS NULL THEN
        v_instance_id := '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;
    
    v_auth_id := gen_random_uuid();
    
    v_metadata := jsonb_build_object(
        'username', p_username,
        'nombre', p_nombre,
        'rol_id', v_rol_id
    );
    
    IF p_apellidos IS NOT NULL THEN
        v_metadata := v_metadata || jsonb_build_object('apellidos', p_apellidos);
    END IF;
    IF p_telefono IS NOT NULL THEN
        v_metadata := v_metadata || jsonb_build_object('telefono', p_telefono);
    END IF;
    IF p_email IS NOT NULL THEN
        v_metadata := v_metadata || jsonb_build_object('email_usuario', p_email);
    END IF;
    IF p_empresa_id IS NOT NULL THEN
        v_metadata := v_metadata || jsonb_build_object('empresa_id', p_empresa_id);
    END IF;
    
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
        p_username || '@example.com',
        crypt(p_password, gen_salt('bf')),
        NOW(),
        v_metadata,
        NOW(),
        NOW(),
        'authenticated',
        '',
        ''
    );
    
    UPDATE public.usuarios 
    SET apellidos = p_apellidos,
        telefono = p_telefono,
        email = p_email,
        empresa_id = p_empresa_id,
        rol_id = v_rol_id
    WHERE auth_id = v_auth_id;
    
    RETURN jsonb_build_object('success', true, 'auth_id', v_auth_id);
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Actualizar función listar_usuarios_rpc
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
                'apellidos', u.apellidos,
                'telefono', u.telefono,
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

-- 8. Verificar columnas
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'usuarios' AND table_schema = 'public'
ORDER BY ordinal_position;
