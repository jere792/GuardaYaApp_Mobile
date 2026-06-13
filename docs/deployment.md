# Guía de Despliegue

## Requisitos Previos

- **Flutter SDK** 3.8.1+ instalado
- **Dart** 3.8.1+
- **Android Studio** o **VS Code** con plugins de Flutter
- **Cuenta en Supabase** (gratuita)
- **Supabase CLI** (opcional, para deploy por CLI)

---

## 1. Configurar Supabase (Backend)

### 1.1 Crear Proyecto
1. Ve a [https://supabase.com](https://supabase.com)
2. Clic en **New Project**
3. Elige nombre y región (recomendado: `sa-east-1` para Latam)
4. Espera a que el proyecto esté listo (~2 minutos)

### 1.2 Obtener Credenciales
Ve a **Project Settings** → **API**:
- `SUPABASE_URL` = https://`[project-ref]`.supabase.co
- `SUPABASE_ANON_KEY` = anon public key
- `SERVICE_ROLE_KEY` = service_role secret key

### 1.3 Crear Tablas Base
En el **SQL Editor** de Supabase, ejecuta:

```sql
-- 1. Crear tabla empresas
CREATE TABLE public.empresas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    email_contacto TEXT,
    telefono TEXT,
    direccion TEXT,
    ruc_dni TEXT,
    color_primario TEXT DEFAULT '#000000',
    color_secundario TEXT DEFAULT '#FFFFFF',
    color_acento TEXT DEFAULT '#0000FF',
    logo_url TEXT,
    plan TEXT DEFAULT 'basico',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Crear tabla roles
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Insertar roles por defecto
INSERT INTO public.roles (nombre) VALUES ('super_admin'), ('admin'), ('empleado');

-- 4. Crear tabla usuarios (sin auth_id)
CREATE TABLE public.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    apellidos TEXT,
    telefono TEXT,
    email TEXT,
    empresa_id UUID REFERENCES public.empresas(id),
    rol_id UUID REFERENCES public.roles(id),
    activo BOOLEAN DEFAULT true,
    password_hash TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. Crear tabla clientes
CREATE TABLE public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    nombre TEXT NOT NULL,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    notas TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. Crear tabla categorias
CREATE TABLE public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 7. Crear tabla productos
CREATE TABLE public.productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    categoria_id UUID REFERENCES public.categorias(id),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    precio NUMERIC NOT NULL DEFAULT 0.00,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 8. Crear tabla tipos_transferencia
CREATE TABLE public.tipos_transferencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    nombre TEXT NOT NULL,
    icono TEXT,
    color TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 9. Crear tabla ventas
CREATE TYPE public.estado_venta AS ENUM ('pendiente', 'completado', 'cancelado', 'reembolsado');

CREATE TABLE public.ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id),
    cliente_id UUID REFERENCES public.clientes(id),
    codigo_yape TEXT,
    monto NUMERIC NOT NULL DEFAULT 0.00,
    cliente_nombre TEXT,
    cliente_telefono TEXT,
    fecha_yape TIMESTAMP,
    descripcion TEXT,
    estado public.estado_venta DEFAULT 'pendiente',
    imagen_yape_url TEXT,
    imagen_entrega_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 10. Crear tabla venta_productos
CREATE TABLE public.venta_productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL REFERENCES public.ventas(id),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    producto_id UUID REFERENCES public.productos(id),
    nombre TEXT NOT NULL,
    cantidad INTEGER DEFAULT 1,
    precio_unitario NUMERIC DEFAULT 0.00,
    subtotal NUMERIC DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 11. Crear tabla historial_estados
CREATE TABLE public.historial_estados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL REFERENCES public.ventas(id),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    estado_anterior TEXT,
    estado_nuevo TEXT NOT NULL,
    usuario_id UUID REFERENCES public.usuarios(id),
    observacion TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 12. Crear tabla notificaciones
CREATE TYPE public.tipo_notificacion AS ENUM ('nueva_venta', 'estado_cambiado', 'sync_completado', 'sync_fallido');

CREATE TABLE public.notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id UUID NOT NULL REFERENCES public.empresas(id),
    venta_id UUID REFERENCES public.ventas(id),
    usuario_id UUID REFERENCES public.usuarios(id),
    tipo public.tipo_notificacion NOT NULL,
    titulo TEXT NOT NULL,
    mensaje TEXT,
    leida BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 1.4 Ejecutar SQL de Autenticación
Copia y pega el contenido de:
```
supabase_login_bcrypt_clean.sql
```

Esto crea:
- `crear_usuario_bcrypt(...)`
- `validar_login_bcrypt(...)`
- `cambiar_password_bcrypt(...)`
- `get_usuario_completo_by_username(...)`
- `verify_usuario_activo_by_username(...)`

### 1.5 Configurar Edge Function

#### Opción A: Via Dashboard (Recomendado)
1. Ve a **Edge Functions** → **Deploy a new function**
2. Nombre: `login-custom`
3. Copia y pega el contenido de:
   ```
   supabase/functions/login-custom/index.ts
   ```
4. Clic en **Deploy**

#### Opción B: Via CLI
```bash
# Login
npx supabase login

# Link project
npx supabase link

# Deploy
npx supabase functions deploy login-custom
```

### 1.6 Configurar Secret
Ve a **Edge Functions** → **Secrets**:
- **Name**: `SERVICE_ROLE_KEY`
- **Value**: Tu `service_role` key (Project Settings → API)

---

## 2. Configurar Flutter (Frontend)

### 2.1 Variables de Entorno

Crea el archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-project-ref.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
```

> ⚠️ **Nunca** pongas el `SERVICE_ROLE_KEY` en el `.env` del frontend.

### 2.2 Compilar la App

#### Android
```bash
# Debug
flutter run

# Release
flutter build apk --release

# Bundle (para Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Debug
flutter run

# Release
flutter build ios --release
```

### 2.3 Hot Reload
Durante desarrollo:
```bash
flutter run --hot
```

---

## 3. Crear Primer Usuario

### 3.1 Desde SQL (rápido)
```sql
-- Crear empresa primero
INSERT INTO public.empresas (nombre, color_primario, color_secundario, color_acento)
VALUES ('Mi Empresa', '#FF6B00', '#00C853', '#2979FF');

-- Crear super_admin
SELECT public.crear_usuario_bcrypt(
    'admin',           -- username
    'admin123',        -- password
    'Administrador',   -- nombre
    'Principal',       -- apellidos
    '999888777',       -- telefono
    NULL,              -- email
    NULL,              -- empresa_id (NULL para super_admin)
    'super_admin'      -- rol
);
```

### 3.2 Desde la App
1. Abre la app
2. Ve a **"Crear Usuario (Dev)"**
3. Llena los campos y selecciona rol
4. Clic en **Crear Usuario**

---

## 4. Verificar Despliegue

### 4.1 Test de Login
```bash
# Probar Edge Function directamente
curl -X POST https://tu-project-ref.supabase.co/functions/v1/login-custom \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Debe devolver:
```json
{
  "success": true,
  "user": {
    "id": "...",
    "username": "admin",
    "nombre": "Administrador",
    "apellidos": "Principal",
    "telefono": "999888777",
    "email": null,
    "empresa_id": null,
    "rol_id": "super_admin",
    "activo": true,
    "created_at": "..."
  }
}
```

### 4.2 Test de App
1. Abre la app
2. Ingresa `admin` / `admin123`
3. Debe entrar al **Home**

---

## 5. Troubleshooting

| Problema | Solución |
|----------|----------|
| `401 Invalid API key` | Verificar que `SERVICE_ROLE_KEY` está en Secrets |
| `Usuario o contraseña incorrectos` | Verificar que `validar_login_bcrypt` existe en SQL |
| `Column password_hash does not exist` | Ejecutar `supabase_login_bcrypt_clean.sql` completo |
| `Failed to delete user` | Usar SQL directo: `DELETE FROM auth.users WHERE email = '...'` |
| App no conecta | Verificar `.env` tiene `SUPABASE_URL` y `SUPABASE_ANON_KEY` |

---

## 6. Producción

### 6.1 Checklist Pre-Deploy
- [ ] SQL ejecutado en producción
- [ ] Edge Function `login-custom` desplegada
- [ ] Secret `SERVICE_ROLE_KEY` configurado
- [ ] `.env` con credenciales correctas
- [ ] Primer usuario creado
- [ ] Login testeado
- [ ] Modo offline testeado

### 6.2 Monitoreo
- Supabase Dashboard → Logs → Edge Functions
- Supabase Dashboard → Logs → API
- Firebase Crashlytics (opcional para Flutter)

---

## 7. Actualizaciones

### Actualizar Edge Function
1. Editar `supabase/functions/login-custom/index.ts`
2. Desplegar de nuevo:
   ```bash
   npx supabase functions deploy login-custom
   ```

### Actualizar SQL
1. Editar archivo `.sql`
2. Ejecutar en SQL Editor de Supabase
3. **Cuidado**: Si hay datos existentes, usar `CREATE OR REPLACE` en vez de `DROP`

---

## Archivos Clave del Despliegue

| Archivo | Propósito |
|---------|-----------|
| `supabase_login_bcrypt_clean.sql` | Funciones SQL de autenticación |
| `supabase/functions/login-custom/index.ts` | Edge Function de login |
| `.env` | Credenciales del frontend |
| `pubspec.yaml` | Dependencias Flutter |

---

## Notas Importantes

- **No usar Supabase Auth**: La app usa solo PostgreSQL + Edge Functions
- **No exponer service_role_key**: Solo va en Edge Functions Secrets
- **Backup antes de cambios**: Supabase hace backups automáticos cada día
- **Modo offline**: La app funciona sin internet, sincroniza cuando hay conexión
