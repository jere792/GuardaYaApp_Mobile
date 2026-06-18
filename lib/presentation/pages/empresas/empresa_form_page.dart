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
  bool _isEditing = false;

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

  void _guardar() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }

    final slug = _slugController.text.trim();
    if (slug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El slug es obligatorio')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();
    final direccion = _direccionController.text.trim();
    final rucDni = _rucDniController.text.trim();
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
          plan: 'basico',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _slugController,
              decoration: InputDecoration(
                labelText: 'Slug *',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rucDniController,
              decoration: InputDecoration(
                labelText: 'RUC / DNI',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email de contacto',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.sentences,
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
    );
  }
}
