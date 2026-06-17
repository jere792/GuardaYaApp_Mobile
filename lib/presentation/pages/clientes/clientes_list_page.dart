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
  bool _mostrarInactivos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
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
    final colorScheme = Theme.of(context).colorScheme;

    final todos = state.clientes;
    final clientes = todos.where((c) => c.activo == !_mostrarInactivos).toList();
    final activos = todos.where((c) => c.activo).length;
    final inactivos = todos.length - activos;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 48, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                      onPressed: () {
                        if (_mostrarInactivos) {
                          setState(() => _mostrarInactivos = false);
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _mostrarInactivos ? Icons.people : Icons.delete_sweep,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => _mostrarInactivos = !_mostrarInactivos),
                      tooltip: _mostrarInactivos ? 'Ver activos' : 'Ver inactivos',
                    ),
                    if (!_mostrarInactivos)
                      IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        onPressed: () => context.push('/clientes/crear'),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _mostrarInactivos ? 'Clientes Inactivos' : 'Clientes',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatChip(
                        icon: Icons.check_circle,
                        label: '$activos activos',
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.cancel,
                        label: '$inactivos inactivos',
                        color: Colors.redAccent,
                      ),
                    ],
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
                    : clientes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  _mostrarInactivos ? 'No hay clientes inactivos' : 'No hay clientes',
                                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _cargar(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: clientes.length,
                              itemBuilder: (context, index) {
                                final c = clientes[index];
                                return _ClienteCard(
                                  cliente: c,
                                  onTap: () => context.push('/clientes/${c.id}'),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _ClienteCard({required this.cliente, required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = cliente.activo;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? colorScheme.primary : Colors.grey,
          foregroundColor: Colors.white,
          child: Text(
            (cliente.nombre.isNotEmpty ? cliente.nombre.substring(0, 1) : '?').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          cliente.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        subtitle: cliente.telefono != null
            ? Text(cliente.telefono!, style: TextStyle(color: colorScheme.onSurfaceVariant))
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