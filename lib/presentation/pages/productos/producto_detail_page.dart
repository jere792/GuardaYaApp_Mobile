import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/productos_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class ProductoDetailPage extends ConsumerWidget {
  final String productoId;

  const ProductoDetailPage({super.key, required this.productoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productosProvider);
    final p = state.productos.where((p) => p.id == productoId).firstOrNull;
    final rolActual = ref.read(authProvider).usuario?.rolId ?? 'empleado';

    if (p == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Producto'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: const Center(child: Text('Producto no encontrado')),
      );
    }

    final isActive = p.activo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
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
              onPressed: () => context.push('/productos/editar/${p.id}'),
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
                  child: const Icon(Icons.inventory_2, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(p.nombre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('S/ ${p.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
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
                  if (p.descripcion != null && p.descripcion!.isNotEmpty) ...[
                    _InfoTile(icon: Icons.description, label: 'Descripción', value: p.descripcion!),
                    const SizedBox(height: 16),
                  ],
                  if (p.categoriaId != null) ...[
                    _InfoTile(icon: Icons.category, label: 'Categoría', value: p.categoriaId!),
                    const SizedBox(height: 16),
                  ],
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Creado',
                    value: '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}
