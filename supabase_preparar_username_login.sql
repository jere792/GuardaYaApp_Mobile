-- ============================================
-- LIMPIAR Y PREPARAR PARA USERNAME-ONLY LOGIN
-- ============================================

-- 1. Eliminar trigger viejo
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Asegurar que email sea nullable en public.usuarios
ALTER TABLE public.usuarios ALTER COLUMN email DROP NOT NULL;

-- 3. Actualizar trigger: email_usuario va a public.usuarios, email interno va a auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
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
            -- Email real del usuario (null si no lo ingresó)
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
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Limpiar usuarios de prueba anteriores
DELETE FROM public.usuarios WHERE email LIKE '%@system.%' OR email LIKE '%@guardaya.%' OR email LIKE '%@example.%' OR auth_id IS NOT NULL;
DELETE FROM auth.users WHERE email LIKE '%@system.%' OR email LIKE '%@guardaya.%' OR email LIKE '%@example.%';

-- 6. Verificar que está limpio
SELECT email FROM auth.users WHERE email LIKE '%@system.%';
SELECT email FROM public.usuarios;

-- 7. Verificar columnas
SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'usuarios' AND table_schema = 'public';
