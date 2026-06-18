import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class EmpleadosListPage extends ConsumerStatefulWidget {
  const EmpleadosListPage({super.key});

  @override
  ConsumerState<EmpleadosListPage> createState() => _EmpleadosListPageState();
}

class _EmpleadosListPageState extends ConsumerState<EmpleadosListPage> {
  bool _mostrarInactivos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarEmpleados());
  }

  void _cargarEmpleados() {
    final authState = ref.read(authProvider);
    final usuario = authState.usuario;
    final rol = usuario?.rolId ?? 'empleado';
    final empresaId = usuario?.empresaId;

    if (rol == 'super_admin') {
      ref.read(usuariosProvider.notifier).cargarEmpleados(null, rol);
    } else if (empresaId != null && empresaId.isNotEmpty) {
      ref.read(usuariosProvider.notifier).cargarEmpleados(empresaId, rol);
    }
  }

  String _rolLabel(String rolId) {
    switch (rolId.toLowerCase()) {
      case 'super_admin':
      case 'superadministrador':
        return 'Super Admin';
      case 'admin':
      case 'administrador':
        return 'Admin';
      default:
        return 'Empleado';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false && next.usuario != null) {
        _cargarEmpleados();
      }
    });

    final usuariosState = ref.watch(usuariosProvider);
    final todos = usuariosState.usuarios;
    final rolActual = ref.watch(authProvider).usuario?.rolId ?? 'empleado';
    final empleados = todos.where((e) => e.activo == !_mostrarInactivos).toList();
    final activos = todos.where((e) => e.activo).length;
    final inactivos = todos.length - activos;

    return Scaffold(
      appBar: AppBar(
        title: Text(_mostrarInactivos ? 'Inactivos' : 'Empleados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_mostrarInactivos) {
              setState(() => _mostrarInactivos = false);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        actions: [
          if (rolActual != 'empleado')
            IconButton(
              icon: Icon(_mostrarInactivos ? Icons.people : Icons.delete_sweep),
              onPressed: () => setState(() => _mostrarInactivos = !_mostrarInactivos),
              tooltip: _mostrarInactivos ? 'Ver activos' : 'Ver inactivos',
            ),
          if (rolActual != 'empleado' && !_mostrarInactivos)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => context.push('/empleados/crear'),
              tooltip: 'Agregar empleado',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: usuariosState.isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                        ? _EmptyState(
                            icon: _mostrarInactivos ? Icons.delete_sweep : Icons.people_outline,
                            message: _mostrarInactivos
                                ? 'No hay empleados inactivos'
                                : 'No hay empleados activos',
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _cargarEmpleados(),
                            color: AppColors.primary,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                              child: GridView.builder(
                                itemCount: empleados.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.82,
                                ),
                                itemBuilder: (context, index) {
                                  final emp = empleados[index];
                                  return _EmpleadoCard(
                                    empleado: emp,
                                    rolActual: rolActual,
                                    rolLabel: _rolLabel(emp.rolId),
                                    onDesactivar: () => _confirmarDesactivar(context, emp),
                                    onVerDetalle: () => context.push('/empleados/detalle/${emp.id}'),
                                    onEditar: () => context.push('/empleados/editar/${emp.id}'),
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _confirmarDesactivar(BuildContext context, Usuario emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_mostrarInactivos ? 'Reactivar empleado' : 'Desactivar empleado'),
        content: Text(
          _mostrarInactivos
              ? '¿Reactivar a ${emp.nombre}?'
              : '¿Desactivar a ${emp.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(usuariosProvider.notifier).desactivarEmpleado(emp.id);
              final state = ref.read(usuariosProvider);
              if (state.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _mostrarInactivos
                          ? 'Empleado reactivado'
                          : 'Empleado desactivado',
                    ),
                  ),
                );
                ref.read(usuariosProvider.notifier).resetSuccess();
              } else if (state.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
                );
                ref.read(usuariosProvider.notifier).resetError();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _mostrarInactivos ? Colors.green : Colors.red,
            ),
            child: Text(
              _mostrarInactivos ? 'Reactivar' : 'Desactivar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderEmpleados extends StatelessWidget {
  final int totalActivos;
  final int totalInactivos;
  final bool mostrandoInactivos;
  final VoidCallback onBack;
  final VoidCallback? onToggleFilter;
  final VoidCallback? onAdd;

  const _HeaderEmpleados({
    required this.totalActivos,
    required this.totalInactivos,
    required this.mostrandoInactivos,
    required this.onBack,
    this.onToggleFilter,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 48, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
              ),
              const Spacer(),
              if (onToggleFilter != null)
                IconButton(
                  icon: Icon(
                    mostrandoInactivos ? Icons.people : Icons.delete_sweep,
                    color: Colors.white,
                  ),
                  onPressed: onToggleFilter,
                  tooltip: mostrandoInactivos ? 'Ver activos' : 'Ver inactivos',
                ),
              if (onAdd != null && !mostrandoInactivos)
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  onPressed: onAdd,
                  tooltip: 'Agregar empleado',
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              mostrandoInactivos ? 'Inactivos' : 'Empleados',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.check_circle,
                  label: '$totalActivos activos',
                  color: Colors.greenAccent,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.cancel,
                  label: '$totalInactivos inactivos',
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmpleadoCard extends StatelessWidget {
  final Usuario empleado;
  final String rolActual;
  final String rolLabel;
  final VoidCallback onDesactivar;
  final VoidCallback onVerDetalle;
  final VoidCallback onEditar;

  const _EmpleadoCard({
    required this.empleado,
    required this.rolActual,
    required this.rolLabel,
    required this.onDesactivar,
    required this.onVerDetalle,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = empleado.activo;

    return Card(
      elevation: isActive ? 2 : 1,
      color: isActive ? colorScheme.surface : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isActive
            ? BorderSide.none
            : BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isActive ? AppColors.primary : Colors.grey,
                foregroundColor: Colors.white,
                child: Text(
                  (empleado.nombre.isNotEmpty
                          ? empleado.nombre.substring(0, 1)
                          : '?')
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              empleado.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              empleado.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            Text(
              rolLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withValues(alpha: isActive ? 1.0 : 0.4),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                if (rolActual != 'empleado')
                  InkWell(
                    onTap: onDesactivar,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isActive ? Icons.block : Icons.check_circle_outline,
                        size: 14,
                        color: isActive ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'Detalle',
                    onTap: onVerDetalle,
                  ),
                ),
                const SizedBox(width: 4),
                if (rolActual != 'empleado')
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      onTap: onEditar,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}