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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      if (isAuthenticated && isLoginRoute) {
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
