-- ============================================
-- LIMPIAR USUARIOS DE PRUEBA Y PREPARAR PARA CREAR DESDE LA APP
-- ============================================

-- 1. Desactivar trigger para poder borrar
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Borrar usuarios de public.usuarios
DELETE FROM public.usuarios 
WHERE email LIKE '%@system.%' 
   OR email LIKE '%@guardaya.%' 
   OR email LIKE '%@example.%';

-- 3. Borrar usuarios de auth.users
DELETE FROM auth.users 
WHERE email LIKE '%@system.%' 
   OR email LIKE '%@guardaya.%' 
   OR email LIKE '%@example.%';

-- 4. Recrear trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Verificar que está limpio
SELECT email FROM auth.users WHERE email LIKE '%@system.%';
SELECT username, email FROM public.usuarios;

-- 6. Verificar estructura de columnas
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'usuarios' AND table_schema = 'public'
ORDER BY ordinal_position;
