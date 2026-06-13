# Arquitectura del Proyecto

## Clean Architecture

GuardaYa sigue una arquitectura **Clean Architecture** con separación de responsabilidades en capas concéntricas. Esto permite:

- **Independencia de frameworks**: El dominio no depende de Flutter ni de Supabase
- **Testabilidad**: Cada capa puede probarse en aislamiento
- **Mantenibilidad**: Cambios en una capa no afectan a las otras

## Capas del Proyecto

### 1. Domain Layer (Capa de Dominio)
```
lib/domain/
├── entities/          # Entidades de negocio (Usuario, Venta, Producto)
├── repositories/      # Interfaces/Contratos de repositorios
└── usecases/          # Casos de uso (Login, Crear Venta, etc.)
```

**Principio**: No depende de nada externo. Es pura lógica de negocio.

### 2. Data Layer (Capa de Datos)
```
lib/data/
├── models/            # Modelos de datos (DTOs) - JSON ↔ Entity
├── repositories/      # Implementaciones de repositorios
└── datasources/
    ├── remote/        # Fuentes de datos remotas (Supabase, Edge Functions)
    └── local/         # Fuentes de datos locales (SQLite, Secure Storage)
```

**Responsabilidad**: Implementar los contratos del Domain, manejar la conversión de datos.

### 3. Presentation Layer (Capa de Presentación)
```
lib/presentation/
├── pages/             # Páginas/UI (Login, Home, Ventas)
├── providers/         # State management (Riverpod)
└── widgets/           # Componentes reutilizables
```

**Responsabilidad**: Mostrar datos al usuario y capturar interacciones.

### 4. Core Layer (Capa Transversal)
```
lib/core/
├── constants/         # Constantes de la app
├── errors/            # Manejo de errores (Failures, Exceptions)
├── theme/             # Temas y colores
└── usecases/          # Contrato base de UseCase
```

## Flujo de Datos

```
UI (Presentation)
    ↓
Provider (Riverpod)
    ↓
UseCase (Domain)
    ↓
Repository (Data) ← Either<Failure, Success>
    ↓
DataSource (Remote/Local)
    ↓
Supabase / SQLite / Storage
```

## Patrones Implementados

### Repository Pattern
Abstrae la fuente de datos. El dominio habla con una interfaz, no sabe si viene de Supabase o SQLite.

### UseCase Pattern
Cada operación de negocio es un caso de uso independiente:
- `LoginUsuario`
- `CrearUsuario`
- `RegistrarVenta`
- `ObtenerVentasPorFecha`

### Dependency Injection
Usando **Riverpod** como service locator:
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(...));
final loginProvider = Provider<LoginUsuario>((ref) => LoginUsuario(ref.watch(authRepositoryProvider)));
```

## Manejo de Errores

Se usa **Either** de `fpdart` para manejar errores de forma funcional:

```dart
Future<Either<Failure, Usuario>> login(...) {
  try {
    // ... operación
    return Right(usuario);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

**Tipos de Failure**:
- `AuthFailure`: Credenciales inválidas
- `ServerFailure`: Error de conexión/red
- `CacheFailure`: Error de almacenamiento local

## Estado de la UI

Cada provider maneja un `State` inmutable:
```dart
class AuthState {
  final Usuario? usuario;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isOffline;
}
```

Los cambios se hacen con `copyWith()` para mantener inmutabilidad.

## Navegación

**Go Router** para declarar rutas de forma tipada:
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => LoginPage()),
    GoRoute(path: '/home', builder: (_, __) => HomePage()),
  ],
);
```

## Seguridad

- **Secure Storage**: Guarda datos sensibles (usuario, empresa)
- **bcrypt**: Hashing de contraseñas en servidor
- **Sin JWT**: Sesión manejada localmente sin dependencia de tokens
