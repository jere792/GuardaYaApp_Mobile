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
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _showFilters = false;
  int _currentPage = 0;
  int get _pageSize => 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarVentasDelDia());
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _cargarVentasDelDia() {
    setState(() => _currentPage = 0);
    final authState = ref.read(authProvider);
    final usuario = authState.usuario;
    if (usuario?.empresaId != null) {
      ref.read(ventasProvider.notifier).obtenerVentasDelDia(usuario!.empresaId!, DateTime.now());
    }
  }

  Future<void> _seleccionarFecha({required bool inicio}) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicio ? (_fechaInicio ?? DateTime.now()) : (_fechaFin ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        if (inicio) _fechaInicio = fecha;
        else _fechaFin = fecha;
      });
    }
  }

  void _buscar() {
    setState(() => _currentPage = 0);
    final authState = ref.read(authProvider);
    final usuario = authState.usuario;
    if (usuario?.empresaId == null) return;

    final codigo = _codigoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final nombre = _nombreController.text.trim();

    if (codigo.isEmpty && telefono.isEmpty && nombre.isEmpty && _fechaInicio == null) {
      _cargarVentasDelDia();
      return;
    }

    if (codigo.isNotEmpty && codigo.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código debe tener al menos 3 caracteres')),
      );
      return;
    }
    if (telefono.isNotEmpty && telefono.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El teléfono debe tener al menos 3 caracteres')),
      );
      return;
    }
    if (nombre.isNotEmpty && nombre.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre debe tener al menos 3 caracteres')),
      );
      return;
    }

    ref.read(ventasProvider.notifier).buscarVentas(
      empresaId: usuario!.empresaId!,
      codigo: codigo.isNotEmpty ? codigo : null,
      telefono: telefono.isNotEmpty ? telefono : null,
      nombre: nombre.isNotEmpty ? nombre : null,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _codigoController.clear();
      _nombreController.clear();
      _telefonoController.clear();
      _fechaInicio = null;
      _fechaFin = null;
      _currentPage = 0;
    });
    _cargarVentasDelDia();
  }

  Widget _buildOfflineMessage() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Falta conexión a internet para mostrar las ventas anteriores. Cuando te conectes, aparecerán automáticamente.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final total = ventasState.ventas.length;

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
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_cache') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Limpiar caché local'),
                    content: const Text('Se eliminarán las ventas pendientes y el caché local. Las ventas ya sincronizadas en el servidor no se verán afectadas.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(ventasProvider.notifier).limpiarCacheLocal();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Caché limpiado correctamente')),
                          );
                          _limpiarFiltros();
                        },
                        child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear_cache', child: Row(
                children: [Icon(Icons.delete_sweep, size: 20, color: Colors.red), SizedBox(width: 8), Text('Limpiar caché')],
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/ventas/registrar'),
          ),],
      ),
      body: _showFilters
          ? SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildFilterPanel(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: _buildContent(ventasState),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(child: _buildContent(ventasState)),
              ],
            ),
    );
  }

  Widget _buildFilterPanel() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.primary.withOpacity(0.08),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _filterField(controller: _codigoController, hint: 'Código de operación', icon: Icons.qr_code)),
                const SizedBox(width: 8),
                Expanded(child: _filterField(controller: _telefonoController, hint: 'Teléfono', icon: Icons.phone, keyboardType: TextInputType.phone)),
              ],
            ),
            const SizedBox(height: 8),
            _filterField(controller: _nombreController, hint: 'Nombre del cliente', icon: Icons.person),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _dateChip(label: _fechaInicio != null ? DateFormat('dd/MM/yyyy').format(_fechaInicio!) : 'Fecha inicio', onTap: () => _seleccionarFecha(inicio: true))),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.arrow_forward, size: 16)),
                Expanded(child: _dateChip(label: _fechaFin != null ? DateFormat('dd/MM/yyyy').format(_fechaFin!) : 'Fecha fin', onTap: () => _seleccionarFecha(inicio: false))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _buscar,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Buscar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _limpiarFiltros,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpiar'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField({required TextEditingController controller, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: colorScheme.outlineVariant)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _dateChip({required String label, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: colorScheme.outlineVariant)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VentasState state) {
    final colorScheme = Theme.of(context).colorScheme;
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
              Text('Error al cargar ventas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('No se pudieron cargar las ventas. Verifica tu conexión a internet.', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarVentasDelDia,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.ventas.isEmpty) {
      if (state.showOfflineMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: Colors.orange.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('Sin conexión', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text('Conéctate a internet para ver tus ventas', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarVentasDelDia,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No hay ventas', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Usa los filtros o toca + para registrar', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final totalPages = state.ventas.isEmpty ? 1 : (state.ventas.length / _pageSize).ceil();
    final pagedVentas = state.ventas.skip(_currentPage * _pageSize).take(_pageSize).toList();
    final hasOfflineMessage = state.showOfflineMessage;
    final itemCount = pagedVentas.length + (hasOfflineMessage ? 1 : 0);

    final list = ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < pagedVentas.length) {
          return _VentaCard(venta: pagedVentas[index]);
        }
        return _buildOfflineMessage();
      },
    );

    if (totalPages <= 1) return list;

    return Column(
      children: [
        Expanded(child: list),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage--),
              ),
              Text('Página ${_currentPage + 1} de $totalPages',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage >= totalPages - 1 ? null : () => setState(() => _currentPage++),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VentaCard extends StatelessWidget {
  final Venta venta;
  const _VentaCard({required this.venta});

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
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/', decimalDigits: 2);

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
                    child: Text(venta.clienteNombre ?? 'Cliente sin nombre',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(venta.estado).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getEstadoColor(venta.estado).withOpacity(0.3)),
                    ),
                    child: Text(_getEstadoLabel(venta.estado),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _getEstadoColor(venta.estado))),
                  ),
                  if (venta.updatedAt != null && venta.updatedAt!.isAfter(venta.createdAt))
                    const SizedBox(width: 6),
                  if (venta.updatedAt != null && venta.updatedAt!.isAfter(venta.createdAt))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Text('Editado',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (venta.clienteTelefono != null) ...[
                    Icon(Icons.phone, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(venta.clienteTelefono!, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(DateFormat('HH:mm').format(venta.createdAt), style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                ],
              ),
              if (venta.codigoYape != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.qr_code, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Op: ${venta.codigoYape}', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (venta.descripcion != null)
                    Expanded(
                      child: Text(venta.descripcion!, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  Text(currencyFormat.format(venta.monto),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
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
