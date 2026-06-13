# Sistema de Autenticación

## Filosofía

GuardaYa utiliza un **sistema de autenticación propio** basado en **bcrypt**, sin depender de Supabase Auth ni JWT. Esto proporciona:

- **Control total** sobre el flujo de login
- **Independencia** de servicios de autenticación de terceros
- **Simplicidad** en el manejo de sesiones
- **Sin correos electrónicos obligatorios** (el email es opcional en la tabla de usuarios)

## Flujo de Autenticación

### 1. Creación de Usuario

```sql
-- La función crear_usuario_bcrypt en PostgreSQL:
-- 1. Valida username único
-- 2. Busca el rol por nombre
-- 3. Genera hash bcrypt con crypt(password, gen_salt('bf'))
-- 4. Inserta en public.usuarios (sin auth_id, sin auth.users)
```

**Campos requeridos:**
- `username` (único, obligatorio)
- `password` (se hashea con bcrypt)
- `nombre` (obligatorio)
- `rol_nombre` (obligatorio: super_admin, admin, empleado)

**Campos opcionales:**
- `apellidos`
- `telefono`
- `email` (del usuario real, no generado)
- `empresa_id` (obligatorio para admin y empleado, null para super_admin)

### 2. Login (Autenticación)

```
Flutter App
    ↓ POST /functions/v1/login-custom
    ↓ body: { username, password }
Edge Function
    ↓ RPC validar_login_bcrypt(username, password)
PostgreSQL
    ↓ SELECT * FROM public.usuarios WHERE username = ? AND activo = true
    ↓ crypt(password, password_hash) = password_hash
    ↓ RETURN usuario con datos completos
```

### 3. Manejo de Sesión

**No hay JWT ni tokens.** La sesión se maneja localmente:

1. **Login exitoso** → Guarda `Usuario` en `SecureStorage`
2. **App inicia** → Lee `Usuario` de `SecureStorage`
3. **Logout** → Borra `SecureStorage.clearAll()`
4. **Verificación** → Usa `verify_usuario_activo_by_username(username)`

## Componentes

### Edge Function: `login-custom`

```typescript
// Endpoint: POST /functions/v1/login-custom
// Body: { "username": "...", "password": "..." }
// Response: { "success": true, "user": { ... } }
```

**Responsabilidad:**
- Validar contra `public.usuarios` usando RPC
- Devolver datos del usuario (sin auth_id)
- **No** sincroniza con `auth.users`
- **No** genera email ni JWT

### Funciones SQL

#### `validar_login_bcrypt(username, password)`
```sql
-- 1. Busca usuario activo
-- 2. Compara hash con crypt(password, password_hash)
-- 3. Devuelve { success, user } o { success: false, error }
```

#### `crear_usuario_bcrypt(...)`
```sql
-- 1. Valida username único
-- 2. Genera hash bcrypt
-- 3. Inserta en public.usuarios
-- 4. Devuelve { success, id }
```

#### `cambiar_password_bcrypt(...)`
```sql
-- 1. Verifica password actual con crypt
-- 2. Genera nuevo hash bcrypt
-- 3. Actualiza password_hash
```

#### `get_usuario_completo_by_username(username)`
```sql
-- Devuelve datos del usuario con empresa y colores
-- Usa JOINs a roles y empresas
```

#### `verify_usuario_activo_by_username(username)`
```sql
-- Verifica que el usuario siga activo en el servidor
-- Usado para modo offline
```

## Roles

| Rol | Descripción | empresa_id |
|-----|-------------|------------|
| **super_admin** | Acceso a todas las empresas, gestión global | `NULL` |
| **admin** | Gestión de una empresa específica | Requerido |
| **empleado** | Operaciones básicas de ventas | Requerido |

## Seguridad

- **bcrypt**: `crypt(password, gen_salt('bf'))` en PostgreSQL
- **service_role key**: Solo usada por la Edge Function (no expuesta al cliente)
- **SecureStorage**: Datos de usuario cifrados en el dispositivo
- **No tokens**: La sesión es local, sin JWT en tránsito

## Ventajas vs Supabase Auth

| Aspecto | Supabase Auth | Nuestro Sistema |
|---------|---------------|-----------------|
| Dependencia | Alta (supabase_flutter auth) | Baja (solo HTTP client) |
| Email | Obligatorio (auth.users) | Opcional (public.usuarios) |
| JWT | Tokens con expiración | Sin tokens, sesión local |
| Control | Limitado por Supabase | Total sobre el flujo |
| Offline | Complejo (refresh token) | Simple (SecureStorage) |
| Multi-empresa | Requiere metadata hacks | Nativo en la tabla |

## Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                            │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │ Login Page  │  │ AuthNotifier │  │ SecureStorage   │ │
│  └─────────────┘  └──────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────┘
                           │ POST /functions/v1/login-custom
                           │ { username, password }
                           ▼
┌─────────────────────────────────────────────────────────┐
│                EDGE FUNCTION (Deno)                       │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ 1. Recibe username + password                      │  │
│  │ 2. RPC: validar_login_bcrypt(username, password)   │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                POSTGRESQL (Supabase)                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ 1. SELECT FROM public.usuarios WHERE username = ?    │  │
│  │ 2. crypt(password, password_hash) = password_hash    │  │
│  │ 3. RETURN user data                                  │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ 1. Recibe user data                                  │  │
│  │ 2. Guarda en SecureStorage                           │  │
│  │ 3. isAuthenticated = true                            │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Archivos Clave

- `supabase_login_bcrypt_clean.sql` - Funciones SQL del sistema
- `supabase/functions/login-custom/index.ts` - Edge Function de login
- `lib/data/datasources/remote/auth_datasource.dart` - Fuente de datos en Flutter
- `lib/data/repositories/implementations/auth_repository_impl.dart` - Repositorio de auth
- `lib/presentation/providers/auth_provider.dart` - Estado de autenticación
- `lib/presentation/pages/login_page.dart` - UI de login
