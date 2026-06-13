# Roadmap - Estado del Proyecto

## Resumen de Progreso

| Módulo | Estado | Progreso |
|--------|--------|----------|
| **Autenticación** | ✅ Completado | 100% |
| **Arquitectura Base** | ✅ Completado | 100% |
| **Base de Datos** | ✅ Completado | 100% |
| **Modo Offline** | ✅ Completado | 100% |
| **OCR (Local)** | ✅ Completado | 100% |
| **Registrar Venta** | ✅ Completado | 100% |
| **Gestión de Empleados** | ✅ Completado | 100% |
| **Home / Dashboard** | ✅ Completado | 100% |
| **Listar Ventas** | 🟡 Placeholder | 20% |
| **Buscar Ventas** | 🟡 Placeholder | 20% |
| **Detalle Venta** | 🟡 Placeholder | 20% |
| **Productos** | ❌ No iniciado | 0% |
| **Clientes** | ❌ No iniciado | 0% |
| **Perfil** | ❌ No iniciado | 0% |
| **Reportes** | ❌ No iniciado | 0% |
| **OCR Server** | 🟡 Función existe | 50% |
| **Notificaciones** | ❌ No iniciado | 0% |
| **PDF/Comprobantes** | ❌ No iniciado | 0% |

**Progreso Total Estimado: ~55%**

---

## Módulos Completados ✅

### 1. Autenticación (100%)
- [x] Login con bcrypt (Edge Function + PostgreSQL)
- [x] Sistema de roles (super_admin, admin, empleado)
- [x] Creación de usuarios con bcrypt
- [x] Sesión local (SecureStorage, sin JWT)
- [x] Logout
- [x] Verificación offline de usuario activo
- [x] Recuperación de sesión al iniciar app

### 2. Arquitectura (100%)
- [x] Clean Architecture (Domain / Data / Presentation)
- [x] Repository Pattern (5 repositorios implementados)
- [x] UseCase Pattern (12 casos de uso)
- [x] Manejo de errores con Either (fpdart)
- [x] State Management con Riverpod
- [x] Navegación con GoRouter
- [x] Inyección de dependencias

### 3. Base de Datos (100%)
- [x] Tablas: usuarios, empresas, roles, ventas, productos, clientes
- [x] Funciones SQL: bcrypt login, crear usuario, cambiar password
- [x] Edge Function: login-custom
- [x] Edge Function: ocr-extract
- [x] Relaciones entre tablas
- [x] Índices y constraints

### 4. Modo Offline (100%)
- [x] SQLite local (ventas pendientes)
- [x] SecureStorage (datos de usuario)
- [x] Connectivity monitoring
- [x] WorkManager (background sync)
- [x] Retry logic (10 intentos)
- [x] Offline banner UI
- [x] Sincronización automática

### 5. OCR Local (100%)
- [x] Google ML Kit Text Recognition
- [x] Regex para Yape/Plin (Perú)
- [x] Extracción: código, monto, fecha, hora, destinatario
- [x] Cálculo de confianza
- [x] Integración en flujo de venta

### 6. Registrar Venta (100%)
- [x] Wizard de 6 pasos
- [x] Cámara y galería
- [x] OCR automático en paso 2
- [x] Selección de productos
- [x] Cálculo de totales
- [x] Guardado en SQLite (offline)
- [x] UI responsive

### 7. Gestión de Empleados (100%)
- [x] Listar empleados (pull-to-refresh)
- [x] Crear empleado (validación)
- [x] Dropdown de roles
- [x] Dropdown de empresas
- [x] super_admin sin empresa

### 8. Home / Dashboard (100%)
- [x] Vista por rol (SuperAdmin, Admin, Empleado)
- [x] Tarjetas de navegación
- [x] Indicador offline
- [x] Theme (dark/light)

---

## Módulos En Progreso 🟡

### 9. Listar Ventas (20%)
**Estado:** Página placeholder creada, no muestra datos

**Falta:**
- [ ] Integrar VentasProvider con repositorio
- [ ] UI de lista con cards
- [ ] Filtros por fecha
- [ ] Filtros por estado
- [ ] Paginación o scroll infinito
- [ ] Pull-to-refresh
- [ ] Caché offline

**Tiempo estimado:** 2-3 días

### 10. Buscar Ventas (20%)
**Estado:** Página placeholder creada

**Falta:**
- [ ] Formulario de búsqueda
- [ ] Búsqueda por código OCR
- [ ] Búsqueda por teléfono de cliente
- [ ] Búsqueda por rango de fechas
- [ ] Resultados con highlight
- [ ] Empty state

**Tiempo estimado:** 1-2 días

### 11. Detalle Venta (20%)
**Estado:** Muestra solo el ID

**Falta:**
- [ ] Mostrar datos completos de la venta
- [ ] Mostrar imagen del comprobante
- [ ] Cambiar estado (pendiente → completado)
- [ ] Editar venta
- [ ] Eliminar venta
- [ ] Ver cliente
- [ ] Compartir comprobante

**Tiempo estimado:** 2-3 días

### 12. OCR Server (50%)
**Estado:** Edge Function existe pero no se usa desde la app

**Falta:**
- [ ] Subir imagen a Supabase Storage
- [ ] Llamar a ocr-extract desde la app
- [ ] Fallback: OCR local primero, server como respaldo
- [ ] Procesar respuesta del servidor

**Tiempo estimado:** 1-2 días

---

## Módulos No Iniciados ❌

### 13. Productos (0%)
**Prioridad:** Alta (se usa en registrar venta)

**Tareas:**
- [ ] Página de lista de productos
- [ ] Crear producto (nombre, precio, stock)
- [ ] Editar producto
- [ ] Eliminar producto (soft delete)
- [ ] Categorías de productos
- [ ] Búsqueda de productos
- [ ] Provider de productos
- [ ] Caché offline

**Tiempo estimado:** 3-4 días

### 14. Clientes (0%)
**Prioridad:** Alta (se usa en registrar venta)

**Tareas:**
- [ ] Página de lista de clientes
- [ ] Crear cliente (nombre, teléfono, email)
- [ ] Editar cliente
- [ ] Ver historial de compras del cliente
- [ ] Búsqueda de clientes
- [ ] Provider de clientes
- [ ] Selección rápida en venta

**Tiempo estimado:** 2-3 días

### 15. Perfil de Usuario (0%)
**Prioridad:** Media

**Tareas:**
- [ ] Mostrar datos del usuario
- [ ] Editar perfil (nombre, teléfono, email)
- [ ] Cambiar contraseña
- [ ] Cambiar tema (dark/light)
- [ ] Notificaciones
- [ ] Cerrar sesión

**Tiempo estimado:** 1-2 días

### 16. Reportes y Analytics (0%)
**Prioridad:** Media (diferenciador del producto)

**Tareas:**
- [ ] Dashboard de ventas diarias/semanales/mensuales
- [ ] Gráficos de barras (fl_chart)
- [ ] Top productos vendidos
- [ ] Ventas por empleado
- [ ] Ventas por hora/día
- [ ] Exportar a CSV/PDF
- [ ] Filtros por fecha y empresa

**Tiempo estimado:** 5-7 días

### 17. Notificaciones (0%)
**Prioridad:** Baja

**Tareas:**
- [ ] Push notifications (Firebase)
- [ ] Notificación de venta sincronizada
- [ ] Notificación de venta fallida
- [ ] Recordatorio de sync pendiente

**Tiempo estimado:** 2-3 días

### 18. PDF y Comprobantes (0%)
**Prioridad:** Media

**Tareas:**
- [ ] Generar PDF de comprobante
- [ ] Compartir PDF (WhatsApp, Email)
- [ ] Imprimir comprobante
- [ ] Template de comprobante con branding

**Tiempo estimado:** 2-3 días

### 19. Gestión de Empresas (0%)
**Prioridad:** Media (solo para super_admin)

**Tareas:**
- [ ] CRUD de empresas
- [ ] Configuración de colores (branding)
- [ ] Logo de empresa
- [ ] Asignar admins a empresas

**Tiempo estimado:** 2-3 días

---

## Plan de Desarrollo Sugerido

### Fase 1: Completar el Core (2-3 semanas)
Prioridad: Hacer que la app sea usable para el flujo principal

1. **Productos** (3-4 días)
2. **Clientes** (2-3 días)
3. **Listar Ventas** (2-3 días)
4. **Detalle Venta** (2-3 días)
5. **Buscar Ventas** (1-2 días)
6. **Integrar OCR Server** (1-2 días)

**Resultado:** App completamente funcional para registrar, listar, buscar y ver ventas.

### Fase 2: Mejoras y UX (1-2 semanas)
1. **Perfil de Usuario** (1-2 días)
2. **Reportes básicos** (3-4 días)
3. **PDF/Comprobantes** (2-3 días)
4. **Polish UI** (2-3 días)

**Resultado:** App profesional lista para presentar a clientes.

### Fase 3: Escalar (2-3 semanas)
1. **Gestión de Empresas** (2-3 días)
2. **Notificaciones** (2-3 días)
3. **Reportes avanzados** (3-4 días)
4. **Testing y QA** (3-5 días)

**Resultado:** MVP completo para producción.

---

## Métricas de Completitud

### Por Capa

| Capa | Progreso |
|------|----------|
| **Domain** (Entidades, UseCases, Repos) | 95% |
| **Data** (Models, Repos Impl, Datasources) | 90% |
| **Presentation** (Pages, Providers) | 45% |
| **Backend** (SQL, Edge Functions) | 90% |
| **Infraestructura** (Offline, OCR, Sync) | 100% |

### Por Flujo de Usuario

| Flujo | Progreso |
|-------|----------|
| **Login** → Home | 100% |
| **Home** → Registrar Venta | 100% |
| **Registrar Venta** → Guardar | 100% |
| **Home** → Listar Ventas | 20% |
| **Home** → Buscar Ventas | 20% |
| **Home** → Gestión Empleados | 100% |
| **Home** → Productos | 0% |
| **Home** → Clientes | 0% |
| **Home** → Reportes | 0% |

---

## Próximo Paso Inmediato

**Recomendación:** Comenzar con **Productos** porque:
1. Ya se usa en "Registrar Venta" (select de productos)
2. Es una tabla fundamental para el negocio
3. El repositorio y datasource ya existen (solo falta UI y provider)
4. Es rápido de implementar (2-3 días)

**Segundo:** Clientes (misma razón)

**Tercero:** Listar Ventas (completar el flujo de ventas)

---

## Estado de Tests

- [ ] Unit tests (no implementados)
- [ ] Widget tests (no implementados)
- [ ] Integration tests (no implementados)

**Nota:** La arquitectura Clean facilita agregar tests posteriormente.

---

## Deuda Técnica

1. **auth_provider.dart** usa `AuthRepositoryImpl(AuthDatasource())` directamente en lugar de provider (línea 111)
2. **ventas_provider.dart** tiene `UnimplementedError` en todos los métodos
3. **Crear usuario temp** es una página de desarrollo, debe eliminarse en producción
4. **OCR local** usa regex hardcodeado para Perú, no es configurable por país
5. **No hay manejo de conflictos** en sync offline (última escritura gana)

---

## Conclusión

La app tiene una **base sólida y bien arquitectada**. El 55% restante es principalmente **UI y Presentation** (lo más rápido de desarrollar). Con dedicación de tiempo completo, el MVP podría estar listo en **4-6 semanas**.

El flujo crítico (login → registrar venta → guardar offline) ya funciona. El siguiente objetivo es hacer que el usuario pueda **ver, buscar y gestionar** esas ventas.
