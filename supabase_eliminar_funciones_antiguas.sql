-- ============================================
-- ELIMINAR FUNCIONES ANTIGUAS NO UTILIZADAS
-- ============================================

-- Estas funciones fueron reemplazadas por get_usuario_completo()
-- que devuelve todos los datos en un solo llamado

-- 1. Eliminar get_user_empresa_id (reemplazada por get_usuario_completo)
DROP FUNCTION IF EXISTS public.get_user_empresa_id();

-- 2. Eliminar get_user_rol (reemplazada por get_usuario_completo)
DROP FUNCTION IF EXISTS public.get_user_rol();

-- 3. Verificar que solo quedan las funciones necesarias
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND routine_type = 'FUNCTION'
    AND routine_name IN (
        'get_usuario_completo',
        'verify_usuario_activo',
        'crear_usuario_seguro',
        'listar_usuarios_rpc',
        'desactivar_usuario_rpc',
        'handle_new_user'
    )
ORDER BY routine_name;

-- 4. Verificar triggers
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND trigger_name = 'on_auth_user_created';
