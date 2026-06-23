import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/domain/entities/tipo_transferencia.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/presentation/providers/ventas_provider.dart';
import 'package:intl/intl.dart';

class VentaDetailPage extends ConsumerStatefulWidget {
  final String ventaId;
  const VentaDetailPage({super.key, required this.ventaId});

  @override
  ConsumerState<VentaDetailPage> createState() => _VentaDetailPageState();
}

class _VentaDetailPageState extends ConsumerState<VentaDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ventasProvider.notifier).obtenerVentaPorId(widget.ventaId);
    });
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'completado': return Colors.green;
      case 'cancelado': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente': return 'Pendiente';
      case 'completado': return 'Completado';
      case 'cancelado': return 'Cancelado';
      default: return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final venta = ventasState.ventaSeleccionada;
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/', decimalDigits: 2);
    final tiposAsync = ref.watch(tiposTransferenciaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: _buildBody(venta, ventasState, currencyFormat, tiposAsync),
    );
  }

  Widget _buildBody(Venta? venta, VentasState state, NumberFormat currencyFormat, AsyncValue<List<TipoTransferencia>> tiposAsync) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error al cargar la venta', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(state.error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(ventasProvider.notifier).obtenerVentaPorId(widget.ventaId),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (venta == null) {
      return const Center(child: Text('Venta no encontrada'));
    }

    final isPendiente = venta.estado == 'pendiente';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estado
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _getEstadoColor(venta.estado).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getEstadoColor(venta.estado).withOpacity(0.3)),
            ),
            child: Text(
              _getEstadoLabel(venta.estado),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getEstadoColor(venta.estado)),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Cliente
        _detailCard(
          children: [
            _detailRow(Icons.person, 'Cliente', venta.clienteNombre ?? 'Sin nombre'),
            if (venta.clienteTelefono != null)
              _detailRow(Icons.phone, 'Teléfono', venta.clienteTelefono!),
          ],
        ),
        const SizedBox(height: 12),

        // Monto
        _detailCard(
          children: [
            _detailRow(Icons.attach_money, 'Monto', currencyFormat.format(venta.monto)),
          ],
        ),
        const SizedBox(height: 12),

        // Datos Yape
        _detailCard(
          children: [
            if (venta.codigoYape != null)
              _detailRow(Icons.qr_code, 'Código de operación', venta.codigoYape!),
            if (venta.fechaYape != null)
              _detailRow(Icons.calendar_today, 'Fecha Yape', DateFormat('dd/MM/yyyy').format(venta.fechaYape!)),
            if (venta.tipoTransferenciaId != null)
              _buildTipoTransferenciaRow(venta.tipoTransferenciaId!, tiposAsync),
          ],
        ),
        const SizedBox(height: 12),

        // Productos
        if (venta.productos != null && venta.productos.toString().isNotEmpty)
          _buildProductosSection(venta.productos!),
        const SizedBox(height: 12),

        // Información de registro
        _detailCard(
          children: [
            _detailRow(Icons.access_time, 'Registrado', DateFormat('dd/MM/yyyy HH:mm').format(venta.createdAt)),
            if (venta.descripcion != null && venta.descripcion!.isNotEmpty)
              _detailRow(Icons.notes, 'Notas', venta.descripcion!),
          ],
        ),
        const SizedBox(height: 24),

        // Botón completar
        if (isPendiente)
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                ref.read(ventasProvider.notifier).cambiarEstado(venta.id, 'completado');
                await Future.delayed(const Duration(milliseconds: 300));
                if (mounted) {
                  ref.read(ventasProvider.notifier).obtenerVentaPorId(widget.ventaId);
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Marcar como Completado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        if (!isPendiente)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getEstadoColor(venta.estado).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _getEstadoColor(venta.estado).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: _getEstadoColor(venta.estado)),
                const SizedBox(width: 8),
                Text('Venta ${_getEstadoLabel(venta.estado).toLowerCase()}',
                    style: TextStyle(color: _getEstadoColor(venta.estado), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProductosSection(dynamic productosData) {
    List<Map<String, dynamic>> productos = [];
    if (productosData is String && productosData.isNotEmpty) {
      try {
        final decoded = Uri.tryParse('[${productosData.replaceAll('{', '{"').replaceAll('}', '"}')}]');
      } catch (_) {}
      // Simple manual parse for our format: [{nombre: X, cantidad: Y, precio: Z, subtotal: W}]
      try {
        final RegExp exp = RegExp(r"\{([^}]+)\}");
        final matches = exp.allMatches(productosData);
        for (final m in matches) {
          final parts = m.group(1)!.split(',');
          Map<String, dynamic> map = {};
          for (final p in parts) {
            final kv = p.split(': ');
            if (kv.length == 2) {
              map[kv[0].trim()] = kv[1].trim();
            }
          }
          if (map.isNotEmpty) productos.add(map);
        }
      } catch (_) {}
    } else if (productosData is List) {
      productos = productosData.cast<Map<String, dynamic>>();
    }
    if (productos.isEmpty) return const SizedBox.shrink();
    return _detailCard(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Productos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        ...productos.map((p) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text('${p['nombre'] ?? ''} x${p['cantidad'] ?? 1}',
                    style: const TextStyle(fontSize: 13)),
              ),
              Text('S/ ${(p['subtotal'] ?? 0).toString()}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _detailCard({required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoTransferenciaRow(String tipoId, AsyncValue<List<TipoTransferencia>> tiposAsync) {
    final tipos = tiposAsync.asData?.value ?? [];
    final tipo = tipos.where((t) => t.id == tipoId).firstOrNull;
    final nombre = tipo?.nombre ?? tipoId;
    return _detailRow(Icons.payment, 'Tipo pago', nombre);
  }
}
