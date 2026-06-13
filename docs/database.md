# Base de Datos

## Sistema: Supabase (PostgreSQL)

GuardaYa utiliza **Supabase** como backend, pero de una forma no tradicional:
- **PostgreSQL** como base de datos principal
- **Edge Functions** para lógica de servidor (no dependen de Supabase Auth)
- **Row Level Security (RLS)** desactivado en favor de validación por RPC

## Tablas Principales

### `public.usuarios`

**Fuente de verdad de autenticación y usuarios.**

```sql
CREATE TABLE public.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    apellidos TEXT,
    telefono TEXT,
    email TEXT,           -- Email real del usuario (opcional)
    empresa_id UUID,
    rol_id UUID,
    activo BOOLEAN DEFAULT true,
    password_hash TEXT,   -- bcrypt hash (crypt)
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Notas:**
- `auth_id` fue eliminado (no usamos Supabase Auth)
- `email` es opcional y real (no generado)
- `password_hash` usa `crypt(password, gen_salt('bf'))`

### `public.empresas`

```sql
CREATE TABLE public.empresas (
    id UUID PRIMARY KEY,
    nombre TEXT NOT NULL,
    color_primario TEXT,
    color_secundario TEXT,
    color_acento TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.roles`

```sql
CREATE TABLE public.roles (
    id UUID PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL  -- super_admin, admin, empleado
);
```

### `public.ventas`

```sql
CREATE TABLE public.ventas (
    id UUID PRIMARY KEY,
    empresa_id UUID,
    usuario_id UUID,
    cliente_id UUID,
    codigo TEXT,
    monto DECIMAL(10,2),
    fecha DATE,
    estado TEXT DEFAULT 'pendiente',
    comprobante_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.productos`

```sql
CREATE TABLE public.productos (
    id UUID PRIMARY KEY,
    empresa_id UUID,
    nombre TEXT NOT NULL,
    precio DECIMAL(10,2),
    stock INTEGER,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.clientes`

```sql
CREATE TABLE public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL,
    nombre TEXT NOT NULL,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    notas TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.categorias`

```sql
CREATE TABLE public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.tipos_transferencia`

```sql
CREATE TABLE public.tipos_transferencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL,
    nombre TEXT NOT NULL,
    icono TEXT,
    color TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.venta_productos`

```sql
CREATE TABLE public.venta_productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL,
    empresa_id UUID NOT NULL,
    producto_id UUID,
    nombre TEXT NOT NULL,
    cantidad INTEGER DEFAULT 1,
    precio_unitario NUMERIC DEFAULT 0.00,
    subtotal NUMERIC DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.historial_estados`

```sql
CREATE TABLE public.historial_estados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL,
    empresa_id UUID NOT NULL,
    estado_anterior TEXT,
    estado_nuevo TEXT NOT NULL,
    usuario_id UUID,
    observacion TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### `public.notificaciones`

```sql
CREATE TABLE public.notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL,
    venta_id UUID,
    usuario_id UUID,
    tipo TEXT NOT NULL,
    titulo TEXT NOT NULL,
    mensaje TEXT,
    leida BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Tipos Enumerados

```sql
-- Enum para estado de ventas
CREATE TYPE public.estado_venta AS ENUM ('pendiente', 'completado', 'cancelado', 'reembolsado');

-- Enum para tipos de notificación
CREATE TYPE public.tipo_notificacion AS ENUM ('nueva_venta', 'estado_cambiado', 'sync_completado', 'sync_fallido');
```

## Funciones SQL

### Autenticación

| Función | Descripción |
|---------|-------------|
| `crear_usuario_bcrypt(...)` | Crea usuario con hash bcrypt |
| `validar_login_bcrypt(...)` | Valida login y devuelve usuario |
| `cambiar_password_bcrypt(...)` | Cambia contraseña con validación previa |
| `get_usuario_completo_by_username(...)` | Obtiene usuario con empresa y colores |
| `verify_usuario_activo_by_username(...)` | Verifica si usuario está activo |

### Gestión

| Función | Descripción |
|---------|-------------|
| `listar_usuarios_rpc(...)` | Lista usuarios de una empresa |
| `crear_venta_rpc(...)` | Crea una nueva venta |
| `obtener_ventas_por_fecha(...)` | Filtra ventas por fecha |
| `buscar_venta_por_codigo(...)` | Busca venta por código OCR |

## Edge Functions

| Función | Descripción | Endpoint |
|---------|-------------|----------|
| `login-custom` | Valida bcrypt y devuelve usuario | `POST /functions/v1/login-custom` |
| `ocr-extract` | Procesa imágenes con OCR | `POST /functions/v1/ocr-extract` |

## Variables de Entorno (Edge Functions)

| Variable | Descripción |
|----------|-------------|
| `SERVICE_ROLE_KEY` | Clave para acceso a base de datos |
| `SUPABASE_URL` | URL del proyecto (automático) |

## Eliminaciones

Se eliminaron de la base de datos:
- ❌ Triggers en `auth.users`
- ❌ Funciones con `auth.uid()`
- ❌ Columna `auth_id` en `public.usuarios`
- ❌ Usuarios de `auth.users` generados automáticamente

## Modo Offline

La app usa **SQLite** local para:
- Ventas pendientes de sincronización
- Datos de usuario en caché
- Productos y clientes (caché)

**Flujo de sincronización:**
1. Usuario crea venta sin internet
2. Se guarda en `pending_ventas` (SQLite)
3. `WorkManager` intenta sincronizar cada 15 min
4. Si hay conexión, envía a Supabase y marca como sincronizada

## Respaldo y Seguridad

- **Backups automáticos**: Activados en Supabase
- **RLS**: No se usa (las queries se validan por RPC con username)
- **service_role**: Solo accesible por Edge Functions (no desde Flutter)
