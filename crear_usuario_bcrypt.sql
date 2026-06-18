CREATE OR REPLACE FUNCTION public.crear_usuario_bcrypt(
  p_username text,
  p_password text,
  p_nombre text,
  p_apellidos text DEFAULT NULL,
  p_telefono text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_empresa_id uuid DEFAULT NULL,
  p_rol_nombre text DEFAULT 'empleado'::text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_rol_id uuid;
  v_rol_nombre text;
  v_result json;
BEGIN
  IF EXISTS (SELECT 1 FROM public.usuarios WHERE username = p_username) THEN
    RAISE EXCEPTION 'El nombre de usuario ya existe'
      USING HINT = 'username_taken';
  END IF;

  -- Resolver rol_id desde el nombre del rol
  SELECT id INTO v_rol_id FROM public.roles WHERE nombre = p_rol_nombre;
  IF v_rol_id IS NULL THEN
    RAISE EXCEPTION 'El rol % no existe', p_rol_nombre;
  END IF;

  -- Insertar en public.usuarios con password hasheado
  INSERT INTO public.usuarios (
    empresa_id, username, nombre, apellidos,
    telefono, email, rol_id, password_hash,
    activo, created_at
  ) VALUES (
    p_empresa_id, p_username, p_nombre, p_apellidos,
    p_telefono, p_email, v_rol_id, crypt(p_password, gen_salt('bf')),
    true, now()
  )
  RETURNING id INTO v_user_id;

  -- Devolver el usuario creado (sin password_hash)
  SELECT json_build_object(
    'id', u.id, 'empresa_id', u.empresa_id, 'username', u.username,
    'nombre', u.nombre, 'apellidos', u.apellidos, 'telefono', u.telefono,
    'email', u.email, 'rol_nombre', p_rol_nombre, 'activo', u.activo,
    'created_at', u.created_at
  ) INTO v_result
  FROM public.usuarios u WHERE u.id = v_user_id;

  RETURN v_result;
END;
$$;
