import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/connectivity_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';
import 'package:guardaya_app/presentation/providers/theme_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final rolId = usuario?.rolId ?? 'empleado';
    final isOffline = authState.isOffline;
    final empresaColors = ref.watch(empresaColorsSyncProvider);

    // Escuchar cambios de conectividad para actualizar el estado offline
    ref.listen(connectivityProvider, (previous, next) {
      if (previous != next) {
        ref.read(authProvider.notifier).setOffline(!next);
      }
    });

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: empresaColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'GuardaYa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isOffline)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Offline',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildContentByRole(rolId, usuario, isOffline, empresaColors, context),
    );
  }

  Widget _buildContentByRole(
    String rolId,
    dynamic usuario,
    bool isOffline,
    EmpresaColors colors,
    BuildContext context,
  ) {
    switch (rolId) {
      case 'super_admin':
        return SuperAdminView(usuario: usuario, isOffline: isOffline, colors: colors);
      case 'admin':
        return AdminView(usuario: usuario, isOffline: isOffline, colors: colors);
      case 'empleado':
        return EmpleadoView(usuario: usuario, isOffline: isOffline, colors: colors);
      default:
        return EmpleadoView(usuario: usuario, isOffline: isOffline, colors: colors);
    }
  }
}

class _HeaderWelcome extends StatelessWidget {
  final dynamic usuario;
  final EmpresaColors colors;
  final String rolLabel;

  const _HeaderWelcome({
    required this.usuario,
    required this.colors,
    required this.rolLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (usuario?.nombre?.isNotEmpty == true
                        ? usuario.nombre.substring(0, 1)
                        : '?')
                    .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${usuario?.nombre ?? 'Usuario'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rolLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? colorScheme.surface : colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isEnabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? color.withOpacity(isDark ? 0.2 : 0.1)
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isEnabled ? color : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? colorScheme.onSurface : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isEnabled ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  final List<_MenuCard> items;
  final int crossAxisCount;

  const _MenuGrid({
    required this.items,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: items,
    );
  }
}

class SuperAdminView extends StatelessWidget {
  final dynamic usuario;
  final bool isOffline;
  final EmpresaColors colors;

  const SuperAdminView({
    super.key,
    required this.usuario,
    required this.isOffline,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeaderWelcome(
          usuario: usuario,
          colors: colors,
          rolLabel: 'Super Administrador',
        ),
        const SizedBox(height: 20),
        if (isOffline) const _OfflineBanner(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _MenuGrid(
                items: [
                  _MenuCard(
                    icon: Icons.business,
                    title: 'Empresas',
                    subtitle: 'Gestionar empresas',
                    color: Colors.blue,
                  ),
                  _MenuCard(
                    icon: Icons.people,
                    title: 'Usuarios',
                    subtitle: 'Todos los empleados',
                    color: colors.primary,
                    onTap: () => context.push('/empleados'),
                  ),
                  _MenuCard(
                    icon: Icons.analytics,
                    title: 'Reportes',
                    subtitle: 'Métricas globales',
                    color: Colors.purple,
                  ),
                  _MenuCard(
                    icon: Icons.settings,
                    title: 'Configuración',
                    subtitle: 'Ajustes del sistema',
                    color: Colors.grey,
                  ),
                ],
              ),
              const _DarkModeTile(),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) => _MenuCard(
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de la app',
                  color: Colors.red,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class AdminView extends StatelessWidget {
  final dynamic usuario;
  final bool isOffline;
  final EmpresaColors colors;

  const AdminView({
    super.key,
    required this.usuario,
    required this.isOffline,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeaderWelcome(
          usuario: usuario,
          colors: colors,
          rolLabel: 'Administrador',
        ),
        const SizedBox(height: 20),
        if (isOffline) const _OfflineBanner(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ventas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _MenuGrid(
                items: [
                  _MenuCard(
                    icon: Icons.point_of_sale,
                    title: 'Ventas de Hoy',
                    subtitle: 'Ver y gestionar',
                    color: Colors.green,
                    onTap: () => context.push('/ventas'),
                  ),
                  _MenuCard(
                    icon: Icons.add_circle,
                    title: 'Nueva Venta',
                    subtitle: 'Registrar venta',
                    color: colors.primary,
                    onTap: () => context.push('/ventas/registrar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Gestión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _MenuGrid(
                items: [
                  _MenuCard(
                    icon: Icons.inventory_2,
                    title: 'Productos',
                    subtitle: 'Inventario y stock',
                    color: Colors.orange,
                    isEnabled: false,
                  ),
                  _MenuCard(
                    icon: Icons.people,
                    title: 'Empleados',
                    subtitle: 'Gestionar equipo',
                    color: Colors.blue,
                    onTap: () => context.push('/empleados'),
                  ),
                  _MenuCard(
                    icon: Icons.analytics,
                    title: 'Reportes',
                    subtitle: 'Métricas de tu empresa',
                    color: Colors.purple,
                    isEnabled: false,
                  ),
                  _MenuCard(
                    icon: Icons.store,
                    title: 'Mi Empresa',
                    subtitle: 'Configuración',
                    color: Colors.teal,
                    isEnabled: false,
                  ),
                ],
              ),
              const _DarkModeTile(),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) => _MenuCard(
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de la app',
                  color: Colors.red,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class EmpleadoView extends StatelessWidget {
  final dynamic usuario;
  final bool isOffline;
  final EmpresaColors colors;

  const EmpleadoView({
    super.key,
    required this.usuario,
    required this.isOffline,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeaderWelcome(
          usuario: usuario,
          colors: colors,
          rolLabel: 'Empleado',
        ),
        const SizedBox(height: 20),
        if (isOffline) const _OfflineBanner(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ventas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _MenuGrid(
                items: [
                  _MenuCard(
                    icon: Icons.add_circle,
                    title: 'Registrar Venta',
                    subtitle: 'Nueva venta con OCR',
                    color: colors.primary,
                    onTap: () => context.push('/ventas/registrar'),
                  ),
                  _MenuCard(
                    icon: Icons.search,
                    title: 'Buscar Venta',
                    subtitle: 'Por código o teléfono',
                    color: Colors.blue,
                    onTap: () => context.push('/ventas/buscar'),
                  ),
                  _MenuCard(
                    icon: Icons.list,
                    title: 'Lista de Ventas',
                    subtitle: 'Ver todas las ventas',
                    color: Colors.green,
                    onTap: () => context.push('/ventas'),
                  ),
                  _MenuCard(
                    icon: Icons.receipt_long,
                    title: 'Mis Ventas',
                    subtitle: 'Historial personal',
                    color: Colors.purple,
                    isEnabled: false,
                  ),
                ],
              ),
              const _DarkModeTile(),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) => _MenuCard(
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de la app',
                  color: Colors.red,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _DarkModeTile extends ConsumerWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        elevation: 2,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 28,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                activeColor: Colors.amber,
                activeTrackColor: Colors.amber.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo sin conexión. Las ventas se guardarán localmente.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
