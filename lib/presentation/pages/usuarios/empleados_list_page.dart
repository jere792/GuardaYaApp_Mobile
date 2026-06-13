import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class EmpleadosListPage extends ConsumerStatefulWidget {
  const EmpleadosListPage({super.key});

  @override
  ConsumerState<EmpleadosListPage> createState() => _EmpleadosListPageState();
}

class _EmpleadosListPageState extends ConsumerState<EmpleadosListPage> {
  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  void _cargarEmpleados() {
    final empresaId = ref.read(authProvider).usuario?.empresaId;
    if (empresaId != null && empresaId.isNotEmpty) {
      ref.read(usuariosProvider.notifier).cargarEmpleados(empresaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuariosState = ref.watch(usuariosProvider);
    final empleados = usuariosState.usuarios;
    final empresaColors = ref.watch(empresaColorsSyncProvider);
    final rolActual = ref.watch(authProvider).usuario?.rolId ?? 'empleado';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        backgroundColor: empresaColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/empleados/crear'),
          ),
        ],
      ),
      body: usuariosState.isLoading
          ? Center(child: CircularProgressIndicator(color: empresaColors.primary))
          : usuariosState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(usuariosState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarEmpleados,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: empresaColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : empleados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: empresaColors.primary.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No hay empleados registrados',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _cargarEmpleados(),
                      color: empresaColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: empleados.length,
                        itemBuilder: (context, index) {
                          final emp = empleados[index];
                          return _EmpleadoCard(
                            empleado: emp,
                            colors: empresaColors,
                            rolActual: rolActual,
                            onDesactivar: () => _confirmarDesactivar(context, emp),
                          );
                        },
                      ),
                    ),
    );
  }

  void _confirmarDesactivar(BuildContext context, dynamic emp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar empleado'),
        content: Text('¿Estás seguro de desactivar a ${emp.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(usuariosProvider.notifier).desactivarEmpleado(emp.id);
              final state = ref.read(usuariosProvider);
              if (state.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Empleado desactivado exitosamente')),
                );
                ref.read(usuariosProvider.notifier).resetSuccess();
              } else if (state.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
                );
                ref.read(usuariosProvider.notifier).resetError();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desactivar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EmpleadoCard extends StatelessWidget {
  final dynamic empleado;
  final EmpresaColors colors;
  final String rolActual;
  final VoidCallback onDesactivar;

  const _EmpleadoCard({
    required this.empleado,
    required this.colors,
    required this.rolActual,
    required this.onDesactivar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: empleado.activo ? colors.primary : Colors.grey,
          foregroundColor: Colors.white,
          child: Text(empleado.nombre.substring(0, 1).toUpperCase()),
        ),
        title: Text(
          empleado.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: empleado.activo ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('${empleado.username} | ${empleado.rolId.toUpperCase()}'),
            if (empleado.email != null) ...[
              const SizedBox(height: 2),
              Text(empleado.email!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: empleado.activo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                empleado.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: empleado.activo ? Colors.green : Colors.red,
                ),
              ),
            ),
            if (rolActual != 'empleado' && empleado.activo)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'desactivar') onDesactivar();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'desactivar',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Desactivar'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
