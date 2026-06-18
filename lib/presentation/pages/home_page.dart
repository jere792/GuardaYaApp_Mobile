import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/connectivity_provider.dart';
import 'package:guardaya_app/presentation/providers/theme_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final rolId = usuario?.rolId ?? 'empleado';
    final isOffline = authState.isOffline;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(connectivityProvider, (previous, next) {
      if (previous != next) {
        ref.read(authProvider.notifier).setOffline(!next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('GuardaYa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          if (isOffline)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Offline', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
      body: _buildContentByRole(rolId, usuario, isOffline, context),
    );
  }

  Widget _buildContentByRole(String rolId, dynamic usuario, bool isOffline, BuildContext context) {
    switch (rolId) {
      case 'super_admin':
        return SuperAdminView(usuario: usuario, isOffline: isOffline);
      case 'admin':
        return AdminView(usuario: usuario, isOffline: isOffline);
      case 'empleado':
        return EmpleadoView(usuario: usuario, isOffline: isOffline);
      default:
        return EmpleadoView(usuario: usuario, isOffline: isOffline);
    }
  }
}

class _HeaderWelcome extends StatelessWidget {
  final dynamic usuario;
  final String rolLabel;

  const _HeaderWelcome({required this.usuario, required this.rolLabel});

  @override
  Widget build(BuildContext context) {
    final initial = (usuario?.nombre?.isNotEmpty == true ? usuario.nombre.substring(0, 1) : '?').toUpperCase();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initial,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Hola, ${usuario?.nombre ?? "Usuario"}!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(rolLabel,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Menu card simplificado sin colores personalizados ---
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 4 : 2,
      color: isDark ? colorScheme.surface : colorScheme.surface,
      shadowColor: isDark ? Colors.black26 : Colors.black12,
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
                      ? AppColors.primary.withOpacity(isDark ? 0.25 : 0.1)
                      : (isDark ? Colors.white.withOpacity(0.05) : AppColors.background),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: isEnabled ? AppColors.primary : Colors.grey.shade400),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? colorScheme.onSurface : Colors.grey.shade400)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: isEnabled ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey.shade400)),
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

  const _MenuGrid({required this.items, this.crossAxisCount = 2});

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

// --- Sección logout reutilizable ---
class _LogoutSection extends ConsumerWidget {
  const _LogoutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: isDark ? 4 : 2,
      color: colorScheme.surface,
      shadowColor: isDark ? Colors.black26 : Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(isDark ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, size: 24, color: AppColors.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cerrar sesión',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    const SizedBox(height: 2),
                    Text('Salir de la app',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.error, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Super Admin ---
class SuperAdminView extends StatelessWidget {
  final dynamic usuario;
  final bool isOffline;
  const SuperAdminView({super.key, required this.usuario, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return _buildContent(context,
        usuario: usuario,
        rolLabel: 'Super Administrador',
        isOffline: isOffline,
        sections: [
          _Section(title: 'Gestión', items: [
            _MenuCard(icon: Icons.business, title: 'Empresas', subtitle: 'Gestionar empresas', onTap: () => context.push('/admin/empresas')),
            _MenuCard(icon: Icons.people, title: 'Usuarios', subtitle: 'Gesti\u00f3n de usuarios', onTap: () => context.push('/admin/usuarios')),
            _MenuCard(icon: Icons.analytics, title: 'Reportes', subtitle: 'Métricas globales', onTap: () => context.push('/reportes')),
            _MenuCard(icon: Icons.settings, title: 'Configuración', subtitle: 'Ajustes del sistema'),
          ]),
        ]);
  }
}

// --- Admin ---
class AdminView extends StatelessWidget {
  final dynamic usuario;
  final bool isOffline;
  const AdminView({super.key, required this.usuario, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return _buildContent(context,
        usuario: usuario,
        rolLabel: 'Administrador',
        isOffline: isOffline,
        sections: [
          _Section(title: 'Ventas', items: [
            _MenuCard(
                icon: Icons.point_of_sale,
                title: 'Ventas de Hoy',
                subtitle: 'Ver y gestionar',
                onTap: () => context.push('/ventas')),
            _MenuCard(
                icon: Icons.add_circle,
                title: 'Nueva Venta',
                subtitle: 'Registrar con OCR',
                onTap: () => context.push('/ventas/registrar')),
          ]),
          _Section(title: 'Gestión', items: [
            _MenuCard(icon: Icons.inventory_2, title: 'Productos', subtitle: 'Inventario y stock', onTap: () => context.push('/productos')),
            _MenuCard(icon: Icons.people, title: 'Empleados', subtitle: 'Gestionar equipo', onTap: () => context.push('/empleados')),
            _MenuCard(icon: Icons.category, title: 'Categorías', subtitle: 'Gestionar categorías', onTap: () => context.push('/categorias')),
            _MenuCard(icon: Icons.people_outline, title: 'Clientes', subtitle: 'Gestionar clientes', onTap: () => context.push('/clientes')),
            _MenuCard(icon: Icons.analytics, title: 'Reportes', subtitle: 'Métricas', onTap: () => context.push('/reportes')),
          ]),
        ]);
  }
}

// --- Empleado ---
class EmpleadoView extends StatelessWidget {
  final dynamic usuario;
  final bool isOffline;
  const EmpleadoView({super.key, required this.usuario, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return _buildContent(context,
        usuario: usuario,
        rolLabel: 'Empleado',
        isOffline: isOffline,
        sections: [
          _Section(title: 'Ventas', items: [
            _MenuCard(icon: Icons.list, title: 'Lista de Ventas', subtitle: 'Ver todas las ventas', onTap: () => context.push('/ventas')),
            _MenuCard(
                icon: Icons.add_circle,
                title: 'Registrar Venta',
                subtitle: 'Nueva venta con OCR',
                onTap: () => context.push('/ventas/registrar')),
          ]),
          _Section(title: 'Gestión', items: [
            _MenuCard(icon: Icons.inventory_2, title: 'Productos', subtitle: 'Inventario y stock', onTap: () => context.push('/productos')),
            _MenuCard(icon: Icons.category, title: 'Categorías', subtitle: 'Gestionar categorías', onTap: () => context.push('/categorias')),
            _MenuCard(icon: Icons.people_outline, title: 'Clientes', subtitle: 'Gestionar clientes', onTap: () => context.push('/clientes')),
          ]),
        ]);
  }
}

// --- Widgets auxiliares ---

class _Section extends StatelessWidget {
  final String title;
  final List<_MenuCard> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        _MenuGrid(items: items),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _buildContent(BuildContext context,
    {required dynamic usuario, required String rolLabel, required bool isOffline, required List<_Section> sections}) {
  return ListView(
    padding: EdgeInsets.zero,
    children: [
      _HeaderWelcome(usuario: usuario, rolLabel: rolLabel),
      const SizedBox(height: 20),
      if (isOffline) const _OfflineBanner(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sections,
            const _DarkModeTile(),
            const SizedBox(height: 16),
            const _LogoutSection(),
          ],
        ),
      ),
      const SizedBox(height: 80),
    ],
  );
}

class _DarkModeTile extends ConsumerWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        elevation: isDark ? 4 : 2,
        color: colorScheme.surface,
        shadowColor: isDark ? Colors.black26 : Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(isDark ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 28, color: AppColors.warning),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                activeColor: AppColors.warning,
                activeTrackColor: AppColors.warning.withOpacity(0.3),
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
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Modo sin conexión. Las ventas se guardarán localmente.',
                style: TextStyle(color: AppColors.warning, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
