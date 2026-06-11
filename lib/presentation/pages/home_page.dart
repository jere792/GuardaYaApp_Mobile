import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final rolId = usuario?.rolId ?? 'empleado';

    return Scaffold(
      appBar: AppBar(
        title: const Text('GuardaYa - Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _buildContentByRole(rolId, ref),
    );
  }

  Widget _buildContentByRole(String rolId, WidgetRef ref) {
    switch (rolId) {
      case 'super_admin':
        return const SuperAdminView();
      case 'admin':
        return const AdminView();
      case 'empleado':
        return const EmpleadoView();
      default:
        return const EmpleadoView();
    }
  }
}

class SuperAdminView extends StatelessWidget {
  const SuperAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
  const EmpleadoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
