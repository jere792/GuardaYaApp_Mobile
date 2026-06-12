import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/connectivity_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final rolId = usuario?.rolId ?? 'empleado';
    final isOffline = authState.isOffline;

    // Escuchar cambios de conectividad para actualizar el estado offline
    ref.listen(connectivityProvider, (previous, next) {
      if (previous != next) {
        ref.read(authProvider.notifier).setOffline(!next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('GuardaYa - Inicio'),
        actions: [
          if (isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Offline'),
                backgroundColor: Colors.orange,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _buildContentByRole(rolId, ref, isOffline),
    );
  }

  Widget _buildContentByRole(String rolId, WidgetRef ref, bool isOffline) {
    switch (rolId) {
      case 'super_admin':
        return SuperAdminView(isOffline: isOffline);
      case 'admin':
        return AdminView(isOffline: isOffline);
      case 'empleado':
        return EmpleadoView(isOffline: isOffline);
      default:
        return EmpleadoView(isOffline: isOffline);
    }
  }
}

class SuperAdminView extends StatelessWidget {
  final bool isOffline;
  const SuperAdminView({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isOffline) const OfflineBanner(),
        Text('Vista Super Administrador', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.business),
            title: Text('Gestionar Empresas'),
            subtitle: Text('Crear, editar y eliminar empresas'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Gestionar Usuarios'),
            subtitle: const Text('Administrar usuarios de todas las empresas'),
            onTap: () => context.push('/empleados'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Reportes Globales'),
            subtitle: Text('Ver métricas de todas las empresas'),
          ),
        ),
      ],
    );
  }
}

class AdminView extends StatelessWidget {
  final bool isOffline;
  const AdminView({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isOffline) const OfflineBanner(),
        Text('Vista Administrador', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('Ventas de Hoy'),
            subtitle: const Text('Ver y gestionar ventas de tu empresa'),
            onTap: () => context.push('/ventas'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Inventario'),
            subtitle: Text('Gestionar productos y stock'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Empleados'),
            subtitle: const Text('Gestionar empleados de tu empresa'),
            onTap: () => context.push('/empleados'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Reportes'),
            subtitle: Text('Ver métricas de tu empresa'),
          ),
        ),
      ],
    );
  }
}

class EmpleadoView extends StatelessWidget {
  final bool isOffline;
  const EmpleadoView({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isOffline) const OfflineBanner(),
        Text('Vista Empleado', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('Registrar Venta'),
            subtitle: const Text('Crear una nueva venta con OCR'),
            onTap: () => context.push('/ventas/registrar'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Buscar Venta'),
            subtitle: const Text('Buscar por código o teléfono'),
            onTap: () => context.push('/ventas/buscar'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Lista de Ventas'),
            subtitle: const Text('Ver todas las ventas del día'),
            onTap: () => context.push('/ventas'),
          ),
        ),
      ],
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo sin conexión. Las ventas se guardarán localmente y se sincronizarán cuando vuelva la conexión.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
