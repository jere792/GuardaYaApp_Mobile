import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class EmpleadoDetailPage extends ConsumerWidget {
  final String empleadoId;

  const EmpleadoDetailPage({super.key, required this.empleadoId});

  String _rolLabel(String rolId) {
    switch (rolId.toLowerCase()) {
      case 'super_admin':
      case 'superadministrador':
      case 'c63abe3d-5de8-442b-b8d8-9738ad9a7be5':
        return 'Super Administrador';
      case 'admin':
      case 'administrador':
      case '6801325e-df02-4391-a882-66247e664dcf':
        return 'Administrador';
      case 'empleado':
      case '77cdd9df-e7fe-4984-9bd9-9ab2168abf5b':
        return 'Empleado';
      default:
        final id = rolId.toLowerCase();
        if (id.contains('admin')) return 'Administrador';
        if (id.contains('super')) return 'Super Administrador';
        return 'Empleado';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosState = ref.watch(usuariosProvider);
    final empleado = usuariosState.usuarios.where((u) => u.id == empleadoId).firstOrNull;
    final rolActual = ref.watch(authProvider).usuario?.rolId ?? 'empleado';
    if (empleado == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Empleado'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: const Center(child: Text('Empleado no encontrado')),
      );
    }

    final isActive = empleado.activo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Empleado'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (rolActual != 'empleado')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/empleados/editar/$empleadoId'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.primary,
                  child: Text(
                    (empleado.nombre.isNotEmpty ? empleado.nombre.substring(0, 1) : '?').toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  empleado.nombre,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  _rolLabel(empleado.rolId),
                  style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.person, label: 'Usuario', value: empleado.username),
                  const SizedBox(height: 16),
                  if (empleado.email != null) ...[
                    _InfoRow(icon: Icons.email, label: 'Email', value: empleado.email!),
                    const SizedBox(height: 16),
                  ],
                  if (empleado.telefono != null) ...[
                    _InfoRow(icon: Icons.phone, label: 'Teléfono', value: empleado.telefono!),
                    const SizedBox(height: 16),
                  ],
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Registrado',
                    value: '${empleado.createdAt.day}/${empleado.createdAt.month}/${empleado.createdAt.year}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}