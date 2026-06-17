import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/clientes_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class ClienteDetailPage extends ConsumerWidget {
  final String clienteId;

  const ClienteDetailPage({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientesProvider);
    final c = state.clientes.where((c) => c.id == clienteId).firstOrNull;
    if (c == null) {
      return Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(4, 48, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Expanded(child: Center(child: Text('Cliente no encontrado'))),
          ],
        ),
      );
    }

    final isActive = c.activo;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 48, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: () => context.push('/clientes/editar/${c.id}'),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  child: Text(
                    (c.nombre.isNotEmpty ? c.nombre.substring(0, 1) : '?').toUpperCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  c.nombre,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.greenAccent.withValues(alpha: 0.2)
                        : Colors.redAccent.withValues(alpha: 0.2),
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
                  if (c.telefono != null) ...[
                    _InfoTile(icon: Icons.phone, label: 'Teléfono', value: c.telefono!),
                    const SizedBox(height: 16),
                  ],
                  if (c.email != null) ...[
                    _InfoTile(icon: Icons.email, label: 'Email', value: c.email!),
                    const SizedBox(height: 16),
                  ],
                  if (c.direccion != null) ...[
                    _InfoTile(icon: Icons.location_on, label: 'Dirección', value: c.direccion!),
                    const SizedBox(height: 16),
                  ],
                  if (c.notas != null) ...[
                    _InfoTile(icon: Icons.notes, label: 'Notas', value: c.notas!),
                    const SizedBox(height: 16),
                  ],
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Registrado',
                    value: '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

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
            Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}