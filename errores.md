# Manejo de Offline en GuardaYa

## ¿Qué funciona en offline?

### ✅ Registrar Ventas
- Se guarda en SQLite local como `pending_ventas`.
- Aparece un toast: *"Venta guardada localmente. Se sincronizará cuando haya internet."*
- En segundo plano, WorkManager intenta sincronizar cada 5 minutos (cuando hay conexión).

### ✅ Autenticación
- Permite hasta **7 días** de uso offline sin reconfirmar con el servidor.
- Usa `SecureStorage` para mantener la sesión local.

### ✅ Indicadores visuales
- **HomePage**: Banner amarillo *"Modo sin conexión. Las ventas se guardarán localmente."*
- **HomePage**: Chip naranja con ícono `wifi_off` + texto "Offline".
- **RegistrarVentaPage**: Chip naranja "Offline" en AppBar.
- **VentasListPage**: Mensaje naranja al final del listado cuando hay datos locales pendientes.

### ✅ Pasos de venta offline
- **Paso 3 (Cliente)**: Muestra mensaje *"Sin conexión a internet. Para asignar un cliente, conéctate a internet o continúa sin asignar uno."* en vez del buscador.
- **Paso 4 (Producto)**: Muestra mensaje *"Sin conexión a internet. Para agregar productos, conéctate a internet o continúa sin agregar."* en vez del buscador.

---

## ¿Qué NO funciona en offline?

### ❌ Catálogos (Productos, Clientes, Categorías)
- No hay caché local. Falla inmediatamente con `ServerFailure`.
- El usuario no puede consultar productos ni clientes para armar una venta.

### ❌ Búsqueda de ventas por código/teléfono/nombre
- Solo busca en remoto. La búsqueda combinada (remoto + local) solo existe en `VentasProvider.buscarVentas()`.

### ❌ Login
- No verifica conectividad antes de intentar la llamada API.
- Puede dar timeout largo antes de mostrar error.

### ❌ Crear Cliente / Producto desde Registrar Venta
- Los botones se ocultan cuando no hay internet y se muestra un mensaje offline.

---

## Fixes aplicados

### ✅ Sync MANUAL (ya no automático)
- **`main.dart`**: Eliminado `SyncService.registerPeriodicSync()` — ya no hay sync automático cada 5 minutos.
- **`ventas_provider.dart`**: Agregado `syncPendingVentas()` que sincroniza todas las ventas locales pendientes bajo demanda.
- **`VentasListPage`**: Banner azul con botón **"Sincronizar"** que muestra cuántas ventas están pendientes.
- **Tarjetas de venta**: Badge **"Local"** en las ventas que aún no se han sincronizado.

### ✅ Sync reintenta ventas en estado 'error'
- **`sync_service.dart`**: Cambiado el filtro de `sync_status = 'pending'` a `(sync_status = 'pending' OR sync_status = 'error') AND retry_count < 10`.
- Las ventas que fallaron se reintentan.

### ✅ Contador de pendientes
- `VentasState` ahora incluye `pendingCount` (int) y `pendingSyncIds` (Set<String>).
- Se actualiza automáticamente después de cargar ventas del día o buscar.
- El badge y banner se sincronizan en tiempo real.

## Problemas detectados

1. **`NoInternetFailure` está definido pero casi no se usa** -- la mayoría de repositorios devuelven `ServerFailure` genérico aunque el error sea de conexión.
2. **`NoInternetException` nunca se lanza desde los datasources** -- no se captura `SocketException` ni `TimeoutException` de forma diferenciada.
3. **Sync duplicado**: `sync_service.dart` (WorkManager) y `ventas_repository_impl.dart` tienen lógica duplicada para sincronizar ventas pendientes.
4. **Sin UI de cola de sync**: El usuario no puede ver cuántas ventas están pendientes de sincronizar ni forzar un sync manual.
5. **`connectivityProvider` inicia como `true`** (asume online) -- hay un período donde la app cree tener conexión cuando aún no verificó.
6. **Máximo de reintentos inconsistente**: `app_constants.dart` define `maxRetrySync = 3` pero el código usa `10` hardcodeado.
7. **Mensajes de error poco amigables**: Muestran excepciones crudas como *"PostgrestException: ..."* en vez de textos para el usuario.
