import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/ventas_provider.dart';
import 'package:intl/intl.dart';

class ReportesPage extends ConsumerStatefulWidget {
  const ReportesPage({super.key});

  @override
  ConsumerState<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends ConsumerState<ReportesPage> {
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fechaInicio = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _fechaFin = DateTime.now();
      _cargarReportes();
    });
  }

  void _cargarReportes() {
    final usuario = ref.read(authProvider).usuario;
    final empresaId = usuario?.empresaId;
    if (empresaId != null && empresaId.isNotEmpty) {
      ref.read(ventasProvider.notifier).obtenerVentasPorRango(empresaId, _fechaInicio, _fechaFin);
    }
  }

  Future<void> _seleccionarFecha({required bool inicio}) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        if (inicio) _fechaInicio = fecha;
        else _fechaFin = fecha;
      });
      _cargarReportes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ventasProvider);
    final ventas = state.ventas;
    final totalVentas = ventas.length;
    final totalMonto = ventas.fold(0.0, (sum, v) => sum + v.monto);
    final promedio = totalVentas > 0 ? totalMonto / totalVentas : 0.0;
    final completadas = ventas.where((v) => v.estado == 'completado').length;
    final pendientes = ventas.where((v) => v.estado == 'pendiente').length;

    final formatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DateRangeCard(
                  fechaInicio: _fechaInicio,
                  fechaFin: _fechaFin,
                  onSelectInicio: () => _seleccionarFecha(inicio: true),
                  onSelectFin: () => _seleccionarFecha(inicio: false),
                ),
                const SizedBox(height: 16),
                _MetricCard(icon: Icons.shopping_cart, label: 'Total Ventas', value: '$totalVentas'),
                const SizedBox(height: 12),
                _MetricCard(icon: Icons.monetization_on, label: 'Ingresos Totales', value: formatter.format(totalMonto), color: AppColors.success),
                const SizedBox(height: 12),
                _MetricCard(icon: Icons.trending_up, label: 'Promedio por Venta', value: formatter.format(promedio)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.check_circle,
                        label: 'Completadas',
                        value: '$completadas',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.pending,
                        label: 'Pendientes',
                        value: '$pendientes',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Últimas ventas del período',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                if (ventas.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No hay ventas en este período', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...ventas.take(10).map((v) => _VentaItem(venta: v)),
              ],
            ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final VoidCallback onSelectInicio;
  final VoidCallback onSelectFin;

  const _DateRangeCard({
    required this.fechaInicio,
    required this.fechaFin,
    required this.onSelectInicio,
    required this.onSelectFin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rango de fechas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _DateButton(label: 'Desde', fecha: fechaInicio, onTap: onSelectInicio, dateFormat: dateFormat),
            const SizedBox(height: 8),
            _DateButton(label: 'Hasta', fecha: fechaFin, onTap: onSelectFin, dateFormat: dateFormat),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime fecha;
  final VoidCallback onTap;
  final DateFormat dateFormat;

  const _DateButton({
    required this.label,
    required this.fecha,
    required this.onTap,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('$label: ${dateFormat.format(fecha)}', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? AppColors.primary;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: isDark ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withOpacity(isDark ? 0.25 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: c),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VentaItem extends StatelessWidget {
  final Venta venta;
  const _VentaItem({required this.venta});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yy HH:mm');
    final isCompletado = venta.estado == 'completado';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isCompletado ? Colors.green.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
          child: Icon(
            isCompletado ? Icons.check_circle : Icons.pending,
            size: 20,
            color: isCompletado ? Colors.green : AppColors.warning,
          ),
        ),
        title: Text(venta.clienteNombre ?? 'Sin cliente', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(dateFormat.format(venta.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: Text(formatter.format(venta.monto), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ),
    );
  }
}
