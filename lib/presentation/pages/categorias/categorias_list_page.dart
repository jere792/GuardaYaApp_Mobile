import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/categorias_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';

class CategoriasListPage extends ConsumerStatefulWidget {
  const CategoriasListPage({super.key});

  @override
  ConsumerState<CategoriasListPage> createState() => _CategoriasListPageState();
}

class _CategoriasListPageState extends ConsumerState<CategoriasListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  void _cargar() {
    final usuario = ref.read(authProvider).usuario;
    final empresaId = usuario?.empresaId;
    if (empresaId != null && empresaId.isNotEmpty) {
      ref.read(categoriasProvider.notifier).cargarCategorias(empresaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriasProvider);
    final empresaColors = ref.watch(empresaColorsSyncProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final activas = state.categorias.where((c) => c.activo).length;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 48, 16, 20),
            decoration: BoxDecoration(
              color: empresaColors.primary,
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
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => context.push('/categorias/crear'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categorías',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$activas categorías activas',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.error!, style: TextStyle(color: colorScheme.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
                          ],
                        ),
                      )
                    : state.categorias.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.category, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay categorías',
                                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _cargar(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.categorias.length,
                              itemBuilder: (context, index) {
                                final cat = state.categorias[index];
                                return _CategoriaCard(
                                  categoria: cat,
                                  onTap: () => context.push('/categorias/${cat.id}'),
                                  onToggle: () => _confirmarDesactivar(cat),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _confirmarDesactivar(Categoria cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(cat.activo ? 'Desactivar categoría' : 'Reactivar categoría'),
        content: Text('${cat.nombre} será ${cat.activo ? 'desactivada' : 'reactivada'}. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(categoriasProvider.notifier).desactivarCategoria(cat.id);
              final st = ref.read(categoriasProvider);
              if (st.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(cat.activo ? 'Categoría desactivada' : 'Categoría reactivada')),
                );
                ref.read(categoriasProvider.notifier).resetSuccess();
              } else if (st.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(st.error!), backgroundColor: Colors.red),
                );
                ref.read(categoriasProvider.notifier).resetError();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: cat.activo ? Colors.red : Colors.green),
            child: Text(cat.activo ? 'Desactivar' : 'Reactivar', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _CategoriaCard({required this.categoria, required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = categoria.activo;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? colorScheme.primary : Colors.grey,
          foregroundColor: Colors.white,
          child: Icon(isActive ? Icons.category : Icons.category_outlined, size: 20),
        ),
        title: Text(
          categoria.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        subtitle: categoria.descripcion != null && categoria.descripcion!.isNotEmpty
            ? Text(categoria.descripcion!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.green : Colors.red),
              ),
            ),
            IconButton(
              icon: Icon(
                isActive ? Icons.block : Icons.check_circle_outline,
                color: isActive ? Colors.red : Colors.green,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}