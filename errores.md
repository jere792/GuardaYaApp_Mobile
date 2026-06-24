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

---

## Problemas detectados

1. **`NoInternetFailure` está definido pero casi no se usa** -- la mayoría de repositorios devuelven `ServerFailure` genérico aunque el error sea de conexión.
2. **`NoInternetException` nunca se lanza desde los datasources** -- no se captura `SocketException` ni `TimeoutException` de forma diferenciada.
3. **Sync duplicado**: `sync_service.dart` (WorkManager) y `ventas_repository_impl.dart` tienen lógica duplicada para sincronizar ventas pendientes.
4. **Sin UI de cola de sync**: El usuario no puede ver cuántas ventas están pendientes de sincronizar ni forzar un sync manual.
5. **`connectivityProvider` inicia como `true`** (asume online) -- hay un período donde la app cree tener conexión cuando aún no verificó.
6. **Máximo de reintentos inconsistente**: `app_constants.dart` define `maxRetrySync = 3` pero el código usa `10` hardcodeado.
7. **Mensajes de error poco amigables**: Muestran excepciones crudas como *"PostgrestException: ..."* en vez de textos para el usuario.
    