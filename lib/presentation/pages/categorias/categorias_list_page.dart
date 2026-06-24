import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/categorias_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class CategoriasListPage extends ConsumerStatefulWidget {
  const CategoriasListPage({super.key});

  @override
  ConsumerState<CategoriasListPage> createState() => _CategoriasListPageState();
}

class _CategoriasListPageState extends ConsumerState<CategoriasListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  int get _pageSize => 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargar() {
    setState(() => _currentPage = 0);
    final usuario = ref.read(authProvider).usuario;
    final empresaId = usuario?.empresaId;
    if (empresaId != null && empresaId.isNotEmpty) {
      ref.read(categoriasProvider.notifier).cargarCategorias(empresaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriasProvider);
    final colorScheme = Theme.of(context).colorScheme;

    var filtered = List<Categoria>.from(state.categorias);
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) =>
        c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (c.descripcion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    filtered.sort((a, b) => a.activo == b.activo ? 0 : (a.activo ? -1 : 1));

    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final pagedItems = filtered.skip(_currentPage * _pageSize).take(_pageSize).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/categorias/crear'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.08),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar categoría...',
                  hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, size: 20, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _currentPage = 0;
                }),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : state.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: AppColors.error, size: 48),
                              const SizedBox(height: 16),
                              Text('Error al cargar', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.error.shade700)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _cargar,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.category, size: 64, color: AppColors.primary.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ? 'Sin resultados' : 'No hay categorías',
                                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _cargar(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: pagedItems.length,
                              itemBuilder: (context, index) {
                                final cat = pagedItems[index];
                                return _CategoriaCard(
                                  categoria: cat,
                                  onTap: () => context.push('/categorias/${cat.id}'),
                                  onEdit: () => context.push('/categorias/editar/${cat.id}'),
                                  onToggle: () => _confirmarDesactivar(cat),
                                );
                              },
                            ),
                          ),
          ),
          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage--),
                  ),
                  Text(
                    'Página ${_currentPage + 1} de $totalPages',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage >= totalPages - 1 ? null : () => setState(() => _currentPage++),
                  ),
                ],
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
              await ref.read(categoriasProvider.notifier).desactivarCategoria(cat.id, reactivar: !cat.activo);
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
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _CategoriaCard({
    required this.categoria,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = categoria.activo;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: isActive ? 2 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isActive ? AppColors.primary.withOpacity(0.15) : colorScheme.surfaceContainerHighest,
                foregroundColor: isActive ? AppColors.primary : Colors.grey,
                child: Icon(isActive ? Icons.category : Icons.category_outlined, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoria.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.4),
                        )),
                    if (categoria.descripcion != null && categoria.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(categoria.descripcion!,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.green : Colors.red)),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: Icon(isActive ? Icons.delete_outline : Icons.restore_from_trash,
                    size: 20, color: isActive ? AppColors.error : AppColors.success),
                onPressed: onToggle,
                tooltip: isActive ? 'Desactivar' : 'Reactivar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Color {
  Color get shade700 {
    if (this == AppColors.error) return const Color(0xFFC62828);
    return this;
  }
}
