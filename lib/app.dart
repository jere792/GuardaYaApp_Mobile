import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_theme.dart';
import 'package:guardaya_app/presentation/pages/home_page.dart';
import 'package:guardaya_app/presentation/pages/login_page.dart';
import 'package:guardaya_app/presentation/pages/ventas/buscar_venta_page.dart';
import 'package:guardaya_app/presentation/pages/ventas/registrar_venta_page.dart';
import 'package:guardaya_app/presentation/pages/ventas/venta_detail_page.dart';
import 'package:guardaya_app/presentation/pages/ventas/ventas_list_page.dart';
import 'package:guardaya_app/presentation/pages/perfil/perfil_page.dart';
import 'package:guardaya_app/presentation/pages/usuarios/crear_empleado_page.dart';
import 'package:guardaya_app/presentation/pages/usuarios/empleado_detail_page.dart';
import 'package:guardaya_app/presentation/pages/usuarios/empleado_edit_page.dart';
import 'package:guardaya_app/presentation/pages/usuarios/empleados_list_page.dart';
import 'package:guardaya_app/presentation/pages/categorias/categoria_detail_page.dart';
import 'package:guardaya_app/presentation/pages/categorias/categoria_form_page.dart';
import 'package:guardaya_app/presentation/pages/categorias/categorias_list_page.dart';
import 'package:guardaya_app/presentation/pages/clientes/cliente_detail_page.dart';
import 'package:guardaya_app/presentation/pages/clientes/cliente_form_page.dart';
import 'package:guardaya_app/presentation/pages/clientes/clientes_list_page.dart';
import 'package:guardaya_app/presentation/pages/crear_usuario_temp_page.dart';
import 'package:guardaya_app/presentation/pages/productos/producto_detail_page.dart';
import 'package:guardaya_app/presentation/pages/productos/producto_form_page.dart';
import 'package:guardaya_app/presentation/pages/productos/productos_list_page.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/theme_provider.dart';

/// Define qué roles pueden acceder a cada ruta.
/// super_admin tiene acceso a todo.
const Map<String, List<String>> _routeRoles = {
  '/login': ['super_admin', 'admin', 'empleado'],
  '/crear-usuarios': ['super_admin', 'admin', 'empleado'],
  '/': ['super_admin', 'admin', 'empleado'],
  '/ventas': ['super_admin', 'admin', 'empleado'],
  '/ventas/registrar': ['super_admin', 'admin', 'empleado'],
  '/ventas/buscar': ['super_admin', 'admin', 'empleado'],
  '/ventas/:id': ['super_admin', 'admin', 'empleado'],
  '/perfil': ['super_admin', 'admin', 'empleado'],
  '/empleados': ['super_admin', 'admin'],
  '/empleados/crear': ['super_admin', 'admin'],
  '/empleados/detalle/:id': ['super_admin', 'admin', 'empleado'],
  '/empleados/editar/:id': ['super_admin', 'admin'],
  '/categorias': ['super_admin', 'admin'],
  '/categorias/crear': ['super_admin', 'admin'],
  '/categorias/:id': ['super_admin', 'admin', 'empleado'],
  '/categorias/editar/:id': ['super_admin', 'admin'],
  '/clientes': ['super_admin', 'admin', 'empleado'],
  '/clientes/crear': ['super_admin', 'admin', 'empleado'],
  '/clientes/:id': ['super_admin', 'admin', 'empleado'],
  '/clientes/editar/:id': ['super_admin', 'admin', 'empleado'],
  '/productos': ['super_admin', 'admin', 'empleado'],
  '/productos/crear': ['super_admin', 'admin'],
  '/productos/:id': ['super_admin', 'admin', 'empleado'],
  '/productos/editar/:id': ['super_admin', 'admin'],
};

bool _isRouteAllowed(String route, String? rol) {
  if (rol == null) return false;
  // super_admin siempre puede acceder
  if (rol == 'super_admin') return true;
  // Normalizar rutas con parámetros (ej: /ventas/123 -> /ventas/:id)
  String normalizedRoute = route;
  if (route.startsWith('/ventas/') && route != '/ventas/registrar' && route != '/ventas/buscar') {
    normalizedRoute = '/ventas/:id';
  } else if (route.startsWith('/empleados/detalle/')) {
    normalizedRoute = '/empleados/detalle/:id';
  } else if (route.startsWith('/empleados/editar/')) {
    normalizedRoute = '/empleados/editar/:id';
  } else if (route.startsWith('/categorias/editar/')) {
    normalizedRoute = '/categorias/editar/:id';
  } else if (route.startsWith('/categorias/') && route != '/categorias/crear') {
    normalizedRoute = '/categorias/:id';
  } else if (route.startsWith('/clientes/editar/')) {
    normalizedRoute = '/clientes/editar/:id';
  } else if (route.startsWith('/clientes/') && route != '/clientes/crear') {
    normalizedRoute = '/clientes/:id';
  } else if (route.startsWith('/productos/editar/')) {
    normalizedRoute = '/productos/editar/:id';
  } else if (route.startsWith('/productos/') && route != '/productos/crear') {
    normalizedRoute = '/productos/:id';
  }
  final allowed = _routeRoles[normalizedRoute];
  return allowed != null && allowed.contains(rol);
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isCrearUsuariosRoute = state.matchedLocation == '/crear-usuarios';
      final rol = authState.usuario?.rolId;

      // Rutas públicas que no requieren autenticación
      if (!isAuthenticated && (isLoginRoute || isCrearUsuariosRoute)) {
        return null;
      }
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      if (isAuthenticated && isLoginRoute) {
        return '/';
      }
      if (isAuthenticated && !_isRouteAllowed(state.matchedLocation, rol)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/ventas', builder: (context, state) => const VentasListPage()),
      GoRoute(path: '/ventas/registrar', builder: (context, state) => const RegistrarVentaPage()),
      GoRoute(path: '/ventas/buscar', builder: (context, state) => const BuscarVentaPage()),
      GoRoute(path: '/ventas/:id', builder: (context, state) => VentaDetailPage(ventaId: state.pathParameters['id']!)),
      GoRoute(path: '/perfil', builder: (context, state) => const PerfilPage()),
      GoRoute(path: '/empleados', builder: (context, state) => const EmpleadosListPage()),
      GoRoute(path: '/empleados/crear', builder: (context, state) => const CrearEmpleadoPage()),
      GoRoute(
        path: '/empleados/detalle/:id',
        builder: (context, state) => EmpleadoDetailPage(empleadoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/empleados/editar/:id',
        builder: (context, state) => EmpleadoEditPage(empleadoId: state.pathParameters['id']!),
      ),
      // Página temporal para crear usuarios en Supabase Auth
      // TODO: Eliminar después de crear los usuarios
      GoRoute(path: '/categorias', builder: (context, state) => const CategoriasListPage()),
      GoRoute(
        path: '/categorias/crear',
        builder: (context, state) => const CategoriaFormPage(),
      ),
      GoRoute(
        path: '/categorias/:id',
        builder: (context, state) => CategoriaDetailPage(categoriaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/categorias/editar/:id',
        builder: (context, state) => CategoriaFormPage(categoriaId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/clientes', builder: (context, state) => const ClientesListPage()),
      GoRoute(
        path: '/clientes/crear',
        builder: (context, state) => const ClienteFormPage(),
      ),
      GoRoute(
        path: '/clientes/:id',
        builder: (context, state) => ClienteDetailPage(clienteId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/clientes/editar/:id',
        builder: (context, state) => ClienteFormPage(clienteId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/productos', builder: (context, state) => const ProductosListPage()),
      GoRoute(
        path: '/productos/crear',
        builder: (context, state) => const ProductoFormPage(),
      ),
      GoRoute(
        path: '/productos/:id',
        builder: (context, state) => ProductoDetailPage(productoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/productos/editar/:id',
        builder: (context, state) => ProductoFormPage(productoId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/crear-usuarios', builder: (context, state) => const CrearUsuarioTempPage()),
    ],
  );
});

class GuardaYaApp extends ConsumerWidget {
  const GuardaYaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'GuardaYa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
