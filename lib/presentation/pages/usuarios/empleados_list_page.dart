import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/empleados/crear'),
          ),
        ],
      ),
      body: usuariosState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : usuariosState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(usuariosState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarEmpleados,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : empleados.isEmpty
                  ? const Center(child: Text('No hay empleados registrados'))
                  : RefreshIndicator(
                      onRefresh: () async => _cargarEmpleados(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: empleados.length,
                        itemBuilder: (context, index) {
                          final emp = empleados[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(emp.nombre.substring(0, 1).toUpperCase()),
                              ),
                              title: Text(emp.nombre),
                              subtitle: Text('${emp.username} | ${emp.rolId}'),
                              trailing: emp.activo
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.cancel, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
