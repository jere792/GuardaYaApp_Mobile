import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/empresas_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class EmpresaDetailPage extends ConsumerWidget {
  final String empresaId;

  const EmpresaDetailPage({super.key, required this.empresaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(empresasProvider);
    final e = state.empresas.where((e) => e.id == empresaId).firstOrNull;
    if (e == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Empresa'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: const Center(child: Text('Empresa no encontrada')),
      );
    }

    final isActive = e.activo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Empresa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/admin/empresas/editar/${e.id}'),
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
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(Icons.business, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  e.nombre,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  e.slug,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                  if (e.rucDni != null) ...[
                    _InfoTile(icon: Icons.badge, label: 'RUC / DNI', value: e.rucDni!),
                    const SizedBox(height: 16),
                  ],
                  if (e.emailContacto != null) ...[
                    _InfoTile(icon: Icons.email, label: 'Email', value: e.emailContacto!),
                    const SizedBox(height: 16),
                  ],
                  if (e.telefono != null) ...[
                    _InfoTile(icon: Icons.phone, label: 'Teléfono', value: e.telefono!),
                    const SizedBox(height: 16),
                  ],
                  if (e.direccion != null) ...[
                    _InfoTile(icon: Icons.location_on, label: 'Dirección', value: e.direccion!),
                    const SizedBox(height: 16),
                  ],
                  _InfoTile(
                    icon: Icons.verified,
                    label: 'Plan',
                    value: e.plan,
                  ),
                  const SizedBox(height: 16),
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Creada',
                    value: '${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year}',
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
        Icon(icon, size: 20, color: AppColors.primary),
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
