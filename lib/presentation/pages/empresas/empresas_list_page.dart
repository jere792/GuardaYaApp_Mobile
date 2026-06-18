import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/presentation/providers/empresas_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class EmpresasListPage extends ConsumerStatefulWidget {
  const EmpresasListPage({super.key});

  @override
  ConsumerState<EmpresasListPage> createState() => _EmpresasListPageState();
}

class _EmpresasListPageState extends ConsumerState<EmpresasListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _mostrarInactivos = false;
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
    _currentPage = 0;
    ref.read(empresasProvider.notifier).cargarEmpresas();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(empresasProvider);
    final colorScheme = Theme.of(context).colorScheme;

    var filtered = state.empresas.where((e) => e.activo == !_mostrarInactivos).toList();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
        e.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (e.emailContacto?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (e.rucDni?.contains(_searchQuery) ?? false)
      ).toList();
    }
    filtered.sort((a, b) => a.activo == b.activo ? 0 : (a.activo ? -1 : 1));
    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final pagedItems = filtered.skip(_currentPage * _pageSize).take(_pageSize).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_mostrarInactivos ? 'Empresas Inactivas' : 'Empresas'),
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
          IconButton(
            icon: Icon(_mostrarInactivos ? Icons.business : Icons.delete_sweep),
            onPressed: () => setState(() => _mostrarInactivos = !_mostrarInactivos),
            tooltip: _mostrarInactivos ? 'Ver activos' : 'Ver inactivos',
          ),
          if (!_mostrarInactivos)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/admin/empresas/crear'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withValues(alpha: 0.08),
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
                  hintText: 'Buscar empresa...',
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
                              Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.error)),
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
                                Icon(Icons.business, size: 64, color: AppColors.primary.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ? 'Sin resultados' : 'No hay empresas',
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
                                final e = pagedItems[index];
                                return _EmpresaCard(
                                  empresa: e,
                                  onTap: () => context.push('/admin/empresas/${e.id}'),
                                  onEdit: () => context.push('/admin/empresas/editar/${e.id}'),
                                  onToggle: () => _confirmarDesactivar(e),
                                );
                              },
                            ),
                          ),
          ),
          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  void _confirmarDesactivar(Empresa e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(e.activo ? 'Desactivar empresa' : 'Reactivar empresa'),
        content: Text('${e.nombre} será ${e.activo ? 'desactivada' : 'reactivada'}. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(empresasProvider.notifier).desactivarEmpresa(e.id, reactivar: !e.activo);
              final st = ref.read(empresasProvider);
              if (st.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.activo ? 'Empresa desactivada' : 'Empresa reactivada')),
                );
                ref.read(empresasProvider.notifier).resetSuccess();
              } else if (st.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(st.error!), backgroundColor: Colors.red),
                );
                ref.read(empresasProvider.notifier).resetError();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: e.activo ? Colors.red : Colors.green),
            child: Text(e.activo ? 'Desactivar' : 'Reactivar', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EmpresaCard extends StatelessWidget {
  final Empresa empresa;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _EmpresaCard({
    required this.empresa,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = empresa.activo;
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
                child: Icon(isActive ? Icons.business : Icons.business_outlined, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(empresa.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.4),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (empresa.rucDni != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                empresa.rucDni!.length == 11 ? 'RUC' : 'DNI',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            empresa.rucDni ?? empresa.plan,
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
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
