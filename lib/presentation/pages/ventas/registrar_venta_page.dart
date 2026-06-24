import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/core/utils/image_picker.dart';
import 'package:guardaya_app/data/models/pending_venta_model.dart';
import 'package:guardaya_app/data/datasources/remote/ventas_datasource.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/widgets/common/confirmation_dialog.dart';
import 'package:guardaya_app/presentation/widgets/common/loading_overlay.dart';
import 'package:guardaya_app/presentation/widgets/common/top_right_toast.dart';
import 'package:guardaya_app/services/ocr_service.dart';
import 'package:guardaya_app/data/datasources/local/db/pending_ventas_dao.dart';
import 'package:guardaya_app/presentation/providers/connectivity_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/entities/tipo_transferencia.dart';
import 'package:guardaya_app/presentation/providers/clientes_provider.dart';
import 'package:guardaya_app/presentation/providers/ventas_provider.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/presentation/providers/productos_provider.dart';

class ProductoVenta {
  String nombre;
  int cantidad;
  double precio;
  double get subtotal => cantidad * precio;

  ProductoVenta({
    required this.nombre,
    this.cantidad = 1,
    required this.precio,
  });
}

class RegistrarVentaPage extends ConsumerStatefulWidget {
  const RegistrarVentaPage({super.key});

  @override
  ConsumerState<RegistrarVentaPage> createState() => _RegistrarVentaPageState();
}

class _RegistrarVentaPageState extends ConsumerState<RegistrarVentaPage> {
  int _currentStep = 0;

  File? _comprobanteImage;
  bool _isScanning = false;
  Map<String, dynamic>? _ocrResult;
  double _ocrConfidence = 0;

  final _codigoController = TextEditingController();
  final _montoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _clienteNombreController = TextEditingController();
  final _clienteTelefonoController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoTransferencia = 'Yape';
  String? _tipoTransferenciaId;
  List<TipoTransferencia> _tiposCargados = [];
  final List<String> _tiposTransferencia = ['Yape', 'Plin', 'Transferencia', 'Efectivo', 'Otro'];

  final List<ProductoVenta> _productos = [];
  final _productoNombreController = TextEditingController();
  final _productoPrecioController = TextEditingController();

  final _clienteSearchController = TextEditingController();
  List<Cliente> _clientesSearchResults = [];
  Cliente? _clienteSeleccionado;
  bool _clienteSearched = false;

  final _productoSearchController = TextEditingController();
  List<Producto> _productosSearchResults = [];
  Producto? _productoSeleccionado;
  bool _productoSearched = false;

  bool _isOffline = false;
  bool _codigoDuplicado = false;
  bool _verificandoCodigo = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _isOffline = !ref.read(connectivityProvider);
    _codigoController.addListener(_onCodigoChanged);
  }

  void _onCodigoChanged() {
    _debounce?.cancel();
    final codigo = _codigoController.text.trim();
    if (codigo.length >= 4 && !_isOffline) {
      _debounce = Timer(const Duration(milliseconds: 500), () => _verificarCodigoDuplicado(codigo));
    } else {
      if (_codigoDuplicado) setState(() => _codigoDuplicado = false);
    }
  }

  Future<void> _verificarCodigoDuplicado(String codigo) async {
    final user = ref.read(authProvider).usuario;
    final empresaId = user?.empresaId;
    if (empresaId == null || empresaId.isEmpty) return;
    setState(() => _verificandoCodigo = true);
    try {
      final datasource = VentasDatasource();
      final existentes = await datasource.buscarVentaPorCodigo(empresaId, codigo);
      if (mounted) setState(() => _codigoDuplicado = existentes.any((v) => v['codigo_yape'] == codigo));
    } catch (_) {
      if (mounted) setState(() => _codigoDuplicado = false);
    } finally {
      if (mounted) setState(() => _verificandoCodigo = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _codigoController.removeListener(_onCodigoChanged);
    _codigoController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _clienteNombreController.dispose();
    _clienteTelefonoController.dispose();
    _descripcionController.dispose();
    _productoNombreController.dispose();
    _productoPrecioController.dispose();
    _clienteSearchController.dispose();
    _productoSearchController.dispose();
    OcrService.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final image = await ImagePickerHelper.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _comprobanteImage = image;
        _ocrResult = null;
        _ocrConfidence = 0;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePickerHelper.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _comprobanteImage = image;
        _ocrResult = null;
        _ocrConfidence = 0;
      });
    }
  }

  Future<void> _scanWithOcr() async {
    if (_comprobanteImage == null) return;

    setState(() => _isScanning = true);

    try {
      final result = await OcrService.extractFromImage(_comprobanteImage!);

      setState(() {
        _ocrResult = result;
        _ocrConfidence = result['confianza'] ?? 0;

        if (result['codigo'] != null) {
          _codigoController.text = result['codigo']!;
        }
        if (result['monto'] != null) {
          _montoController.text = result['monto'].toString();
        }
        if (result['fecha'] != null) {
          _fechaController.text = result['fecha']!;
        }
        if (result['hora'] != null) {
          _horaController.text = result['hora']!;
        }
      });

      TopRightToast.show(
        context,
        'OCR completado. Datos extraídos con ${(result['confianza'] * 100).toStringAsFixed(0)}% de confianza.',
      );
    } catch (e) {
      TopRightToast.show(context, 'Error al escanear: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isScanning = false);
    }
  }

  double get _totalVenta {
    if (_productos.isEmpty) {
      return double.tryParse(_montoController.text.replaceAll(',', '.')) ?? 0;
    }
    return _productos.fold(0, (sum, p) => sum + p.subtotal);
  }

  void _addProducto() {
    final nombre = _productoNombreController.text.trim();
    final precio = double.tryParse(_productoPrecioController.text.replaceAll(',', '.')) ?? 0;

    if (nombre.isEmpty || precio <= 0) {
      TopRightToast.show(context, 'Ingrese nombre y precio válidos', isError: true);
      return;
    }

    setState(() {
      _productos.add(ProductoVenta(nombre: nombre, precio: precio));
      _productoNombreController.clear();
      _productoPrecioController.clear();
    });
  }

  void _removeProducto(int index) {
    setState(() => _productos.removeAt(index));
  }

  void _buscarClientes(String query) {
    if (query.trim().isEmpty || query.trim().length < 3) {
      setState(() {
        _clientesSearchResults = [];
        _clienteSearched = false;
      });
      return;
    }
    final usuario = ref.read(authProvider).usuario;
    if (usuario?.empresaId == null) return;

    final clientes = ref.read(clientesProvider).clientes;
    final filtered = clientes.where((c) =>
      c.activo &&
      c.empresaId == usuario!.empresaId &&
      (c.nombre.toLowerCase().contains(query.toLowerCase()) ||
       (c.telefono?.contains(query) ?? false))
    ).take(5).toList();

    setState(() {
      _clientesSearchResults = filtered;
      _clienteSearched = true;
    });
  }

  void _cargarClientesSiEsNecesario() {
    if (ref.read(clientesProvider).clientes.isEmpty) {
      final usuario = ref.read(authProvider).usuario;
      if (usuario?.empresaId != null) {
        ref.read(clientesProvider.notifier).cargarClientes(usuario!.empresaId!);
      }
    }
  }

  void _buscarProductos(String query) {
    if (query.trim().isEmpty || query.trim().length < 3) {
      setState(() {
        _productosSearchResults = [];
        _productoSearched = false;
      });
      return;
    }
    final usuario = ref.read(authProvider).usuario;
    if (usuario?.empresaId == null) return;

    final productos = ref.read(productosProvider).productos;
    final filtered = productos.where((p) =>
      p.activo &&
      p.empresaId == usuario!.empresaId &&
      p.nombre.toLowerCase().contains(query.toLowerCase())
    ).take(5).toList();

    setState(() {
      _productosSearchResults = filtered;
      _productoSearched = true;
    });
  }

  void _cargarProductosSiEsNecesario() {
    if (ref.read(productosProvider).productos.isEmpty) {
      final usuario = ref.read(authProvider).usuario;
      if (usuario?.empresaId != null) {
        ref.read(productosProvider.notifier).cargarProductos(usuario!.empresaId!);
      }
    }
  }

  Future<void> _guardarVenta() async {
    final authState = ref.read(authProvider);
    final usuario = authState.usuario;

    if (usuario == null) {
      TopRightToast.show(context, 'Error: No hay usuario autenticado', isError: true);
      return;
    }

    if (_codigoController.text.trim().isEmpty || _montoController.text.trim().isEmpty) {
      TopRightToast.show(context, 'Ingrese código y monto de la venta', isError: true);
      return;
    }

    final codigoOp = _codigoController.text.trim();
    final monto = double.tryParse(_montoController.text.replaceAll(',', '.')) ?? 0;
    if (monto <= 0) {
      TopRightToast.show(context, 'El monto debe ser mayor a 0', isError: true);
      return;
    }

    // Verificar si el código de operación ya existe
    final datasource = VentasDatasource();
    if (!_isOffline && usuario.empresaId != null) {
      try {
        final existentes = await datasource.buscarVentaPorCodigo(usuario.empresaId!, codigoOp);
        if (existentes.any((v) => v['codigo_yape'] == codigoOp)) {
          TopRightToast.show(context, 'Este código de operación ya fue registrado', isError: true);
          return;
        }
      } catch (_) {}
    }

    LoadingOverlay.show(context, message: 'Guardando venta...');

    try {
      final uuid = const Uuid();
      final ventaId = uuid.v4();

      // Serializar productos a JSON
      final productosJson = _productos.isNotEmpty
          ? _productos.map((p) => {
              'nombre': p.nombre,
              'cantidad': p.cantidad,
              'precio': p.precio,
              'subtotal': p.subtotal,
            }).toList()
          : null;

      final pendingVenta = PendingVentaModel(
        id: ventaId,
        empresaId: usuario.empresaId ?? '',
        usuarioId: usuario.id,
        clienteId: _clienteSeleccionado?.id,
        codigoYape: codigoOp,
        monto: monto,
        clienteNombre: _clienteNombreController.text.trim().isNotEmpty ? _clienteNombreController.text.trim() : null,
        clienteTelefono: _clienteTelefonoController.text.trim().isNotEmpty ? _clienteTelefonoController.text.trim() : null,
        fechaYape: _fechaController.text.trim().isNotEmpty ? _fechaController.text.trim() : null,
        descripcion: _descripcionController.text.trim().isNotEmpty ? _descripcionController.text.trim() : null,
        productos: productosJson != null ? jsonEncode(productosJson) : null,
        estado: 'pendiente',
        imagenYapeLocalPath: _comprobanteImage?.path,
        tipoTransferenciaId: _tipoTransferenciaId,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Guardar siempre en SQLite local
      final dao = PendingVentasDao();
      await dao.insertPendingVenta(pendingVenta);

      // Intentar sync inmediato a Supabase si hay internet
      bool synced = false;
      if (!_isOffline) {
        try {
          final ventaMap = pendingVenta.toMap();
          ventaMap.remove('sync_status');
          ventaMap.remove('sync_error');
          ventaMap.remove('retry_count');
          ventaMap.remove('imagen_yape_local_path');
          ventaMap.remove('imagen_entrega_local_path');
          ventaMap.remove('productos');

          // Convertir fecha_yape a ISO 8601 para Supabase
          if (ventaMap['fecha_yape'] != null) {
            final parsed = _parseFechaToIso(ventaMap['fecha_yape'] as String);
            ventaMap['fecha_yape'] = parsed;
          }

          final ventaCreada = await datasource.registrarVenta(ventaMap);

          if (productosJson != null && productosJson.isNotEmpty) {
            await datasource.registrarVentaProductos(
              ventaCreada['id'],
              usuario.empresaId ?? '',
              productosJson,
            );
          }

          await dao.updateSyncStatus(ventaId, 'synced');
          synced = true;
        } catch (syncError) {
          debugPrint('Sync inmediato falló: $syncError');
          if (mounted) {
            TopRightToast.show(context, 'Error al sincronizar: $syncError', isError: true);
          }
        }
      }

      if (mounted) LoadingOverlay.hide(context);

      if (synced) {
        TopRightToast.show(context, 'Venta guardada y sincronizada con Supabase');
      } else if (_isOffline) {
        TopRightToast.show(context, 'Venta guardada localmente. Se sincronizará cuando haya internet.');
      } else {
        TopRightToast.show(context, 'Venta guardada localmente. El sync automático continuará en segundo plano.', isError: true);
      }

      _clearForm();

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) LoadingOverlay.hide(context);
      TopRightToast.show(context, 'Error al guardar: ${e.toString()}', isError: true);
    }
  }

  String? _parseFechaToIso(String fecha) {
    try {
      // Formato dd/mm/aaaa
      final parts = fecha.split(RegExp(r'[/-]'));
      if (parts.length == 3 && parts[0].length <= 2) {
        final dia = parts[0].padLeft(2, '0');
        final mes = parts[1].padLeft(2, '0');
        final anio = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
        return '$anio-$mes-${dia}T00:00:00.000Z';
      }

      // Formato "10 jun. 2026"
      final meses = {
        'ene': '01', 'feb': '02', 'mar': '03', 'abr': '04',
        'may': '05', 'jun': '06', 'jul': '07', 'ago': '08',
        'sep': '09', 'oct': '10', 'nov': '11', 'dic': '12',
      };
      final textMatch = RegExp(r'(\d{1,2})\s+([a-z]{3})[a-z]*\.?\s+(\d{4})', caseSensitive: false).firstMatch(fecha);
      if (textMatch != null) {
        final dia = textMatch.group(1)!.padLeft(2, '0');
        final mes = meses[textMatch.group(2)!.toLowerCase()] ?? '01';
        final anio = textMatch.group(3)!;
        return '$anio-$mes-${dia}T00:00:00.000Z';
      }
    } catch (_) {}
    return fecha;
  }

  void _clearForm() {
    setState(() {
      _comprobanteImage = null;
      _ocrResult = null;
      _ocrConfidence = 0;
      _currentStep = 0;
      _tipoTransferencia = 'Yape';
      _tipoTransferenciaId = null;
      _codigoController.clear();
      _montoController.clear();
      _fechaController.clear();
      _horaController.clear();
      _clienteNombreController.clear();
      _clienteTelefonoController.clear();
      _descripcionController.clear();
      _productos.clear();
      _clienteSearchController.clear();
      _clientesSearchResults = [];
      _clienteSeleccionado = null;
      _clienteSearched = false;
      _productoSearchController.clear();
      _productosSearchResults = [];
      _productoSeleccionado = null;
      _productoSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(connectivityProvider, (previous, next) {
      if (mounted) setState(() => _isOffline = !next);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Venta'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('Offline'),
                backgroundColor: Colors.orange,
                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildStepper(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildStepCircle(0, Icons.payment, 'Tipo'),
          _buildStepLine(0),
          _buildStepCircle(1, Icons.camera_alt, 'Foto'),
          _buildStepLine(1),
          _buildStepCircle(2, Icons.person, 'Cliente'),
          _buildStepLine(2),
          _buildStepCircle(3, Icons.shopping_cart, 'Producto'),
          _buildStepLine(3),
          _buildStepCircle(4, Icons.check, 'Guardar'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, IconData icon, String label) {
    final cs = Theme.of(context).colorScheme;
    final isActive = step <= _currentStep;
    final isCurrent = step == _currentStep;

    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (step <= _currentStep) {
                setState(() => _currentStep = step);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : cs.surfaceContainerHighest,
                border: isCurrent ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? cs.onSurface : cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final cs = Theme.of(context).colorScheme;
    final isActive = step < _currentStep;
    return Container(
      width: 20,
      height: 2,
      color: isActive ? AppColors.primary : cs.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2:
        WidgetsBinding.instance.addPostFrameCallback((_) => _cargarClientesSiEsNecesario());
        return _buildStep3();
      case 3:
        WidgetsBinding.instance.addPostFrameCallback((_) => _cargarProductosSiEsNecesario());
        return _buildStep4();
      case 4: return _buildStep5();
      default: return _buildStep1();
    }
  }

  Widget _navRow({bool showBack = false, bool showOmit = false, required String nextText, VoidCallback? onNext, VoidCallback? onOmit}) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (showBack)
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
        if (showBack && (showOmit || onOmit != null)) const SizedBox(width: 12),
        if (showOmit || onOmit != null)
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onOmit ?? () => setState(() => _currentStep++),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: cs.outlineVariant),
                  foregroundColor: cs.onSurfaceVariant,
                ),
                child: const Text('Omitir', style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
        if ((showBack || showOmit || onOmit != null)) const SizedBox(width: 12),
        Expanded(
          flex: (showBack || showOmit || onOmit != null) ? 1 : 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: onNext != null ? AppColors.primary : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(nextText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTipoGrid(List<String> tipos, Map<String, IconData> icons, Map<String, Color> colors) {
    final rows = <Widget>[];
    for (int i = 0; i < tipos.length; i += 3) {
      final rowTipos = tipos.skip(i).take(3).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: rowTipos.map((tipo) {
              final isSelected = _tipoTransferencia == tipo;
              final color = colors[tipo] ?? Colors.grey;
              final icon = icons[tipo] ?? Icons.payment;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _tipoTransferencia = tipo;
                    final encontrado = _tiposCargados.where((t) => t.nombre == tipo).firstOrNull;
                    _tipoTransferenciaId = encontrado?.id;
                  }),
                  child: Container(
                    height: 90,
                    margin: EdgeInsets.only(
                      left: rowTipos.indexOf(tipo) > 0 ? 8 : 0,
                      right: rowTipos.indexOf(tipo) < rowTipos.length - 1 ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : color.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 28, color: isSelected ? Colors.white : color),
                        const SizedBox(height: 4),
                        Text(
                          tipo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    return rows;
  }

  // Step 1: Tipo de transferencia
  Widget _buildStep1() {
    final cs = Theme.of(context).colorScheme;
    final isEfectivo = _tipoTransferencia == 'Efectivo';

    final tiposAsync = ref.watch(tiposTransferenciaProvider);
    tiposAsync.whenData((tipos) {
      if (_tiposCargados != tipos) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _tiposCargados = tipos);
        });
      }
    });

    const tipoIcons = {
      'Yape': Icons.account_balance,
      'Plin': Icons.account_balance,
      'Transferencia': Icons.swap_horiz,
      'Efectivo': Icons.money,
      'Otro': Icons.more_horiz,
    };
    const tipoColors = {
      'Yape': Color(0xFF00B4D8),
      'Plin': Color(0xFF6C63FF),
      'Transferencia': AppColors.primary,
      'Efectivo': Color(0xFF2A9D8F),
      'Otro': Colors.grey,
    };
    return _buildCard(
      title: 'Tipo de Transferencia',
      icon: Icons.payment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._buildTipoGrid(_tiposTransferencia, tipoIcons, tipoColors),
          if (isEfectivo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para efectivo no se requiere código de operación.',
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _montoController,
              label: 'Monto (S/) *',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          _navRow(
            nextText: 'Continuar',
            onNext: () => setState(() => _currentStep = isEfectivo ? 2 : 1),
          ),
        ],
      ),
    );
  }

  // Step 2: Foto y datos extraídos
  Widget _buildStep2() {
    final cs = Theme.of(context).colorScheme;
    return _buildCard(
      title: 'Foto y Datos Extraídos',
      icon: Icons.camera_alt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_comprobanteImage == null) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Toma una foto del comprobante',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera),
                        label: const Text('Cámara'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _comprobanteImage!,
                height: 320,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _scanWithOcr,
                      icon: _isScanning
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.document_scanner, size: 18),
                      label: Text(_isScanning ? 'Escaneando...' : 'Escanear con OCR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _comprobanteImage = null;
                        _ocrResult = null;
                        _ocrConfidence = 0;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                    label: const Text('Quitar', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            if (_ocrResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _ocrConfidence >= 0.7
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _ocrConfidence >= 0.7
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _ocrConfidence >= 0.7 ? Icons.check_circle : Icons.warning,
                      color: _ocrConfidence >= 0.7 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OCR: ${(_ocrConfidence * 100).toStringAsFixed(0)}% de confianza',
                        style: TextStyle(
                          color: _ocrConfidence >= 0.7 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _codigoController,
            label: 'Código de operación',
            icon: Icons.confirmation_number,
            keyboardType: TextInputType.number,
          ),
          if (_verificandoCodigo)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          if (_codigoDuplicado)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este código de operación ya fue registrado',
                      style: TextStyle(fontSize: 12, color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _montoController,
            label: 'Monto (S/)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fechaController,
                  label: 'Fecha',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _horaController,
                  label: 'Hora',
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _navRow(showBack: true, nextText: 'Continuar', onNext: _codigoDuplicado ? null : () => setState(() => _currentStep = 2)),
        ],
      ),
    );
  }

  // Step 3: Datos de cliente
  Widget _buildStep3() {
    final cs = Theme.of(context).colorScheme;
    final tieneCliente = _clienteSeleccionado != null;

    return _buildCard(
      title: 'Datos del Cliente',
      icon: Icons.person,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tieneCliente) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text('Cliente seleccionado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _clienteSeleccionado = null;
                    _clienteSearchController.clear();
                    _clientesSearchResults = [];
                  }),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_clienteSeleccionado!.nombre,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (_clienteSeleccionado!.telefono != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(_clienteSeleccionado!.telefono!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            // Search field
            TextField(
              controller: _clienteSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente por nombre o teléfono...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _clienteSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _clienteSearchController.clear();
                          setState(() {
                            _clientesSearchResults = [];
                            _clienteSeleccionado = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) => _buscarClientes(v),
            ),
            // Search results
            if (_clientesSearchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _clientesSearchResults.length,
                  itemBuilder: (context, index) {
                    final cl = _clientesSearchResults[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          (cl.nombre.isNotEmpty ? cl.nombre[0] : '?').toUpperCase(),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(cl.nombre, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      subtitle: cl.telefono != null ? Text(cl.telefono!, style: const TextStyle(fontSize: 12)) : null,
                      onTap: () {
                        _clienteSeleccionado = cl;
                        _clienteSearchController.text = cl.nombre;
                        _clientesSearchResults = [];
                        setState(() {});
                      },
                    );
                  },
                ),
              )
            else if (_clienteSearchController.text.length >= 3 && !_clienteSearched)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_clienteSearchController.text.isNotEmpty && _clienteSearchController.text.length < 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Escribe al menos 3 caracteres para buscar.',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              )
            else if (_clienteSearchController.text.isNotEmpty && _clientesSearchResults.isEmpty && _clienteSearched)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('No se encontraron clientes.',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/clientes/crear'),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Crear Cliente (opcional)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descripcionController,
            label: 'Descripción / Notas',
            icon: Icons.notes,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _navRow(
            showBack: true,
            showOmit: true,
            nextText: 'Continuar',
            onNext: () => setState(() => _currentStep = 3),
            onOmit: () {
              setState(() {
                _clienteSeleccionado = null;
                _clienteSearchController.clear();
                _clientesSearchResults = [];
                _currentStep = 3;
              });
            },
          ),
        ],
      ),
    );
  }

  // Step 4: Producto
  Widget _buildStep4() {
    final cs = Theme.of(context).colorScheme;
    final tieneProducto = _productoSeleccionado != null;

    return _buildCard(
      title: 'Productos',
      icon: Icons.shopping_cart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tieneProducto) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text('Producto seleccionado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _productoSeleccionado = null;
                    _productoSearchController.clear();
                    _productosSearchResults = [];
                  }),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_productoSeleccionado!.nombre,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Search field
            TextField(
              controller: _productoSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _productoSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _productoSearchController.clear();
                          setState(() {
                            _productosSearchResults = [];
                            _productoSeleccionado = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) => _buscarProductos(v),
            ),
            // Search results
            if (_productosSearchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _productosSearchResults.length,
                  itemBuilder: (context, index) {
                    final p = _productosSearchResults[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.shopping_bag, size: 18, color: AppColors.primary),
                      ),
                      title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      subtitle: Text('S/ ${p.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        _productoSeleccionado = p;
                        _productoNombreController.text = p.nombre;
                        _productoPrecioController.text = p.precio.toStringAsFixed(2);
                        _productoSearchController.text = p.nombre;
                        _productosSearchResults = [];
                        setState(() {});
                      },
                    );
                  },
                ),
              )
            else if (_productoSearchController.text.length >= 3 && !_productoSearched)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_productoSearchController.text.isNotEmpty && _productoSearchController.text.length < 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Escribe al menos 3 caracteres para buscar.',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              )
            else if (_productoSearchController.text.isNotEmpty && _productosSearchResults.isEmpty && _productoSearched)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('No se encontraron productos.',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/productos/crear'),
                icon: const Icon(Icons.inventory_2, size: 18),
                label: const Text('Crear Producto (opcional)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _productoNombreController,
                  label: 'Producto',
                  icon: Icons.shopping_bag,
                  readOnly: tieneProducto,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _productoPrecioController,
                  label: 'Precio',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                onPressed: _addProducto,
                icon: const Icon(Icons.add_circle, color: AppColors.success),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_productos.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                'No hay productos agregados. Puedes añadir items o usar solo el monto total.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            ..._productos.asMap().entries.map((entry) {
              final index = entry.key;
              final producto = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(
                            '${producto.cantidad} x S/ ${producto.precio.toStringAsFixed(2)}',
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'S/ ${producto.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                    ),
                    IconButton(
                      onPressed: () => _removeProducto(index),
                      icon: const Icon(Icons.remove_circle, color: AppColors.error),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
          _navRow(
            showBack: true,
            showOmit: true,
            nextText: 'Revisar y Guardar',
            onNext: () => setState(() => _currentStep = 4),
            onOmit: () {
              setState(() {
                _productoSeleccionado = null;
                _productoNombreController.clear();
                _productoPrecioController.clear();
                _productoSearchController.clear();
                _productosSearchResults = [];
                _currentStep = 4;
              });
            },
          ),
        ],
      ),
    );
  }

  // Step 5: Confirmación para guardar
  Widget _buildStep5() {
    final cs = Theme.of(context).colorScheme;
    return _buildCard(
      title: 'Confirmar Venta',
      icon: Icons.check,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Tipo:', _tipoTransferencia),
                _buildSummaryRow('Código:', _codigoController.text),
                _buildSummaryRow('Monto:', 'S/ ${double.tryParse(_montoController.text.replaceAll(',', '.'))?.toStringAsFixed(2) ?? "0.00"}'),
                _buildSummaryRow('Fecha:', _fechaController.text.isNotEmpty ? _fechaController.text : '—'),
                _buildSummaryRow('Hora:', _horaController.text.isNotEmpty ? _horaController.text : '—'),
                _buildSummaryRow('Cliente:', _clienteNombreController.text.isNotEmpty ? _clienteNombreController.text : 'Sin cliente'),
                if (_productos.isNotEmpty) ...[
                  const Divider(height: 24),
                  ..._productos.map((p) => _buildSummaryRow(
                    '${p.nombre}:',
                    'S/ ${p.subtotal.toStringAsFixed(2)}',
                  )),
                ],
                const Divider(height: 24),
                _buildSummaryRow(
                  'Total:',
                  'S/ ${_totalVenta.toStringAsFixed(2)}',
                  isBold: true,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _navRow(showBack: true, nextText: 'Guardar Venta', onNext: () async {
            final confirmed = await ConfirmationDialog.show(
              context,
              title: 'Guardar Venta',
              message: '¿Estás seguro de guardar esta venta de S/ ${_totalVenta.toStringAsFixed(2)}?',
            );
            if (confirmed == true && mounted) {
              _guardarVenta();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? cs.surfaceContainerLow : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? cs.onSurfaceVariant : cs.onSurface, fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6), fontSize: 14),
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant.withOpacity(0.7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
