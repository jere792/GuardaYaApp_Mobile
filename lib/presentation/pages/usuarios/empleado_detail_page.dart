import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class EmpleadoDetailPage extends ConsumerWidget {
  final String empleadoId;

  const EmpleadoDetailPage({super.key, required this.empleadoId});

  String _rolLabel(String rolId) {
    switch (rolId) {
      case 'super_admin':
        return 'Super Administrador';
      case 'admin':
        return 'Administrador';
      default:
        return 'Empleado';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosState = ref.watch(usuariosProvider);
    final empleado = usuariosState.usuarios.where((u) => u.id == empleadoId).firstOrNull;
    final empresaColors = ref.watch(empresaColorsSyncProvider);
    final rolActual = ref.watch(authProvider).usuario?.rolId ?? 'empleado';
    if (empleado == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Empleado')),
        body: const Center(child: Text('Empleado no encontrado')),
      );
    }

    final isActive = empleado.activo;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 48, 16, 24),
            decoration: BoxDecoration(
              color: empresaColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    if (rolActual != 'empleado')
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () => context.push('/empleados/editar/$empleadoId'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  child: Text(
                    (empleado.nombre.isNotEmpty ? empleado.nombre.substring(0, 1) : '?').toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  empleado.nombre,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _rolLabel(empleado.rolId),
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
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