-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.roles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre character varying NOT NULL UNIQUE,
  descripcion text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.empresas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre character varying NOT NULL,
  slug character varying NOT NULL UNIQUE,
  email_contacto character varying,
  telefono character varying,
  direccion text,
  ruc_dni character varying,
  logo_url text,
  plan character varying NOT NULL DEFAULT 'basico'::character varying,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT empresas_pkey PRIMARY KEY (id)
);
CREATE TABLE public.usuarios (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid,
  username character varying NOT NULL UNIQUE,
  nombre character varying NOT NULL,
  email character varying,
  rol_id uuid,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  apellidos text,
  telefono text,
  password_hash text,
  CONSTRAINT usuarios_pkey PRIMARY KEY (id),
  CONSTRAINT usuarios_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT usuarios_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.roles(id)
);
CREATE TABLE public.clientes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL,
  nombre character varying NOT NULL,
  telefono character varying,
  email character varying,
  direccion text,
  notas text,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT clientes_pkey PRIMARY KEY (id),
  CONSTRAINT clientes_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id)
);
CREATE TABLE public.categorias (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL,
  nombre character varying NOT NULL,
  descripcion text,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categorias_pkey PRIMARY KEY (id),
  CONSTRAINT categorias_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id)
);
CREATE TABLE public.productos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL,
  categoria_id uuid,
  nombre character varying NOT NULL,
  descripcion text,
  precio numeric NOT NULL DEFAULT 0.00,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT productos_pkey PRIMARY KEY (id),
  CONSTRAINT productos_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id)
);
CREATE TABLE public.tipos_transferencia (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL,
  nombre character varying NOT NULL,
  icono text,
  color character varying,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tipos_transferencia_pkey PRIMARY KEY (id),
  CONSTRAINT tipos_transferencia_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id)
);
CREATE TABLE public.ventas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL,
  usuario_id uuid NOT NULL,
  cliente_id uuid,
  codigo_yape character varying,
  monto numeric NOT NULL DEFAULT 0.00,
  cliente_nombre character varying,
  cliente_telefono character varying,
  fecha_yape timestamp with time zone,
  descripcion text,
  estado USER-DEFINED NOT NULL DEFAULT 'pendiente'::estado_venta,
  imagen_yape_url text,
  imagen_entrega_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ventas_pkey PRIMARY KEY (id),
  CONSTRAINT ventas_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT ventas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id),
  CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);
CREATE TABLE public.venta_productos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  venta_id uuid NOT NULL,
  empresa_id uuid NOT NULL,
  producto_id uuid,
  nombre character varying NOT NULL,
  cantidad integer NOT NULL DEFAULT 1,
  precio_unitario numeric NOT NULL DEFAULT 0.00,
  subtotal numeric DEFAULT ((cantidad)::numeric * precio_unitario),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT venta_productos_pkey PRIMARY KEY (id),
  CONSTRAINT venta_productos_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id),
  CONSTRAINT venta_productos_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT venta_productos_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id)
);
CREATE TABLE public.historial_estados (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  venta_id uuid NOT NULL,
  empresa_id uuid NOT NULL,
  estado_anterior character varying,
  estado_nuevo character varying NOT NULL,
  usuario_id uuid,
  observacion text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT historial_estados_pkey PRIMARY KEY (id),
  CONSTRAINT historial_estados_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id),
  CONSTRAINT historial_estados_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT historial_estados_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id)
);
CREATE TABLE public.notificaciones (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid NOT NULL,
  venta_id uuid,
  usuario_id uuid,
  tipo USER-DEFINED NOT NULL,
  titulo character varying NOT NULL,
  mensaje text,
  leida boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notificaciones_pkey PRIMARY KEY (id),
  CONSTRAINT notificaciones_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT notificaciones_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id),
  CONSTRAINT notificaciones_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id)
);