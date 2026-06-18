import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/presentation/providers/dashboard_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(state.error!)
              : RefreshIndicator(
                  onRefresh: () => ref.read(dashboardProvider.notifier).cargarDatos(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildMetricasGrid(state),
                      const SizedBox(height: 24),
                      _buildUltimasEmpresas(state),
                      const SizedBox(height: 24),
                      _buildUltimosUsuarios(state),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(dashboardProvider.notifier).cargarDatos(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricasGrid(DashboardState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _MetricaCard(
          icon: Icons.business,
          iconBgColor: Colors.blue,
          label: 'Total Empresas',
          value: state.totalEmpresas.toString(),
        ),
        _MetricaCard(
          icon: Icons.people,
          iconBgColor: Colors.green,
          label: 'Total Usuarios',
          value: state.totalUsuarios.toString(),
        ),
        _MetricaCard(
          icon: Icons.check_circle,
          iconBgColor: AppColors.primary,
          label: 'Usuarios Activos',
          value: state.usuariosActivos.toString(),
        ),
        _MetricaCard(
          icon: Icons.calendar_month,
          iconBgColor: Colors.purple,
          label: 'Empresas este Mes',
          value: state.empresasEsteMes.toString(),
        ),
      ],
    );
  }

  Widget _buildUltimasEmpresas(DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Últimas Empresas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...state.ultimasEmpresas.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(e.rucDni ?? e.plan),
            trailing: TextButton(
              onPressed: () => context.push('/admin/empresas/${e.id}'),
              child: const Text('Ver'),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildUltimosUsuarios(DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Últimos Usuarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...state.ultimosUsuarios.map((u) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${u.username} • ${u.rolId}'),
            trailing: TextButton(
              onPressed: () => context.push('/empleados/detalle/${u.id}'),
              child: const Text('Ver'),
            ),
          ),
        )),
      ],
    );
  }
}

class _MetricaCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final String value;

  const _MetricaCard({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
