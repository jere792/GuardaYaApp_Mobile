-- ============================================
-- ACTUALIZAR FUNCIONES RLS EXISTENTES
-- ============================================

-- 1. Primero eliminar funciones (usando CASCADE para evitar errores de dependencias)
DROP FUNCTION IF EXISTS public.get_user_rol() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_empresa_id() CASCADE;

-- 2. Recrear get_user_empresa_id()
-- Ahora maneja super_admin (empresa_id = NULL) y usuarios normales
CREATE OR REPLACE FUNCTION public.get_user_empresa_id()
RETURNS UUID AS $$
DECLARE
    v_empresa_id UUID;
    v_rol_id UUID;
BEGIN
    v_empresa_id := (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::UUID;
    v_rol_id := (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID;
    
    -- Si es super_admin, devolver NULL (puede ver todo)
    IF v_rol_id = (SELECT id FROM public.roles WHERE nombre = 'super_admin') THEN
        RETURN NULL;
    END IF;
    
    RETURN v_empresa_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Recrear get_user_rol()
CREATE OR REPLACE FUNCTION public.get_user_rol()
RETURNS VARCHAR AS $$
DECLARE
    v_rol_id UUID;
    v_rol_nombre VARCHAR;
BEGIN
    v_rol_id := (auth.jwt() -> 'user_metadata' ->> 'rol_id')::UUID;
    
    SELECT nombre INTO v_rol_nombre
    FROM public.roles
    WHERE id = v_rol_id;
    
    RETURN COALESCE(v_rol_nombre, 'empleado');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Verificar
SELECT routine_name, data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND routine_name IN ('get_user_empresa_id', 'get_user_rol');
