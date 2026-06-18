import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/presentation/providers/empresas_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class EmpresaFormPage extends ConsumerStatefulWidget {
  final String? empresaId;

  const EmpresaFormPage({super.key, this.empresaId});

  @override
  ConsumerState<EmpresaFormPage> createState() => _EmpresaFormPageState();
}

class _EmpresaFormPageState extends ConsumerState<EmpresaFormPage> {
  final _nombreController = TextEditingController();
  final _slugController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _rucDniController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String _planSeleccionado = 'basico';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.empresaId != null;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
    }
  }

  void _cargarDatos() {
    final state = ref.read(empresasProvider);
    final e = state.empresas.where((e) => e.id == widget.empresaId).firstOrNull;
    if (e != null) {
      _nombreController.text = e.nombre;
      _slugController.text = e.slug;
      _emailController.text = e.emailContacto ?? '';
      _telefonoController.text = e.telefono ?? '';
      _direccionController.text = e.direccion ?? '';
      _rucDniController.text = e.rucDni ?? '';
      _planSeleccionado = e.plan;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _slugController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _rucDniController.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value, String campo) {
    if (value == null || value.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final slug = _slugController.text.trim();
    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();
    final direccion = _direccionController.text.trim();
    final rucDni = _rucDniController.text.trim();
    final plan = _planSeleccionado;
    final now = DateTime.now();

    if (_isEditing) {
      final state = ref.read(empresasProvider);
      final original = state.empresas.where((e) => e.id == widget.empresaId).firstOrNull;
      if (original == null) return;

      await ref.read(empresasProvider.notifier).actualizarEmpresa(
        original.copyWith(
          nombre: nombre,
          slug: slug,
          emailContacto: email.isNotEmpty ? email : null,
          telefono: telefono.isNotEmpty ? telefono : null,
          direccion: direccion.isNotEmpty ? direccion : null,
          rucDni: rucDni.isNotEmpty ? rucDni : null,
          plan: plan,
        ),
      );
    } else {
      await ref.read(empresasProvider.notifier).crearEmpresa(
        Empresa(
          id: '',
          nombre: nombre,
          slug: slug,
          emailContacto: email.isNotEmpty ? email : null,
          telefono: telefono.isNotEmpty ? telefono : null,
          direccion: direccion.isNotEmpty ? direccion : null,
          rucDni: rucDni.isNotEmpty ? rucDni : null,
          plan: plan,
          activo: true,
          createdAt: now,
        ),
      );
    }

    final newState = ref.read(empresasProvider);
    if (newState.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Empresa actualizada' : 'Empresa creada')),
      );
      ref.read(empresasProvider.notifier).resetSuccess();
      if (context.mounted) context.pop();
    } else if (newState.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState.error!), backgroundColor: Colors.red),
      );
      ref.read(empresasProvider.notifier).resetError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Empresa' : 'Nueva Empresa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                validator: (v) => _validarRequerido(v, 'El nombre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slugController,
                decoration: InputDecoration(
                  labelText: 'Slug *',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                  helperText: 'Identificador único (ej: mi-empresa)',
                ),
                maxLength: 50,
                validator: (v) => _validarRequerido(v, 'El slug'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rucDniController,
                decoration: InputDecoration(
                  labelText: 'RUC / DNI *',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                  helperText: '8 dígitos para DNI, 11 para RUC',
                ),
                keyboardType: TextInputType.number,
                maxLength: 11,
                validator: (v) => _validarRequerido(v, 'El RUC/DNI'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email de contacto (opcional)',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono *',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                maxLength: 15,
                validator: (v) => _validarRequerido(v, 'El teléfono'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección (opcional)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _planSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Plan *',
                  prefixIcon: const Icon(Icons.verified),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                ),
                items: ['basico', 'premium', 'empresarial'].map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.toUpperCase()),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _planSeleccionado = v);
                },
              ),
              const SizedBox(height: 32),
              Consumer(builder: (context, ref, _) {
                final state = ref.watch(empresasProvider);
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: state.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isEditing ? 'Guardar Cambios' : 'Crear Empresa', style: const TextStyle(fontSize: 16)),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
