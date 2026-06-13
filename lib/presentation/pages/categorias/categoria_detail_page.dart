import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/categorias_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';

class CategoriaDetailPage extends ConsumerWidget {
  final String categoriaId;

  const CategoriaDetailPage({super.key, required this.categoriaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriasProvider);
    final cat = state.categorias.where((c) => c.id == categoriaId).firstOrNull;
    final empresaColors = ref.watch(empresaColorsSyncProvider);
    final rolActual = ref.read(authProvider).usuario?.rolId ?? 'empleado';
    if (cat == null) {
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            const Expanded(child: Center(child: Text('Categoría no encontrada'))),
          ],
        ),
      );
    }

    final isActive = cat.activo;

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
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    if (rolActual != 'empleado')
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () => context.push('/categorias/editar/${cat.id}'),
                      ),
                  ],
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Icon(Icons.category, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  cat.nombre,
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
                    isActive ? 'Activa' : 'Inactiva',
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
                  if (cat.descripcion != null && cat.descripcion!.isNotEmpty) ...[
                    _InfoTile(icon: Icons.description, label: 'Descripción', value: cat.descripcion!),
                    const SizedBox(height: 16),
                  ],
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Creada',
                    value: '${cat.createdAt.day}/${cat.createdAt.month}/${cat.createdAt.year}',
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