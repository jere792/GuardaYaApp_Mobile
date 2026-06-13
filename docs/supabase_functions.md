# GuardaYa - Supabase Functions y Configuración

## Visión General

Este documento registra **todas las funciones RPC** y la **configuración de RLS** que la app móvil necesita para funcionar correctamente con Supabase.

**Nota importante:** La app usa un sistema de autenticación **custom** (bcrypt + Edge Function `login-custom`) en lugar de Supabase Auth nativo. Por lo tanto, **RLS debe estar desactivado** en las tablas principales, ya que la app usa la `anon` key para consultas directas.

---

## Funciones RPC Requeridas

### 1. `crear_usuario_bcrypt`

**Archivo:** `setup_rpc_y_rls.sql`

**Propósito:** Crear un nuevo usuario con contraseña hasheada con bcrypt.

**Por qué es necesaria:** La app necesita crear usuarios que luego puedan iniciar sesión con el Edge Function `login-custom`. La contraseña debe ser hasheada con `crypt()` en PostgreSQL para que el login funcione.

**Parámetros:**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `p_username` | TEXT | ✅ | Nombre de usuario único |
| `p_password` | TEXT | ✅ | Contraseña en texto plano (se hashea en el servidor) |
| `p_nombre` | TEXT | ✅ | Nombre completo |
| `p_rol_nombre` | TEXT | ✅ | Rol: `super_admin`, `admin`, `empleado` |
| `p_apellidos` | TEXT | ❌ | Apellidos |
| `p_telefono` | TEXT | ❌ | Teléfono |
| `p_email` | TEXT | ❌ | Email |
| `p_empresa_id` | UUID | ❌ | ID de empresa (solo admin/empleado) |

**Retorno:** `JSONB` con datos del usuario creado

**Dónde se usa:** `lib/data/datasources/remote/usuario_datasource.dart` → `crearUsuario()`

---

### 2. `get_usuario_completo_by_username`

**Archivo:** Supabase (ya existente en el proyecto)

**Propósito:** Obtener todos los datos del usuario incluyendo información de empresa y branding.

**Parámetros:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `p_username` | TEXT | Nombre de usuario |

**Dónde se usa:** `lib/data/datasources/remote/auth_datasource.dart` → `getUsuarioCompleto()`

---

### 3. `verify_usuario_activo_by_username`

**Archivo:** Supabase (ya existente en el proyecto)

**Propósito:** Verificar si el usuario está activo.

**Parámetros:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `p_username` | TEXT | Nombre de usuario |

**Dónde se usa:** `lib/data/datasources/remote/auth_datasource.dart` → `verifyUsuarioActivo()`

---

### 4. `validar_login_bcrypt`

**Archivo:** `supabase_login_bcrypt_clean.sql` (ya existente)

**Propósito:** Validar credenciales de login usando bcrypt. Devuelve datos del usuario si la contraseña coincide.

**Parámetros:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `p_username` | TEXT | Nombre de usuario |
| `p_password` | TEXT | Contraseña en texto plano |

**Dónde se usa:** Indirectamente vía Edge Function `login-custom`

---

## Tablas con RLS Desactivado

Por la arquitectura actual (auth custom sin JWT), las siguientes tablas deben tener **RLS desactivado**:

| Tabla | Motivo | Método de Acceso |
|-------|--------|-----------------|
| `usuarios` | Listar, desactivar, crear usuarios | Query directa + RPC (crear) |
| `ventas` | CRUD de ventas | Query directa |
| `productos` | Cuando se implemente | Query directa |
| `clientes` | Cuando se implemente | Query directa |

**Comando SQL:**
```sql
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
```

---

## Edge Functions

### 1. `login-custom`

**Archivo:** Supabase Edge Functions

**Propósito:** Endpoint de login que valida credenciales contra `public.usuarios` usando bcrypt.

**Por qué es necesaria:** Flutter no puede ejecutar bcrypt.compare directamente porque el hash generado por PostgreSQL `crypt()` usa un formato diferente al de las librerías de Dart/JavaScript.

**Body esperado:**
```json
{
  "username": "usuario",
  "password": "contraseña"
}
```

**Dónde se usa:** `lib/data/datasources/remote/auth_datasource.dart` → `login()`

---

## Mapa de Acceso a Datos

### Usuarios (Empleados)

| Operación | Tipo | SQL/Function | Archivo Flutter |
|-----------|------|-------------|----------------|
| **Crear** | `INSERT` | `rpc('crear_usuario_bcrypt')` | `usuario_datasource.dart` → `crearUsuario()` |
| **Listar** | `SELECT` | `from('usuarios').select().eq('empresa_id')` | `usuario_datasource.dart` → `listarUsuarios()` |
| **Desactivar** | `UPDATE` | `from('usuarios').update({activo: false})` | `usuario_datasource.dart` → `desactivarUsuario()` |

### Ventas

| Operación | Tipo | SQL/Function | Archivo Flutter |
|-----------|------|-------------|----------------|
| **Crear** | `INSERT` | `from('ventas').insert()` | `ventas_datasource.dart` → `registrarVenta()` |
| **Listar por fecha** | `SELECT` | `from('ventas').select().eq('empresa_id').gte('created_at')` | `ventas_datasource.dart` → `obtenerVentasPorFecha()` |
| **Buscar por código** | `SELECT` | `from('ventas').select().eq('codigo_yape')` | `ventas_datasource.dart` → `buscarVentaPorCodigo()` |
| **Buscar por teléfono** | `SELECT` | `from('ventas').select().ilike('cliente_telefono')` | `ventas_datasource.dart` → `buscarVentaPorTelefono()` |
| **Cambiar estado** | `UPDATE` | `from('ventas').update({estado: ...})` | `ventas_datasource.dart` → `cambiarEstadoVenta()` |

### Autenticación

| Operación | Tipo | Método | Archivo Flutter |
|-----------|------|--------|----------------|
| **Login** | `POST` | `supabase.functions.invoke('login-custom')` | `auth_datasource.dart` → `login()` |
| **Obtener usuario** | `RPC` | `supabase.rpc('get_usuario_completo_by_username')` | `auth_datasource.dart` → `getUsuarioCompleto()` |
| **Verificar activo** | `RPC` | `supabase.rpc('verify_usuario_activo_by_username')` | `auth_datasource.dart` → `verifyUsuarioActivo()` |

---

## Notas para Mantenimiento

### ⚠️ Si cambias a Supabase Auth nativo

1. **Activar RLS** en todas las tablas:
   ```sql
   ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
   ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
   ```

2. **Eliminar dependencia** de `crear_usuario_bcrypt` y `login-custom`. Usar el flujo nativo de `supabase.auth.signUp()` y `supabase.auth.signIn()`.

3. **Actualizar datasource** para usar `auth.uid()` en vez de `empresa_id` manual.

4. **Eliminar Edge Function** `login-custom` y las RPCs de bcrypt.

### ⚠️ Si agregas una nueva tabla

1. **Desactivar RLS**:
   ```sql
   ALTER TABLE public.nueva_tabla DISABLE ROW LEVEL SECURITY;
   ```

2. **Agregar aquí** en la sección "Tablas con RLS Desactivado".

3. **Registrar** en el mapa de acceso a datos si usa queries directas.

---

## Archivos de Configuración

| Archivo | Descripción |
|---------|-------------|
| `setup_rpc_y_rls.sql` | Crea `crear_usuario_bcrypt` + desactiva RLS |
| `desactivar_rls_temp.sql` | Solo desactiva RLS (sin crear funciones) |
| `supabase_login_bcrypt_clean.sql` | Funciones de autenticación bcrypt |
| `actualizar_trigger_email.sql` | Trigger de `auth.users` (legacy, no usado) |

---

## Historial de Cambios

| Fecha | Cambio | Razón |
|-------|--------|-------|
| 2026-06-13 | Desactivar RLS en `usuarios` y `ventas` | App usa auth custom sin JWT |
| 2026-06-13 | Crear `crear_usuario_bcrypt` | Crear usuarios con hash bcrypt para login |
| 2026-06-13 | Cambiar `listar_usuarios` de RPC a query directa | Simplificar mantenimiento |
| 2026-06-13 | Cambiar `desactivar_usuario` de RPC a query directa | Simplificar mantenimiento |
| 2026-06-13 | Crear `login-custom` Edge Function | Validar bcrypt desde Flutter |
| 2026-06-13 | Crear `get_usuario_completo_by_username` | Obtener datos de usuario post-login |
| 2026-06-13 | Crear `verify_usuario_activo_by_username` | Verificar estado de cuenta |
