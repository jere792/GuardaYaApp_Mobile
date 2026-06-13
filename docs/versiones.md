# Versiones del Proyecto

## Versión de la App

| Componente | Versión |
|-----------|---------|
| **App** | `1.0.0+1` |
| **Flutter** | `^3.8.1` |
| **Dart** | `^3.8.1` |
| **Android SDK** | `minSdkVersion 21` (implícito) |

## Dependencias del Frontend

### UI / Navegación
| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter` | `^3.8.1` | Framework UI |
| `cupertino_icons` | `^1.0.8` | Iconos iOS |
| `go_router` | `^14.8.1` | Navegación declarativa |
| `cached_network_image` | `^3.4.1` | Caché de imágenes |
| `shimmer` | `^3.0.0` | Efectos de carga |
| `intl` | `^0.19.0` | Formato de fechas/números |
| `image_picker` | `^1.1.2` | Cámara y galería |

### Estado
| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_riverpod` | `^2.6.1` | State management |
| `fpdart` | `^1.1.1` | Programación funcional (Either) |
| `equatable` | `^2.0.7` | Comparación de objetos |

### Backend
| Paquete | Versión | Uso |
|---------|---------|-----|
| `supabase_flutter` | `^2.8.4` | Cliente Supabase (solo queries, no auth) |

### Almacenamiento Local
| Paquete | Versión | Uso |
|---------|---------|-----|
| `sqflite` | `^2.4.2` | SQLite (ventas offline) |
| `path_provider` | `^2.1.5` | Rutas de sistema de archivos |
| `flutter_secure_storage` | `^9.2.4` | Almacenamiento seguro (usuario) |
| `shared_preferences` | `^2.5.3` | Preferencias (tema) |

### Conectividad / Background
| Paquete | Versión | Uso |
|---------|---------|-----|
| `connectivity_plus` | `^6.1.3` | Detección de internet |
| `workmanager` | `^0.9.0+3` | Sync en background |

### OCR
| Paquete | Versión | Uso |
|---------|---------|-----|
| `google_mlkit_text_recognition` | `^0.14.0` | OCR local (comprobantes) |

### Utilidades
| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_dotenv` | `^5.2.1` | Variables de entorno (dev) |
| `get_it` | `^8.0.3` | Service locator (DI) |
| `injectable` | `^2.5.0` | Generación de DI |

### Dev
| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_test` | SDK | Tests |
| `flutter_lints` | `^5.0.0` | Linting |
| `build_runner` | `^2.4.15` | Generación de código |
| `injectable_generator` | `^2.7.0` | Generador de DI |

---

## Backend / Supabase

| Componente | Versión / Especificación |
|-----------|-------------------------|
| **PostgreSQL** | 15+ (versión de Supabase) |
| **Supabase** | 2.x (API) |
| **Edge Runtime** | Deno 2.1.4 (compatible) |
| **Supabase CLI** | `npx supabase` (latest) |

### Edge Functions

| Función | Versión | Descripción |
|---------|---------|-------------|
| `login-custom` | `v4` (actual) | Login con bcrypt |
| `ocr-extract` | `v1` | OCR server con Tesseract.js |

### Dependencias de Edge Functions

| Paquete | URL | Uso |
|---------|-----|-----|
| `std/http` | `https://deno.land/std@0.177.0/http/server.ts` | Servidor HTTP |
| `supabase-js` | `https://esm.sh/@supabase/supabase-js@2.39.3` | Cliente Supabase |
| `bcrypt` (eliminado) | ~~`https://deno.land/x/bcrypt@v0.4.1`~~ | ~~Hashing Deno~~ (no usado) |

---

## Funciones SQL (RPC)

| Función | Descripción | Estado |
|---------|-------------|--------|
| `crear_usuario_bcrypt(...)` | Crea usuario con hash bcrypt | ✅ Activa |
| `validar_login_bcrypt(...)` | Valida login y devuelve usuario | ✅ Activa |
| `cambiar_password_bcrypt(...)` | Cambia contraseña | ✅ Activa |
| `get_usuario_completo_by_username(...)` | Datos del usuario por username | ✅ Activa |
| `verify_usuario_activo_by_username(...)` | Verifica si usuario está activo | ✅ Activa |
| `listar_usuarios_rpc(...)` | Lista usuarios por empresa | ✅ Activa (asumida) |
| `crear_venta_rpc(...)` | Crea nueva venta | 🟡 Pendiente de verificar |
| `obtener_ventas_por_fecha(...)` | Ventas por fecha | 🟡 Pendiente de verificar |
| `desactivar_usuario_rpc(...)` | Desactiva usuario | 🟡 Pendiente de verificar |

---

## Esquema de Base de Datos

| Tabla | Estado | Uso en App |
|-------|--------|-----------|
| `public.roles` | ✅ Existe | Roles de usuario |
| `public.empresas` | ✅ Existe | Datos de empresa |
| `public.usuarios` | ✅ Existe | Usuarios (con `password_hash`) |
| `public.clientes` | ✅ Existe | Clientes |
| `public.categorias` | ✅ Existe | Categorías de productos |
| `public.productos` | ✅ Existe | Productos |
| `public.tipos_transferencia` | ✅ Existe | Tipos de pago (Yape, Plin, etc.) |
| `public.ventas` | ✅ Existe | Ventas registradas |
| `public.venta_productos` | ✅ Existe | Items de cada venta |
| `public.historial_estados` | ✅ Existe | Historial de cambios de estado |
| `public.notificaciones` | ✅ Existe | Notificaciones del sistema |

### Tipos Enumerados (Enums)

| Enum | Valores | Uso |
|------|---------|-----|
| `estado_venta` | `pendiente`, `completado`, `cancelado`, `reembolsado` | Estado de ventas |
| `tipo_notificacion` | `nueva_venta`, `estado_cambiado`, `sync_completado`, `sync_fallido` | Tipos de notificaciones |

---

## APIs Externas

| Servicio | Endpoint | Uso |
|----------|----------|-----|
| **Supabase REST** | `https://[project-ref].supabase.co/rest/v1/` | Queries a PostgreSQL |
| **Supabase Edge Functions** | `https://[project-ref].supabase.co/functions/v1/` | Edge Functions |
| **Google ML Kit** | Local (on-device) | OCR de comprobantes |
| **Tesseract.js** (server) | Via `ocr-extract` Edge Function | OCR server-side |

---

## Versiones del Sistema Operativo Soportadas

| Plataforma | Versión Mínima |
|-----------|----------------|
| **Android** | API 21 (Android 5.0) |
| **iOS** | iOS 12.0 |
| **Web** | Chrome 90+, Firefox 88+, Safari 14+ |

---

## Notas de Compatibilidad

- `supabase_flutter` `2.8.4` es compatible con Dart `3.8.1`
- `google_mlkit_text_recognition` requiere `minSdkVersion 21` en Android
- `workmanager` requiere configuración adicional en Android (`AndroidManifest.xml`)
- `flutter_secure_storage` usa Keychain en iOS y Keystore en Android

---

## Historial de Cambios de Versiones

| Fecha | Cambio | Detalle |
|-------|--------|---------|
| 2026-06-13 | v1.0.0+1 | Login con bcrypt implementado |
| 2026-06-13 | Edge Function v4 | Eliminada sincronización con `auth.users` |
| 2026-06-13 | SQL v2 | Eliminada columna `auth_id`, eliminados triggers |
| Previo | v0.9.0 | Usaba Supabase Auth nativo (JWT) |

---

## Próximas Actualizaciones Planificadas

| Dependencia | Versión Actual | Última Disponible | Notas |
|-------------|----------------|-------------------|-------|
| `flutter_riverpod` | `^2.6.1` | `2.6.1` | Actualizado |
| `supabase_flutter` | `^2.8.4` | `2.8.4` | Actualizado |
| `google_mlkit_text_recognition` | `^0.14.0` | `0.14.0` | Actualizado |
| `go_router` | `^14.8.1` | `14.8.1` | Actualizado |
