-- ============================================
-- LIMPIAR Y PREPARAR CON DOMINIO CORRECTO
-- ============================================

-- 1. Desactivar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Borrar usuarios de prueba
DELETE FROM public.usuarios 
WHERE email LIKE '%@system.%' OR email LIKE '%@guardaya.%' OR email LIKE '%@example.%';

DELETE FROM auth.users 
WHERE email LIKE '%@system.%' OR email LIKE '%@guardaya.%' OR email LIKE '%@example.%';

-- 3. Recrear trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Verificar que está limpio
SELECT email FROM auth.users WHERE email LIKE '%@example.%';
SELECT username, email FROM public.usuarios;
