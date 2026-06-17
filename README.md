# GuardaYaApp - SaaS de Gestión de Ventas con OCR

> **GuardaYaApp** es un sistema SaaS multitenant para negocios que reciben pagos por **Yape/Plin**. Automatiza el registro de ventas mediante **OCR** y centraliza toda la información, evitando que los negocios pierdan tiempo buscando comprobantes en WhatsApp.

---

## Arquitectura del Proyecto

### Stack Tecnológico

| Componente | Tecnología | Razón |
|---|---|---|
| **Backend** | Supabase (PostgreSQL) | Auth custom, Base de datos, Storage, Realtime |
| **State Management** | Flutter Riverpod | Reactivo, testeable, integra bien con Clean Architecture |
| **OCR** | Google ML Kit (local) + Supabase Edge Function (remoto) | Offline funcional + Precisión online |
| **Offline** | SQLite (`sqflite`) + `connectivity_plus` | Cache de ventas críticas cuando no hay internet |
| **Imágenes** | `image_picker` + Supabase Storage | Captura + almacenamiento en la nube |
| **Routing** | `go_router` | Navegación declarativa + Deep links |
| **Sync** | `workmanager` | Sincronización en background de ventas pendientes |

### Arquitectura de Capas (Clean Architecture)

```
lib/
├── core/                          # Capa transversal
│   ├── constants/
│   ├── errors/
│   ├── usecases/
│   ├── utils/
│   └── theme/
├── data/                          # Capa de datos
│   ├── datasources/
│   │   ├── local/                 # SQLite (offline)
│   │   │   └── supabase_local_cache.dart
│   │   └── remote/                # Supabase Client
│   │       ├── supabase_client.dart
│   │       ├── auth_datasource.dart
│   │       ├── ventas_datasource.dart
│   │       ├── ocr_datasource.dart
│   │       └── ...
│   ├── models/                    # DTOs para Supabase
│   └── repositories/
│       └── implementations/
├── domain/                        # Capa de dominio
│   ├── entities/                  # Entidades puras del negocio
│   ├── repositories/              # Contratos (abstractos)
│   └── usecases/                  # Casos de uso
│       ├── ventas/
│       ├── clientes/
│       └── auth/
├── presentation/                  # Capa de UI
│   ├── providers/                 # Riverpod Providers
│   ├── pages/                     # Pantallas
│   └── widgets/                   # Componentes reutilizables
└── services/                      # Servicios transversales
    ├── supabase_service.dart
    ├── ocr_service.dart
    ├── connectivity_service.dart
    └── notification_service.dart
```

---

## Estrategia Offline (Online-First + Offline Fallback)

### Contexto
Los negocios en Perú (mercados, puestos, delivery) operan en zonas con **señal de internet intermitente**. La app debe permitir que el cajero registre una venta aunque no haya WiFi.

### Arquitectura

```
┌─────────────────────────────────────────────────────┐
│                   APP GUARDAYA                        │
├─────────────────────────────────────────────────────┤
│  1. Intentar guardar en Supabase (Online)           │
│     ↓                                               │
│  2. Si falla por red → Guardar en SQLite (Offline)  │
│     ↓                                               │
│  3. Cuando vuelve internet → Sync automático        │
│     ↓                                               │
│  4. Marcar como "Sincronizado" y borrar de SQLite   │
└─────────────────────────────────────────────────────┘
```

### Tablas SQLite Locales (Solo del Móvil)

> **Nota:** Estas tablas existen únicamente en la base de datos local del teléfono (`sqflite`), **NO** en Supabase.

```sql
-- Tabla principal de ventas pendientes
CREATE TABLE pending_ventas (
    id TEXT PRIMARY KEY,              -- UUID generado localmente
    empresa_id TEXT NOT NULL,
    usuario_id TEXT NOT NULL,
    cliente_id TEXT,
    codigo_yape TEXT,
    monto REAL NOT NULL,
    cliente_nombre TEXT,
    cliente_telefono TEXT,
    fecha_yape TEXT,                  -- ISO8601 string
    descripcion TEXT,
    estado TEXT DEFAULT 'pendiente',
    imagen_yape_local_path TEXT,      -- Path del archivo local
    imagen_entrega_local_path TEXT,
    created_at TEXT,                  -- ISO8601 string
    sync_status TEXT DEFAULT 'pending', -- pending, syncing, synced, error
    sync_error TEXT,                  -- Mensaje de error si falla
    retry_count INTEGER DEFAULT 0
);

-- Tabla de productos asociados a la venta pendiente
CREATE TABLE pending_venta_productos (
    id TEXT PRIMARY KEY,
    pending_venta_id TEXT NOT NULL,
    producto_id TEXT,
    nombre TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario REAL NOT NULL,
    subtotal REAL,
    FOREIGN KEY (pending_venta_id) REFERENCES pending_ventas(id)
);

-- Tabla de cache de ventas ya sincronizadas (para búsquedas rápidas sin internet)
CREATE TABLE cache_ventas (
    id TEXT PRIMARY KEY,
    empresa_id TEXT NOT NULL,
    cliente_nombre TEXT,
    cliente_telefono TEXT,
    codigo_yape TEXT,
    monto REAL,
    estado TEXT,
    created_at TEXT,
    updated_at TEXT
    -- Datos mínimos para búsqueda y listado rápido
);
```

### Flujo de Registro de Venta

```
┌─────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│  Usuario    │────▶│  Toma foto Yape     │────▶│  OCR (ML Kit)    │
│  Abre App   │     │  o selecciona imagen │     │  Extrae datos    │
└─────────────┘     └─────────────────────┘     └──────────────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────────┐
│  PASO 1: Verificar conectividad (connectivity_plus)         │
│  ├─ Si hay internet: Intentar INSERT en Supabase            │
│  │   ├─ Éxito: Mostrar "Venta registrada"                   │
│  │   └─ Error: Caer a SQLite                                │
│  └─ Si NO hay internet: Guardar directamente en SQLite      │
│      └─ Mostrar "Venta guardada. Se sincronizará al conectar"│
└─────────────────────────────────────────────────────────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────────┐
│  PASO 2: Si se guardó en SQLite, subir imagen a Storage     │
│  cuando haya internet (prioridad baja)                      │
│  ├─ Imagen Yape → Supabase Storage bucket 'comprobantes'    │
│  ├─ Imagen Entrega → Supabase Storage bucket 'entregas'     │
│  └─ Actualizar URL en Supabase después de subir             │
└─────────────────────────────────────────────────────────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────────┐
│  PASO 3: Sync Worker (Background)                           │
│  ├─ Se activa cada 5 minutos o cuando detecta conexión      │
│  ├─ Lee pending_ventas WHERE sync_status = 'pending'        │
│  ├─ Intenta INSERT en Supabase tabla 'ventas'               │
│  ├─ Si éxito: Mover a cache_ventas, borrar de pending      │
│  └─ Si error: retry_count++, si > 3 → sync_status = 'error'│
└─────────────────────────────────────────────────────────────┘
```

### Lógica de Conflictos

| Escenario | Solución |
|---|---|
| **ID duplicado** | El UUID es v4, estadísticamente imposible. Si ocurre, el worker intenta UPDATE en lugar de INSERT. |
| **Imagen no sube** | Se guarda la venta con `imagen_yape_url = null`. Se intenta subir imagen en segundo plano. |
| **Usuario cierra app antes de sync** | SQLite es persistente. El sync worker se ejecuta al abrir la app nuevamente. |
| **Dos cajas offline venden al mismo cliente** | No hay conflicto porque son ventas diferentes. GuardaYa es **append-only** (ventas no se editan, solo cambian de estado). |

---

## Estrategia OCR Dual

### Contexto
Los comprobantes de Yape/Plin tienen fondos de colores (amarillo, morado) y formatos que pueden confundir a un OCR genérico. Por eso usamos dos modos:

### Modo 1: Offline (Google ML Kit)
- Funciona **sin internet**.
- Rápido (procesa localmente en el celular).
- Menos preciso. El usuario puede corregir antes de guardar.
- Extrae texto crudo y la app aplica **regex locales** para parsear Yape.

### Modo 2: Online (Supabase Edge Function)
- Se ejecuta en el servidor de Supabase (Free tier: 500,000 invocaciones/mes).
- Más preciso porque se puede usar **Google Vision API** o **Tesseract** con pre-procesamiento de imagen.
- Permite entrenar el parsing con regex específicos para comprobantes peruanos.

### Flujo del OCR

```
1. App toma foto del comprobante
   └─ Guarda localmente (File temp)

2. ¿Hay internet?
   ├─ SÍ: Subir a Supabase Storage (bucket 'ocr-temp')
   │   └─ Obtener URL pública
   │   └─ Llamar Edge Function: POST /ocr-extract
   │       Body: { image_url: "..." }
   │       └─ Respuesta: { codigo: "123456",
   │                       monto: 150.00,
   │                       fecha: "2026-06-09",
   │                       confianza: 0.95 }
   │
   └─ NO: Usar ML Kit localmente
       └─ Extraer texto crudo
       └─ App aplica regex propios para parsear Yape
       └─ Mostrar datos con baja confianza (usuario corrige)

3. App muestra previsualización con datos extraídos
   └─ Usuario confirma o corrige manualmente

4. App guarda la venta (con imagen y datos corregidos)
```

### Regex Específicos para Comprobantes Peruanos

| Campo | Patrón común en Yape/Plin |
|---|---|
| **Código de operación** | `Código de operación: 12345678` o `N° Operación: 123456` |
| **Monto** | `S/ 150.00` o `S/. 150.00` |
| **Fecha/Hora** | `09/06/2026 14:30:23` |
| **Nombre del destinatario** | `Pago a: Juan Perez` |

---

## Esquema de Base de Datos

### Supabase (PostgreSQL) - Backend Central

> **Tablas oficiales del SaaS.** Todos los datos reales del negocio viven aquí.

```sql
-- Roles del sistema
CREATE TABLE public.roles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre character varying NOT NULL UNIQUE,
  descripcion text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);

-- Empresas (Tenants)
CREATE TABLE public.empresas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre character varying NOT NULL,
  slug character varying NOT NULL UNIQUE,
  email_contacto character varying,
  telefono character varying,
  direccion text,
  ruc_dni character varying,
  logo_url text,
  plan character varying NOT NULL DEFAULT 'basico',
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT empresas_pkey PRIMARY KEY (id)
);

-- Usuarios (Auth custom con bcrypt)
CREATE TABLE public.usuarios (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  empresa_id uuid,
  username character varying NOT NULL UNIQUE,
  nombre character varying NOT NULL,
  email character varying,
  password_hash character varying NOT NULL,
  rol_id uuid NOT NULL,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT usuarios_pkey PRIMARY KEY (id),
  CONSTRAINT usuarios_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT usuarios_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.roles(id)
);

-- Clientes
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

-- Categorías de productos
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

-- Productos
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

-- Tipos de transferencia (Yape, Plin, etc.)
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

-- Ventas (El núcleo del sistema)
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
  estado USER-DEFINED NOT NULL DEFAULT 'pendiente',
  imagen_yape_url text,
  imagen_entrega_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ventas_pkey PRIMARY KEY (id),
  CONSTRAINT ventas_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id),
  CONSTRAINT ventas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id),
  CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id)
);

-- Productos de una venta (desglose)
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

-- Historial de cambios de estado
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

-- Notificaciones
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
```

---

## Relación de Tablas: Supabase vs SQLite

| Tabla | Supabase (PostgreSQL) | SQLite Local (Móvil) |
|---|---|---|
| `roles` | ✅ Tabla maestra | ❌ No necesario |
| `empresas` | ✅ Tabla maestra | ❌ Solo cache en memoria (del usuario logueado) |
| `usuarios` | ✅ Tabla maestra | ❌ Solo cache del usuario logueado (secure storage) |
| `clientes` | ✅ Tabla maestra | ✅ Parcial (cache de búsqueda rápida) |
| `categorias` | ✅ Tabla maestra | ✅ Parcial (cache para registro de venta) |
| `productos` | ✅ Tabla maestra | ✅ Parcial (cache para registro de venta) |
| `tipos_transferencia` | ✅ Tabla maestra | ✅ Parcial (cache) |
| `ventas` | ✅ **Tabla real del negocio** | ✅ `cache_ventas` (copia mínima) + `pending_ventas` (fallback offline) |
| `venta_productos` | ✅ **Tabla real del negocio** | ✅ `pending_venta_productos` (fallback offline) |
| `historial_estados` | ✅ **Tabla real del negocio** | ❌ No necesario en local |
| `notificaciones` | ✅ **Tabla real del negocio** | ❌ No necesario en local |

---

## Autenticación

> **GuardaYa usa autenticación custom**, NO el sistema nativo de Supabase Auth.

### Flujo

1. Usuario ingresa `username` y `password` en la app.
2. La app llama a un **RPC** de PostgreSQL o a una **Edge Function** de Supabase.
3. La función busca en `usuarios` el `username`, obtiene `password_hash`.
4. La función usa **bcrypt** para comparar la contraseña ingresada con el hash.
5. Si es válido, la función retorna un **JWT custom** con `user_id`, `empresa_id`, `rol_id`.
6. La app guarda el JWT en `flutter_secure_storage`.
7. En cada request, el JWT se envía en headers para identificar al usuario y su empresa (multitenant).

### ¿Por qué no Supabase Auth nativo?
- Tu esquema ya tiene `usuarios` con `password_hash` y `bcrypt`.
- Necesitas vincular directamente cada request con `empresa_id` (multitenant).
- El `username` es único global y ligado a tu propia tabla de roles.

---

## Plan de Implementación

### Fase 1: Base Técnica
1. Configurar `pubspec.yaml` con todas las dependencias.
2. Crear la estructura de carpetas (Clean Architecture).
3. Configurar `supabase_flutter` con URL y anon key.
4. Crear el sistema de autenticación custom (login contra tabla `usuarios` con bcrypt).
5. Crear el tema visual y colores base.

### Fase 2: Módulo de Ventas (Core)
1. Crear modelos de `Venta`, `Producto`, `Cliente`, `VentaProducto`.
2. Crear datasources y repositories para ventas.
3. Implementar OCR dual (ML Kit local + Edge Function remota).
4. Crear pantalla de **Registrar Venta** (foto + OCR + corrección + guardar).
5. Crear pantalla de **Buscar Venta** (por código Yape, por teléfono, por nombre).
6. Crear pantalla de **Detalle de Venta** (cambiar estado, ver imagen, marcar entrega).

### Fase 3: Offline y Sync
1. Implementar SQLite local con `sqflite`.
2. Implementar `connectivity_service` para detectar offline.
3. Crear lógica de "guardar local si offline, sync cuando online".
4. Implementar cache de búsquedas recientes.

### Fase 4: Módulos Adicionales
1. **Clientes**: Crear y listar clientes.
2. **Productos**: CRUD de productos (solo admin).
3. **Notificaciones**: Notificaciones push cuando cambia el estado de una venta.
4. **Dashboard**: Resumen de ventas del día (solo admin).

### Fase 5: Supabase Backend
1. Crear Edge Function para OCR remoto.
2. Crear RPC functions para lógica compleja (`login_usuario`, `buscar_ventas`).
3. Configurar Storage buckets para imágenes de comprobantes (`comprobantes`) y entregas (`entregas`).
4. Implementar triggers para `historial_estados` y notificaciones.

---

## Notas Importantes

- **No uses `supabase.auth.signIn()`**: GuardaYa usa su propia tabla `usuarios` con bcrypt.
- **RLS**: Las Row Level Security policies de Supabase deben filtrar por `empresa_id` en cada request.
- **Imágenes**: Las fotos de comprobantes se almacenan en `Supabase Storage` (bucket `comprobantes`). Las de entregas en bucket `entregas`.
- **Sync**: Usa `workmanager` para ejecutar el sync de ventas pendientes en background, incluso si la app está cerrada.
- **UUID**: Todos los IDs (incluso en SQLite local) usan el formato UUID v4 para evitar colisiones entre cajas offline.

---

## Monorepo: Estructura del Proyecto

Este repositorio usa **monorepo** (múltiples proyectos en un solo repo):

```
GuardaYaApp_Mobile/
├── lib/                    # App Flutter (Frontend)
├── pubspec.yaml
├── .env                    # Variables de entorno del Flutter
├── supabase/               # Backend (Supabase)
│   ├── functions/
│   │   └── ocr-extract/    # Edge Function OCR
│   │       └── index.ts
│   └── config.toml         # Configuración Supabase CLI
└── README.md
```

### Credenciales: ¿Qué va dónde?

| Credencial | ¿Dónde se usa? | ¿Va en el repo? |
|---|---|---|
| `SUPABASE_URL` | Flutter + Edge Function | ✅ Sí (pública) |
| `SUPABASE_ANON_KEY` | Flutter (app móvil) | ✅ Sí, con RLS |
| `SUPABASE_SECRET_KEY` | Edge Functions (backend) | ❌ **NO** - solo en Supabase Dashboard |

**Nota:** El Edge Function `ocr-extract` usa `SUPABASE_SERVICE_ROLE_KEY` automáticamente desde el entorno de Supabase. No necesitas configurarla manualmente.

---

## Licencia

Proyecto privado - GuardaYaApp.
