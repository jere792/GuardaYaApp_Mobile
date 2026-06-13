# Enfoque del Proyecto

## Declaración de Visión

**GuardaYa es un SaaS de gestión de ventas diseñado para el comercio informal en Latinoamérica, que usa OCR para digitalizar comprobantes de pago (Yape/Plin) y funciona sin conexión a internet.**

## Principios de Diseño

### 1. Offline-First

**El internet no es un lujo, es una intermitencia.**

La app está diseñada para funcionar 100% sin internet:
- SQLite local almacena ventas, productos, clientes
- El usuario no nota cuando pierde conexión
- Sincronización automática en segundo plano cuando vuelve el internet
- WorkManager maneja la sincronización sin que el usuario intervenga

**Regla:** *Si una función requiere internet obligatorio, se replantea o se adapta.*

### 2. Simplicidad Radical

**El usuario promedio no es tecnólogo.**

- No se requiere correo electrónico (solo username)
- No hay contraseñas complejas (pero sí bcrypt en el servidor)
- No hay términos técnicos en la UI
- El flujo de venta es: Foto → Confirmar → Listo
- No hay configuraciones innecesarias

**Regla:** *Si una función necesita un manual, está mal diseñada.*

### 3. Control del Negocio

**El dueño debe entender todo sin ayuda.**

- Dashboard claro: Ventas de hoy, semana, mes
- Cada empleado ve solo lo que le corresponde
- El dueño (super_admin) ve todo
- No hay magia oculta: cada venta tiene un comprobante, un código, un monto

### 4. Arquitectura Limpia

**El código debe ser mantenible por cualquier desarrollador Flutter.**

- Clean Architecture: separación clara de responsabilidades
- Domain-Driven Design: el lenguaje del código es el lenguaje del negocio
- Cada feature tiene su propia capa (Domain, Data, Presentation)
- Testing es posible en cada capa por separado

### 5. Autenticación Propia

**No dependemos de servicios de terceros para algo tan crítico.**

- Supabase Auth es reemplazado por bcrypt en PostgreSQL
- Control total sobre el flujo de login
- No hay tokens JWT que expiran misteriosamente
- No hay correos que no se entregan
- Sesión manejada localmente con SecureStorage

**Regla:** *Si Supabase desaparece mañana, el login debe seguir funcionando.*

### 6. SaaS Multi-Empresa

**Un sistema, muchos negocios.**

- Cada empresa tiene sus productos, precios, colores, empleados
- Un super_admin puede ver todas las empresas
- El plan freemium permite una empresa gratis
- Planes pagos permiten múltiples empresas

---

## Arquitectura Técnica

### Decisiones Clave

| Decisión | Justificación |
|----------|---------------|
| **Flutter** (multiplataforma) | Una sola codebase para Android, iOS, Web |
| **Supabase** (PostgreSQL + Edge Functions) | Backend sin servidor, escalable, económico |
| **Riverpod** (estado) | Simple, testable, reactivo |
| **Go Router** (navegación) | Declarativo, tipado, compatible con web |
| **SQLite** (offline) | Nativo, rápido, no requiere internet |
| **bcrypt** (PostgreSQL) | Hashing probado, nativo en PostgreSQL, sin dependencias |
| **Google ML Kit** (OCR) | On-device, no sube imágenes a internet, gratis |
| **Edge Functions** (server) | Código del servidor junto al código de la app, versionado en Git |

### Flujo de Datos

```
┌──────────────────────────────────────────────────────────┐
│                    USUARIO (Celular)                       │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Tomar foto  │  │ OCR local    │  │ Guardar venta    │  │
│  │ comprobante │  │ (ML Kit)     │  │ (SQLite offline) │  │
│  └─────────────┘  └──────────────┘  └──────────────────┘  │
└──────────────────────────────────────────────────────────┘
                              │
                              │ Sync cuando hay internet
                              ▼
┌──────────────────────────────────────────────────────────┐
│                    SUPABASE (PostgreSQL)                   │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Tablas: usuarios, empresas, ventas, productos,     │ │
│  │  clientes, historial, notificaciones                 │ │
│  │                                                     │ │
│  │  Funciones: bcrypt, validación, listados,           │ │
│  │  obtención de datos                                  │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                              │
                              │ Edge Functions
                              ▼
┌──────────────────────────────────────────────────────────┐
│                    SERVERLESS (Deno)                       │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  login-custom: Valida bcrypt contra public.usuarios │ │
│  │  ocr-extract: OCR server-side con Tesseract.js      │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

### Capas de la App

```
Domain Layer (Lógica de negocio pura)
    ├── Entities (Usuario, Venta, Producto)
    ├── Repositories (Interfaces)
    └── Use Cases (Login, Registrar Venta, etc.)

Data Layer (Implementación técnica)
    ├── Models (DTOs: JSON ↔ Entity)
    ├── Datasources (Supabase, SQLite, Storage)
    └── Repositories (Implementaciones)

Presentation Layer (Interfaz de usuario)
    ├── Pages (Login, Home, Ventas)
    ├── Providers (Riverpod)
    └── Widgets (Componentes reutilizables)
```

---

## Estrategia de Producto

### MVP (Fase 1)
- Login con bcrypt
- Registrar venta con OCR
- Listar ventas
- Modo offline

### Beta (Fase 2)
- Gestión de productos
- Gestión de clientes
- Dashboard con gráficos
- Perfil de usuario

### Producción (Fase 3)
- Reportes avanzados (PDF, Excel)
- Notificaciones push
- Multi-sucursal
- WhatsApp Business API
- Planes de suscripción

---

## Estrategia de Tecnología

### Qué usamos
- ✅ Flutter (multiplataforma)
- ✅ PostgreSQL (datos estructurados)
- ✅ Edge Functions (lógica de servidor)
- ✅ SQLite (offline)
- ✅ bcrypt (hashing)
- ✅ ML Kit (OCR local)

### Qué NO usamos
- ❌ Supabase Auth (demasiado complejo para nuestro caso)
- ❌ JWT (no queremos tokens que expiran)
- ❌ Firebase Auth (misma razón)
- ❌ MongoDB (no necesitamos NoSQL)
- ❌ Redux (Riverpod es más simple)
- ❌ Clean Architecture "pura" (adaptamos para Flutter)
- ❌ Correo electrónico obligatorio (no todos tienen email)

---

## Estrategia de Negocio

### Modelo de Ingresos

| Plan | Precio | Características |
|------|--------|----------------|
| **Gratis** | S/ 0 | 1 empresa, 1 empleado, 100 ventas/mes |
| **Básico** | S/ 29/mes | 1 empresa, 3 empleados, ventas ilimitadas |
| **Pro** | S/ 79/mes | 3 empresas, 10 empleados, reportes avanzados |
| **Enterprise** | S/ 199/mes | Empresas ilimitadas, soporte prioritario, API |

### Ventaja Competitiva

1. **Solo app que hace OCR de Yape/Plin** en el mercado peruano
2. **Funciona sin internet** (la única en su categoría)
3. **No requiere email** (accesible para comercio informal)
4. **SaaS multi-empresa** (un dueño con múltiples negocios)

### Target Market

- **Primario:** Bodegas, tiendas de barrio, mercados (Perú, Colombia, México)
- **Secundario:** Tiendas de Instagram, vendedores informales, delivery
- **Terciario:** Pequeños restaurantes, ferias, eventos

---

## Métricas de Calidad Técnica

| Métrica | Objetivo | Cómo medir |
|---------|----------|------------|
| **Tiempo de build** | < 5 minutos | `flutter build` |
| **Cobertura de tests** | > 60% | `flutter test --coverage` |
| **Tiempo de login** | < 2 segundos | Stopwatch en app |
| **Tiempo de OCR** | < 3 segundos | Stopwatch en app |
| **Disponibilidad offline** | 100% | Tests sin internet |
| **Tamaño de app** | < 50 MB | `flutter build apk` |
| **Errores de crash** | < 0.1% | Firebase Crashlytics |

---

## Conclusión

GuardaYa no es un ERP. No es un sistema de facturación. Es un **cajero digital para el comercio informal**.

El enfoque es claro:
- **Offline-first** (funciona sin internet)
- **OCR-first** (lee comprobantes automáticamente)
- **Simple-first** (5 minutos de setup, no necesita manual)
- **Control-first** (el dueño sabe todo, siempre)

La tecnología es un medio, no un fin. El objetivo es que **Doña María, Carlos y Pedro** tengan control de sus ventas sin ser ingenieros.
