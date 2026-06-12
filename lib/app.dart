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
import 'package:guardaya_app/presentation/pages/usuarios/empleados_list_page.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';

/// Define qué roles pueden acceder a cada ruta.
/// super_admin tiene acceso a todo.
const Map<String, List<String>> _routeRoles = {
  '/login': ['super_admin', 'admin', 'empleado'],
  '/': ['super_admin', 'admin', 'empleado'],
  '/ventas': ['super_admin', 'admin', 'empleado'],
  '/ventas/registrar': ['super_admin', 'admin', 'empleado'],
  '/ventas/buscar': ['super_admin', 'admin', 'empleado'],
  '/ventas/:id': ['super_admin', 'admin', 'empleado'],
  '/perfil': ['super_admin', 'admin', 'empleado'],
  '/empleados': ['super_admin', 'admin'],
  '/empleados/crear': ['super_admin', 'admin'],
};

bool _isRouteAllowed(String route, String? rol) {
  if (rol == null) return false;
  // super_admin siempre puede acceder
  if (rol == 'super_admin') return true;
  // Normalizar rutas con parámetros (ej: /ventas/123 -> /ventas/:id)
  final normalizedRoute = route.startsWith('/ventas/') && route != '/ventas/registrar' && route != '/ventas/buscar'
      ? '/ventas/:id'
      : route;
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
      final rol = authState.usuario?.rolId;

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
    ],
  );
});

class GuardaYaApp extends ConsumerWidget {
  const GuardaYaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final empresaColors = ref.watch(empresaColorsSyncProvider);

    return MaterialApp.router(
      title: 'GuardaYa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(empresaColors: empresaColors),
      routerConfig: router,
    );
  }
}
