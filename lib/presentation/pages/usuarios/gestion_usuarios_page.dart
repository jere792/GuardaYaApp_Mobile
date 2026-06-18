import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class GestionUsuariosPage extends ConsumerStatefulWidget {
  const GestionUsuariosPage({super.key});

  @override
  ConsumerState<GestionUsuariosPage> createState() => _GestionUsuariosPageState();
}

class _GestionUsuariosPageState extends ConsumerState<GestionUsuariosPage> {
  bool _mostrarInactivos = false;
  int _currentPage = 0;
  int get _pageSize => 3;
  Map<String, String> _empresaMap = {};

  bool _showFilters = false;
  final _searchController = TextEditingController();
  String _rolFilter = '';
  String? _empresaFilter;
  Map<String, int> _empresaLimiteMap = {};

  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarUsuarios());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarEmpresas() async {
    try {
      final data = await SupabaseService.from('empresas')
          .select('id, nombre, limite_usuarios');
      final map = <String, String>{};
      final limiteMap = <String, int>{};
      for (final e in data as List) {
        map[e['id'] as String] = e['nombre'] as String;
        limiteMap[e['id'] as String] = (e['limite_usuarios'] ?? 0) as int;
      }
      if (mounted) setState(() {
        _empresaMap = map;
        _empresaLimiteMap = limiteMap;
      });
    } catch (_) {}
  }

  void _cargarUsuarios() {
    setState(() => _currentPage = 0);
    ref.read(usuariosProvider.notifier).cargarEmpleados(null, 'super_admin');
  }

  String _rolLabel(String rolId) {
    switch (rolId.toLowerCase()) {
      case 'super_admin':
      case 'superadministrador':
      case 'c63abe3d-5de8-442b-b8d8-9738ad9a7be5':
        return 'Super Admin';
      case 'admin':
      case 'administrador':
      case '6801325e-df02-4391-a882-66247e664dcf':
        return 'Admin';
      case 'empleado':
      case '77cdd9df-e7fe-4984-9bd9-9ab2168abf5b':
        return 'Empleado';
      default:
        final id = rolId.toLowerCase();
        if (id.contains('admin')) return 'Admin';
        if (id.contains('super')) return 'Super Admin';
        return 'Empleado';
    }
  }

  String _rolIdForFilter(String rolId) {
    switch (rolId.toLowerCase()) {
      case 'super_admin':
      case 'superadministrador':
      case 'c63abe3d-5de8-442b-b8d8-9738ad9a7be5':
        return 'super_admin';
      case 'admin':
      case 'administrador':
      case '6801325e-df02-4391-a882-66247e664dcf':
        return 'admin';
      case 'empleado':
      case '77cdd9df-e7fe-4984-9bd9-9ab2168abf5b':
        return 'empleado';
      default:
        final id = rolId.toLowerCase();
        if (id.contains('admin')) return 'admin';
        if (id.contains('super')) return 'super_admin';
        return 'empleado';
    }
  }

  String _empresaName(String? empresaId) {
    if (empresaId == null) return 'Super Admin';
    return _empresaMap[empresaId] ?? 'Super Admin';
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _rolFilter = '';
      _empresaFilter = null;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usuariosState = ref.watch(usuariosProvider);

    final todos = usuariosState.usuarios;

    var filtered = todos.where((e) => e.activo == !_mostrarInactivos);
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((e) =>
        e.nombre.toLowerCase().contains(q) ||
        e.username.toLowerCase().contains(q) ||
        (e.telefono?.toLowerCase().contains(q) ?? false));
    }
    if (_rolFilter.isNotEmpty) {
      filtered = filtered.where((e) => _rolIdForFilter(e.rolId) == _rolFilter);
    }
    if (_empresaFilter != null) {
      filtered = filtered.where((e) => e.empresaId == _empresaFilter);
    }
    final filteredList = filtered.toList();

    final grouped = <String?, List<Usuario>>{};
    for (final u in filteredList) {
      grouped.putIfAbsent(u.empresaId, () => []).add(u);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final nameA = _empresaName(a);
        final nameB = _empresaName(b);
        return nameA.compareTo(nameB);
      });

    final sections = <List<Widget>>[];
    for (final key in sortedKeys) {
      final users = grouped[key]!;
      final limite = key != null ? (_empresaLimiteMap[key] ?? 0) : 0;
      final sectionWidgets = <Widget>[
        _SectionHeader(
          empresaName: _empresaName(key),
          userCount: users.length,
          limiteUsuarios: limite,
        ),
      ];
      for (int i = 0; i < users.length; i += 2) {
        final u0 = users[i];
        final children = <Widget>[
          Expanded(
            child: _UserCard(
              usuario: u0,
              empresaNombre: _empresaName(u0.empresaId),
              rolLabel: _rolLabel(u0.rolId),
              onDesactivar: () => _confirmarDesactivar(context, u0),
              onVerDetalle: () => context.push('/empleados/detalle/${u0.id}'),
              onEditar: () => context.push('/empleados/editar/${u0.id}'),
              onCambiarPassword: () => _mostrarDialogCambiarPassword(u0),
            ),
          ),
          const SizedBox(width: 12),
        ];
        if (i + 1 < users.length) {
          final u1 = users[i + 1];
          children.add(
            Expanded(
              child: _UserCard(
                usuario: u1,
                empresaNombre: _empresaName(u1.empresaId),
                rolLabel: _rolLabel(u1.rolId),
              onDesactivar: () => _confirmarDesactivar(context, u1),
              onVerDetalle: () => context.push('/empleados/detalle/${u1.id}'),
              onEditar: () => context.push('/empleados/editar/${u1.id}'),
              onCambiarPassword: () => _mostrarDialogCambiarPassword(u1),
              ),
            ),
          );
        } else {
          children.add(const Expanded(child: SizedBox.shrink()));
        }
        sectionWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: children),
        ));
      }
      sections.add(sectionWidgets);
    }

    final totalPages = sections.isEmpty ? 1 : (sections.length / _pageSize).ceil();
    final pageSections = sections.skip(_currentPage * _pageSize).take(_pageSize).toList();
    final pagedWidgets = pageSections.expand((s) => s).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_mostrarInactivos ? 'Usuarios Inactivos' : 'Gesti\u00f3n de Usuarios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: Icon(_mostrarInactivos ? Icons.people : Icons.delete_sweep),
            onPressed: () => setState(() { _mostrarInactivos = !_mostrarInactivos; _currentPage = 0; }),
            tooltip: _mostrarInactivos ? 'Ver activos' : 'Ver inactivos',
          ),
          if (!_mostrarInactivos)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => context.push('/admin/usuarios/crear'),
              tooltip: 'Crear usuario',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterPanel(),
          Expanded(
            child: usuariosState.isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : usuariosState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(usuariosState.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cargarUsuarios,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : pagedWidgets.isEmpty
                        ? _EmptyState(
                            icon: _mostrarInactivos ? Icons.delete_sweep : Icons.people_outline,
                            message: _mostrarInactivos
                                ? 'No hay usuarios inactivos'
                                : 'No hay usuarios registrados',
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _cargarUsuarios(),
                            color: AppColors.primary,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              children: pagedWidgets,
                            ),
                          ),
          ),
          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage--),
                  ),
                  Text('P\u00e1gina ${_currentPage + 1} de $totalPages',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
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

  Widget _buildFilterPanel() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Column(
        children: [
          _FilterField(
            controller: _searchController,
            hint: 'Buscar por nombre, usuario o tel\u00e9fono',
            icon: Icons.search,
            onChanged: (_) => setState(() => _currentPage = 0),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _rolFilter.isEmpty ? null : _rolFilter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _rolFilter.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
                    color: _rolFilter.isNotEmpty ? AppColors.primary : colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rol',
                    hintStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: _rolFilter.isNotEmpty
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos los roles')),
                    DropdownMenuItem(value: 'empleado', child: Text('Empleado', style: TextStyle(color: colorScheme.onSurface))),
                    DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: colorScheme.onSurface))),
                    DropdownMenuItem(value: 'super_admin', child: Text('Super Admin', style: TextStyle(color: colorScheme.onSurface))),
                  ],
                  onChanged: (v) => setState(() { _rolFilter = v ?? ''; _currentPage = 0; }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _empresaFilter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _empresaFilter != null ? FontWeight.w600 : FontWeight.w400,
                    color: _empresaFilter != null ? AppColors.primary : colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Empresa',
                    hintStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: _empresaFilter != null
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas las empresas')),
                    ..._empresaMap.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: TextStyle(color: colorScheme.onSurface)),
                    )),
                  ],
                  onChanged: (v) => setState(() { _empresaFilter = v; _currentPage = 0; }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _limpiarFiltros,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                side: BorderSide(color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
              ),
              child: const Text('Limpiar'),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogCambiarPassword(Usuario u) {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar contrase\u00f1a - ${u.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva contrase\u00f1a *',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar contrase\u00f1a *',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final pwd = passwordCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();
              if (pwd.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La contrase\u00f1a debe tener al menos 6 caracteres')),
                );
                return;
              }
              if (pwd != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Las contrase\u00f1as no coinciden')),
                );
                return;
              }
              Navigator.pop(ctx);
              await ref.read(usuariosProvider.notifier).cambiarPassword(u.id, pwd);
              final st = ref.read(usuariosProvider);
              if (st.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contrase\u00f1a cambiada exitosamente')),
                );
                ref.read(usuariosProvider.notifier).resetSuccess();
              } else if (st.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(st.error!), backgroundColor: Colors.red),
                );
                ref.read(usuariosProvider.notifier).resetError();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _confirmarDesactivar(BuildContext context, Usuario u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_mostrarInactivos ? 'Reactivar usuario' : 'Desactivar usuario'),
        content: Text(
          _mostrarInactivos
              ? '\u00bfReactivar a ${u.nombre}?'
              : '\u00bfDesactivar a ${u.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(usuariosProvider.notifier).desactivarEmpleado(u.id, reactivar: _mostrarInactivos);
              final state = ref.read(usuariosProvider);
              if (state.success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _mostrarInactivos ? 'Usuario reactivado' : 'Usuario desactivado',
                    ),
                  ),
                );
                ref.read(usuariosProvider.notifier).resetSuccess();
              } else if (state.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
                );
                ref.read(usuariosProvider.notifier).resetError();
              }
              _cargarUsuarios();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _mostrarInactivos ? Colors.green : Colors.red,
            ),
            child: Text(
              _mostrarInactivos ? 'Reactivar' : 'Desactivar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  const _FilterField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String empresaName;
  final int userCount;
  final int limiteUsuarios;

  const _SectionHeader({
    required this.empresaName,
    required this.userCount,
    this.limiteUsuarios = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final limiteStr = limiteUsuarios > 0 ? ' / $limiteUsuarios' : '';
    final color = limiteUsuarios > 0 && userCount > limiteUsuarios
        ? Colors.red
        : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Icon(Icons.business, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              empresaName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$userCount$limiteStr usuario${userCount == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Usuario usuario;
  final String empresaNombre;
  final String rolLabel;
  final VoidCallback onDesactivar;
  final VoidCallback onVerDetalle;
  final VoidCallback onEditar;
  final VoidCallback onCambiarPassword;

  const _UserCard({
    required this.usuario,
    required this.empresaNombre,
    required this.rolLabel,
    required this.onDesactivar,
    required this.onVerDetalle,
    required this.onEditar,
    required this.onCambiarPassword,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = usuario.activo;
    final isSuperAdmin = usuario.empresaId == null;

    return Card(
      elevation: isActive ? 2 : 1,
      color: isActive ? colorScheme.surface : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isActive
            ? BorderSide.none
            : BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isActive
                    ? (isSuperAdmin ? Colors.deepPurple : AppColors.primary)
                    : Colors.grey,
                foregroundColor: Colors.white,
                child: Text(
                  (usuario.nombre.isNotEmpty
                          ? usuario.nombre.substring(0, 1)
                          : '?')
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              usuario.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            Text(
              usuario.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            Text(
              '$rolLabel \u2022 $empresaNombre',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withValues(alpha: isActive ? 1.0 : 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onDesactivar,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isActive ? Icons.delete_outline : Icons.restore_from_trash,
                      size: 20,
                      color: isActive ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'Detalle',
                    onTap: onVerDetalle,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    onTap: onEditar,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                icon: Icons.key,
                label: 'Cambiar Contrase\u00f1a',
                onTap: onCambiarPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
