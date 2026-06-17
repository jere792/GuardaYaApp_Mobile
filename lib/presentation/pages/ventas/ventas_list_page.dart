import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/ventas_provider.dart';
import 'package:intl/intl.dart';

class VentasListPage extends ConsumerStatefulWidget {
  const VentasListPage({super.key});

  @override
  ConsumerState<VentasListPage> createState() => _VentasListPageState();
}

class _VentasListPageState extends ConsumerState<VentasListPage> {
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarVentas();
    });
  }

  void _cargarVentas() {
    final authState = ref.read(authProvider);
    final usuario = authState.usuario;
    if (usuario?.empresaId != null) {
      ref.read(ventasProvider.notifier).obtenerVentasDelDia(
            usuario!.empresaId!,
            _fechaSeleccionada,
          );
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
      _cargarVentas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _seleccionarFecha,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header de fecha
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.date_range, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Ventas del ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${ventasState.ventas.length} ventas',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Lista de ventas
          Expanded(
            child: _buildContent(ventasState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/ventas/registrar'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(VentasState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Cargando ventas...',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar ventas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarVentas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.ventas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ventas para este día',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para registrar una venta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.ventas.length,
      itemBuilder: (context, index) {
        final venta = state.ventas[index];
        return _VentaCard(venta: venta);
      },
    );
  }
}

class _VentaCard extends StatelessWidget {
  final Venta venta;

  const _VentaCard({required this.venta});

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/ventas/${venta.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      venta.clienteNombre ?? 'Cliente sin nombre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(venta.estado).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getEstadoColor(venta.estado).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getEstadoLabel(venta.estado),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getEstadoColor(venta.estado),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    venta.clienteTelefono ?? 'Sin teléfono',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(venta.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (venta.codigoYape != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.qr_code, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Yape: ${venta.codigoYape}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (venta.descripcion != null)
                    Expanded(
                      child: Text(
                        venta.descripcion!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    currencyFormat.format(venta.monto),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

late final NumberFormat currencyFormat = NumberFormat.currency(
  locale: 'es_PE',
  symbol: 'S/',
  decimalDigits: 2,
);