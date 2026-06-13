-- ============================================
-- ACTUALIZAR TRIGGER PARA MANEJAR EMAIL OPCIONAL
-- ============================================

-- 1. Eliminar trigger viejo
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Actualizar función del trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_email TEXT;
BEGIN
    -- Determinar el email: usar email_usuario del metadata si existe, sino NULL
    v_email := NULLIF(trim(NEW.raw_user_meta_data->>'email_usuario'), '');
    
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
            v_email,  -- NULL si no se proporcionó email_usuario
            NULLIF(trim(NEW.raw_user_meta_data->>'empresa_id'), '')::UUID,
            NULLIF(trim(NEW.raw_user_meta_data->>'rol_id'), '')::UUID,
            true,
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Recrear trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Verificar trigger
SELECT trigger_name FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created';
