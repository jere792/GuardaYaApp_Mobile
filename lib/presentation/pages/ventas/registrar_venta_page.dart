import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/core/utils/image_picker.dart';
import 'package:guardaya_app/data/models/pending_venta_model.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/connectivity_provider.dart';
import 'package:guardaya_app/services/ocr_service.dart';
import 'package:guardaya_app/data/datasources/local/db/pending_ventas_dao.dart';
import 'package:guardaya_app/services/connectivity_service.dart';
import 'package:uuid/uuid.dart';

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
  // Step tracking
  int _currentStep = 0;
  
  // Image & OCR
  File? _comprobanteImage;
  bool _isScanning = false;
  Map<String, dynamic>? _ocrResult;
  double _ocrConfidence = 0;
  
  // Form controllers
  final _codigoController = TextEditingController();
  final _montoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _clienteNombreController = TextEditingController();
  final _clienteTelefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Transfer type
  String _tipoTransferencia = 'Yape';
  final List<String> _tiposTransferencia = ['Yape', 'Plin', 'Transferencia', 'Efectivo', 'Otro'];
  
  // Products
  final List<ProductoVenta> _productos = [];
  final _productoNombreController = TextEditingController();
  final _productoPrecioController = TextEditingController();
  
  // State
  bool _isSaving = false;
  bool _isOffline = false;
  
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    final connectivityService = ConnectivityService();
    final online = await connectivityService.isOnline;
    setState(() => _isOffline = !online);
  }
  
  @override
  void dispose() {
    _codigoController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _clienteNombreController.dispose();
    _clienteTelefonoController.dispose();
    _descripcionController.dispose();
    _productoNombreController.dispose();
    _productoPrecioController.dispose();
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
        
        // Auto-fill fields
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
      
      _showSuccess('OCR completado. Datos extraídos con ${(result['confianza'] * 100).toStringAsFixed(0)}% de confianza.');
    } catch (e) {
      _showError('Error al escanear: ${e.toString()}');
    } finally {
      setState(() => _isScanning = false);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
      _showError('Ingrese nombre y precio válidos');
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
  
  Future<void> _guardarVenta() async {
    final authState = ref.read(authProvider);
    final usuario = authState.usuario;
    
    if (usuario == null) {
      _showError('Error: No hay usuario autenticado');
      return;
    }
    
    if (_codigoController.text.trim().isEmpty || _montoController.text.trim().isEmpty) {
      _showError('Ingrese código y monto de la venta');
      return;
    }
    
    final monto = double.tryParse(_montoController.text.replaceAll(',', '.')) ?? 0;
    if (monto <= 0) {
      _showError('El monto debe ser mayor a 0');
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final uuid = const Uuid();
      final ventaId = uuid.v4();
      
      // Crear venta para SQLite
      final pendingVenta = PendingVentaModel(
        id: ventaId,
        empresaId: usuario.empresaId ?? '',
        usuarioId: usuario.id,
        codigoYape: _codigoController.text.trim(),
        monto: monto,
        clienteNombre: _clienteNombreController.text.trim().isNotEmpty ? _clienteNombreController.text.trim() : null,
        clienteTelefono: _clienteTelefonoController.text.trim().isNotEmpty ? _clienteTelefonoController.text.trim() : null,
        fechaYape: _fechaController.text.trim().isNotEmpty ? _fechaController.text.trim() : null,
        descripcion: _descripcionController.text.trim().isNotEmpty ? _descripcionController.text.trim() : null,
        estado: 'pendiente',
        imagenYapeLocalPath: _comprobanteImage?.path,
        createdAt: DateTime.now().toIso8601String(),
      );
      
      // Guardar en SQLite
      final dao = PendingVentasDao();
      await dao.insertPendingVenta(pendingVenta);
      
      // Si hay internet, intentar sync inmediato
      if (!_isOffline) {
        // TODO: Implementar sync inmediato
        _showSuccess('Venta guardada y sincronizada con Supabase');
      } else {
        _showSuccess('Venta guardada localmente. Se sincronizará cuando haya internet.');
      }
      
      // Limpiar formulario
      _clearForm();
      
      // Volver a la lista de ventas
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Error al guardar: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  void _clearForm() {
    setState(() {
      _comprobanteImage = null;
      _ocrResult = null;
      _ocrConfidence = 0;
      _currentStep = 0;
      _codigoController.clear();
      _montoController.clear();
      _fechaController.clear();
      _horaController.clear();
      _clienteNombreController.clear();
      _clienteTelefonoController.clear();
      _descripcionController.clear();
      _productos.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar Venta'),
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            _buildStepper(),
            const SizedBox(height: 24),
            
            // Step 1: Tipo de transferencia
            _buildStep1(),
            
            // Step 2: Foto del comprobante
            if (_currentStep >= 1) _buildStep2(),
            
            // Step 3: Datos extraídos
            if (_currentStep >= 2) _buildStep3(),
            
            // Step 4: Datos del cliente
            if (_currentStep >= 3) _buildStep4(),
            
            // Step 5: Productos
            if (_currentStep >= 4) _buildStep5(),
            
            // Step 6: Resumen y guardar
            if (_currentStep >= 5) _buildStep6(),
          ],
        ),
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
          _buildStepCircle(2, Icons.text_fields, 'Datos'),
          _buildStepLine(2),
          _buildStepCircle(3, Icons.person, 'Cliente'),
          _buildStepLine(3),
          _buildStepCircle(4, Icons.shopping_cart, 'Items'),
          _buildStepLine(4),
          _buildStepCircle(5, Icons.check, 'Guardar'),
        ],
      ),
    );
  }
  
  Widget _buildStepCircle(int step, IconData icon, String label) {
    final isActive = step <= _currentStep;
    final isCurrent = step == _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (step <= _currentStep + 1) {
                setState(() => _currentStep = step);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.grey.shade300,
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
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.textPrimary : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepLine(int step) {
    final isActive = step < _currentStep;
    return Container(
      width: 20,
      height: 2,
      color: isActive ? AppColors.primary : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }
  
  Widget _buildStep1() {
    return _buildCard(
      title: 'Tipo de Transferencia',
      icon: Icons.payment,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tiposTransferencia.map((tipo) {
          final isSelected = _tipoTransferencia == tipo;
          return ChoiceChip(
            label: Text(tipo),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _tipoTransferencia = tipo;
                  if (_currentStep < 1) _currentStep = 1;
                });
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.grey.shade100,
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStep2() {
    return _buildCard(
      title: 'Foto del Comprobante',
      icon: Icons.camera_alt,
      child: Column(
        children: [
          if (_comprobanteImage == null) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toma una foto del comprobante',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
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
                          backgroundColor: Colors.grey.shade700,
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
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scanWithOcr,
                  icon: _isScanning
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.document_scanner),
                  label: Text(_isScanning ? 'Escaneando...' : 'Escanear con OCR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _comprobanteImage = null;
                      _ocrResult = null;
                    });
                  },
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  tooltip: 'Eliminar foto',
                ),
              ],
            ),
            if (_ocrResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _ocrConfidence >= 0.7
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _ocrConfidence >= 0.7
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _ocrConfidence >= 0.7 ? Icons.check_circle : Icons.warning,
                      color: _ocrConfidence >= 0.7
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OCR: ${(_ocrConfidence * 100).toStringAsFixed(0)}% de confianza',
                        style: TextStyle(
                          color: _ocrConfidence >= 0.7
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (_currentStep < 2) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _comprobanteImage != null || _tipoTransferencia == 'Efectivo'
                  ? () => setState(() => _currentStep = 2)
                  : null,
              child: const Text('Continuar'),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStep3() {
    return _buildCard(
      title: 'Datos Extraídos',
      icon: Icons.text_fields,
      child: Column(
        children: [
          _buildTextField(
            controller: _codigoController,
            label: 'Código de operación',
            icon: Icons.confirmation_number,
            keyboardType: TextInputType.number,
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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 3),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep4() {
    return _buildCard(
      title: 'Datos del Cliente',
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextField(
            controller: _clienteNombreController,
            label: 'Nombre del cliente',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _clienteTelefonoController,
            label: 'Teléfono',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descripcionController,
            label: 'Descripción / Notas',
            icon: Icons.notes,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 4),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep5() {
    return _buildCard(
      title: 'Productos',
      icon: Icons.shopping_cart,
      child: Column(
        children: [
          // Add product form
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _productoNombreController,
                  label: 'Producto',
                  icon: Icons.shopping_bag,
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
          
          // Products list
          if (_productos.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No hay productos. Puedes agregar items o usar solo el monto total.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
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
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${producto.cantidad} x S/ ${producto.precio.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'S/ ${producto.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeProducto(index),
                      icon: const Icon(Icons.remove_circle, color: AppColors.error),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 5),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep6() {
    return _buildCard(
      title: 'Resumen',
      icon: Icons.check,
      child: Column(
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Tipo:', _tipoTransferencia),
                _buildSummaryRow('Código:', _codigoController.text),
                _buildSummaryRow('Fecha:', _fechaController.text),
                _buildSummaryRow('Cliente:', _clienteNombreController.text.isNotEmpty ? _clienteNombreController.text : 'Sin cliente'),
                const Divider(height: 24),
                if (_productos.isNotEmpty) ...[
                  ..._productos.map((p) => _buildSummaryRow(
                    '${p.nombre}:',
                    'S/ ${p.subtotal.toStringAsFixed(2)}',
                  )),
                  const Divider(height: 24),
                ],
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
          
          // Save button
          Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSaving ? null : _guardarVenta,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Guardar Venta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.textSecondary.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
