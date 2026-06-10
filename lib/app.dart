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

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/ventas', builder: (context, state) => const VentasListPage()),
    GoRoute(path: '/ventas/registrar', builder: (context, state) => const RegistrarVentaPage()),
    GoRoute(path: '/ventas/buscar', builder: (context, state) => const BuscarVentaPage()),
    GoRoute(path: '/ventas/:id', builder: (context, state) => VentaDetailPage(ventaId: state.pathParameters['id']!)),
    GoRoute(path: '/perfil', builder: (context, state) => const PerfilPage()),
  ],
);

class GuardaYaApp extends StatelessWidget {
  const GuardaYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'GuardaYa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}