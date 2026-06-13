# Estructura del Proyecto

## Organización de Carpetas

```
GuardaYaApp_Mobile/
├── android/                    # Configuración Android
├── ios/                        # Configuración iOS
├── web/                        # Configuración Web
├── assets/                     # Imágenes, iconos, fuentes
│   ├── images/
│   └── icons/
├── lib/                        # Código principal de Flutter
│   ├── app.dart                # Configuración de la app
│   ├── main.dart               # Punto de entrada
│   ├── core/                   # Capa transversal
│   │   ├── constants/          # Constantes (API, App)
│   │   ├── errors/             # Failures y Exceptions
│   │   ├── theme/              # AppTheme, AppColors
│   │   └── usecases/           # Contrato base de UseCase
│   ├── data/                   # Capa de Datos
│   │   ├── datasources/
│   │   │   ├── local/          # SQLite, SecureStorage
│   │   │   │   ├── cache/
│   │   │   │   │   └── secure_storage.dart
│   │   │   │   └── db/
│   │   │   │       ├── database_helper.dart
│   │   │   │       └── pending_ventas_dao.dart
│   │   │   └── remote/         # Supabase, Edge Functions
│   │   │       ├── auth_datasource.dart
│   │   │       ├── usuario_datasource.dart
│   │   │       ├── ventas_datasource.dart
│   │   │       ├── productos_datasource.dart
│   │   │       ├── clientes_datasource.dart
│   │   │       └── ocr_datasource.dart
│   │   ├── models/             # DTOs (JSON ↔ Entity)
│   │   │   ├── usuario_model.dart
│   │   │   ├── venta_model.dart
│   │   │   ├── producto_model.dart
│   │   │   ├── cliente_model.dart
│   │   │   ├── empresa_model.dart
│   │   │   ├── empresa_colors.dart
│   │   │   └── pending_venta_model.dart
│   │   └── repositories/
│   │       └── implementations/
│   │           ├── auth_repository_impl.dart
│   │           ├── usuario_repository_impl.dart
│   │           ├── ventas_repository_impl.dart
│   │           ├── productos_repository_impl.dart
│   │           └── clientes_repository_impl.dart
│   ├── domain/                 # Capa de Dominio
│   │   ├── entities/           # Entidades de negocio
│   │   │   ├── usuario.dart
│   │   │   ├── venta.dart
│   │   │   ├── producto.dart
│   │   │   ├── cliente.dart
│   │   │   └── empresa.dart
│   │   ├── repositories/       # Interfaces (contratos)
│   │   │   ├── auth_repository.dart
│   │   │   ├── usuario_repository.dart
│   │   │   ├── ventas_repository.dart
│   │   │   ├── productos_repository.dart
│   │   │   └── clientes_repository.dart
│   │   └── usecases/           # Casos de uso
│   │       ├── auth/
│   │       │   ├── login_usuario.dart
│   │       │   ├── logout_usuario.dart
│   │       │   └── obtener_usuario_actual.dart
│   │       ├── usuarios/
│   │       │   ├── crear_usuario.dart
│   │       │   └── listar_usuarios.dart
│   │       ├── ventas/
│   │       │   ├── registrar_venta.dart
│   │       │   ├── obtener_ventas_por_fecha.dart
│   │       │   ├── buscar_venta_por_codigo.dart
│   │       │   ├── buscar_venta_por_telefono.dart
│   │       │   └── cambiar_estado_venta.dart
│   │       ├── productos/
│   │       │   └── obtener_productos.dart
│   │       └── clientes/
│   │           └── obtener_clientes.dart
│   ├── presentation/           # Capa de Presentación
│   │   ├── pages/              # Páginas de la app
│   │   │   ├── login_page.dart
│   │   │   ├── home_page.dart
│   │   │   ├── crear_usuario_temp_page.dart
│   │   │   ├── perfil/
│   │   │   │   └── perfil_page.dart
│   │   │   ├── usuarios/
│   │   │   │   ├── empleados_list_page.dart
│   │   │   │   └── crear_empleado_page.dart
│   │   │   └── ventas/
│   │   │       ├── ventas_list_page.dart
│   │   │       ├── venta_detail_page.dart
│   │   │       ├── registrar_venta_page.dart
│   │   │       └── buscar_venta_page.dart
│   │   ├── providers/          # State Management (Riverpod)
│   │   │   ├── auth_provider.dart
│   │   │   ├── usuarios_provider.dart
│   │   │   ├── ventas_provider.dart
│   │   │   ├── theme_provider.dart
│   │   │   ├── connectivity_provider.dart
│   │   │   └── empresa_colors_provider.dart
│   │   └── widgets/            # Componentes reutilizables
│   │       └── common/
│   │           ├── loading_indicator.dart
│   │           └── custom_button.dart
│   └── services/               # Servicios globales
│       ├── supabase_service.dart   # Cliente Supabase
│       ├── ocr_service.dart       # Servicio OCR
│       ├── sync_service.dart      # Sincronización offline
│       └── connectivity_service.dart
├── supabase/                   # Edge Functions
│   └── functions/
│       ├── login-custom/
│       │   └── index.ts         # Login con bcrypt
│       └── ocr-extract/
│           └── index.ts         # OCR de comprobantes
├── docs/                        # Documentación
│   ├── README.md
│   ├── arquitectura.md
│   ├── autenticacion.md
│   ├── database.md
│   ├── deployment.md
│   ├── estructura.md
│   ├── enfoque.md
│   ├── problematica.md
│   ├── roadmap.md
│   └── versiones.md
├── supabase_login_bcrypt_clean.sql   # SQL de autenticación
├── pubspec.yaml               # Dependencias Flutter
└── README.md                   # README del proyecto

```

## Convenciones de Nomenclatura

### Archivos

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Páginas | `nombre_page.dart` | `login_page.dart` |
| Providers | `nombre_provider.dart` | `auth_provider.dart` |
| Modelos | `nombre_model.dart` | `usuario_model.dart` |
| Entidades | `nombre.dart` | `usuario.dart` |
| Repositorios | `nombre_repository.dart` | `auth_repository.dart` |
| Implementaciones | `nombre_repository_impl.dart` | `auth_repository_impl.dart` |
| Datasources | `nombre_datasource.dart` | `auth_datasource.dart` |
| UseCases | `nombre_accion.dart` | `login_usuario.dart` |

### Clases

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Entidades | `Nombre` | `Usuario` |
| Modelos | `NombreModel` | `UsuarioModel` |
| Repositorios | `NombreRepository` | `AuthRepository` |
| Implementaciones | `NombreRepositoryImpl` | `AuthRepositoryImpl` |
| Datasources | `NombreDatasource` | `AuthDatasource` |
| UseCases | `NombreAccion` | `LoginUsuario` |
| Providers | `NombreNotifier` | `AuthNotifier` |
| States | `NombreState` | `AuthState` |

### Variables y Métodos

- **Dart style**: `lowerCamelCase` para variables y métodos
- **Privados**: Prefijo `_` para métodos/variables privados
- **Constantes**: `UPPER_SNAKE_CASE` o `kCamelCase`

## Dependencias Principales

```yaml
# Backend
supabase_flutter: ^2.8.4    # Cliente Supabase (solo para queries, no auth)

# UI
go_router: ^14.8.1          # Navegación
flutter_riverpod: ^2.6.1    # State management

# Local
sqflite: ^2.4.2             # SQLite
flutter_secure_storage: ^9.2.4  # Almacenamiento seguro

# OCR
google_mlkit_text_recognition: ^0.14.0

# Otros
connectivity_plus: ^6.1.3   # Conectividad
workmanager: ^0.9.0+3        # Background sync
fpdart: ^1.1.1              # Programación funcional
```

## Flujo de Desarrollo

1. **Domain**: Define la entidad y el contrato del repositorio
2. **Data**: Implementa el datasource y el repositorio
3. **UseCase**: Crea el caso de uso
4. **Provider**: Crea el provider de Riverpod
5. **UI**: Crea la página y conecta el provider

## Notas Importantes

- **No usar `auth.uid()`**: Todos los datos se obtienen por `username`
- **No usar `SupabaseService.auth`**: La sesión se maneja localmente
- **Offline-first**: Siempre considerar que no hay internet
- **bcrypt**: Las contraseñas se hashean en PostgreSQL, nunca en Flutter
