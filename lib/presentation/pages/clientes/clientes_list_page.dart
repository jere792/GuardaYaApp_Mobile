import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/clientes_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class ClientesListPage extends ConsumerStatefulWidget {
  const ClientesListPage({super.key});

  @override
  ConsumerState<ClientesListPage> createState() => _ClientesListPageState();
}

class _ClientesListPageState extends ConsumerState<ClientesListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _mostrarInactivos = false;

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
    final usuario = ref.read(authProvider).usuario;
    final empresaId = usuario?.empresaId;
    if (empresaId != null && empresaId.isNotEmpty) {
      ref.read(clientesProvider.notifier).cargarClientes(empresaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientesProvider);

    var filtered = state.clientes.where((c) => c.activo == !_mostrarInactivos).toList();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) =>
        c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (c.telefono?.contains(_searchQuery) ?? false)
      ).toList();
    }
    filtered.sort((a, b) => a.activo == b.activo ? 0 : (a.activo ? -1 : 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(_mostrarInactivos ? 'Clientes Inactivos' : 'Clientes'),
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
            icon: Icon(_mostrarInactivos ? Icons.people : Icons.delete_sweep),
            onPressed: () => setState(() => _mostrarInactivos = !_mostrarInactivos),
            tooltip: _mostrarInactivos ? 'Ver activos' : 'Ver inactivos',
          ),
          if (!_mostrarInactivos)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => context.push('/clientes/crear'),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
                onChanged: (v) => setState(() => _searchQuery = v),
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
                                Icon(Icons.people_outline, size: 64, color: AppColors.primary.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ? 'Sin resultados' : (_mostrarInactivos ? 'No hay inactivos' : 'No hay clientes'),
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _cargar(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final c = filtered[index];
                                return _ClienteCard(
                                  cliente: c,
                                  onTap: () => context.push('/clientes/${c.id}'),
                                  onEdit: () => context.push('/clientes/editar/${c.id}'),
                                  onToggle: () => _confirmarDesactivar(c),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _confirmarDesactivar(Cliente c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c.activo ? 'Desactivar cliente' : 'Reactivar cliente'),
        content: Text('${c.nombre} será ${c.activo ? 'desactivado' : 'reactivado'}. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(clientesProvider.notifier).desactivarCliente(c.id);
              final st = ref.read(clientesProvider);
              if (st.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(c.activo ? 'Cliente desactivado' : 'Cliente reactivado')),
                );
                ref.read(clientesProvider.notifier).resetSuccess();
              } else if (st.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(st.error!), backgroundColor: Colors.red),
                );
                ref.read(clientesProvider.notifier).resetError();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: c.activo ? Colors.red : Colors.green),
            child: Text(c.activo ? 'Desactivar' : 'Reactivar', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _ClienteCard({
    required this.cliente,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = cliente.activo;

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
                backgroundColor: isActive ? AppColors.primary.withOpacity(0.15) : Colors.grey.shade200,
                foregroundColor: isActive ? AppColors.primary : Colors.grey,
                child: Text(
                  (cliente.nombre.isNotEmpty ? cliente.nombre.substring(0, 1) : '?').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.4),
                        )),
                    if (cliente.telefono != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(cliente.telefono!,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
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

extension on Color {
  Color get shade700 {
    if (this == AppColors.error) return const Color(0xFFC62828);
    return this;
  }
}
