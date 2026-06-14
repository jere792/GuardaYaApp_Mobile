import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/clientes_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';

class ClienteFormPage extends ConsumerStatefulWidget {
  final String? clienteId;

  const ClienteFormPage({super.key, this.clienteId});

  @override
  ConsumerState<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends ConsumerState<ClienteFormPage> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _notasController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.clienteId != null;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
    }
  }

  void _cargarDatos() {
    final state = ref.read(clientesProvider);
    final c = state.clientes.where((c) => c.id == widget.clienteId).firstOrNull;
    if (c != null) {
      _nombreController.text = c.nombre;
      _telefonoController.text = c.telefono ?? '';
      _emailController.text = c.email ?? '';
      _direccionController.text = c.direccion ?? '';
      _notasController.text = c.notas ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
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

    final usuario = ref.read(authProvider).usuario;
    final empresaId = usuario?.empresaId;
    if (empresaId == null || empresaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: empresa no encontrada')),
      );
      return;
    }

    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();
    final direccion = _direccionController.text.trim();
    final notas = _notasController.text.trim();
    final now = DateTime.now();

    if (_isEditing) {
      final state = ref.read(clientesProvider);
      final original = state.clientes.where((c) => c.id == widget.clienteId).firstOrNull;
      if (original == null) return;

      await ref.read(clientesProvider.notifier).actualizarCliente(
        original.copyWith(
          nombre: nombre,
          telefono: telefono.isNotEmpty ? telefono : null,
          email: email.isNotEmpty ? email : null,
          direccion: direccion.isNotEmpty ? direccion : null,
          notas: notas.isNotEmpty ? notas : null,
        ),
      );
    } else {
      await ref.read(clientesProvider.notifier).crearCliente(
        Cliente(
          id: '',
          empresaId: empresaId,
          nombre: nombre,
          telefono: telefono.isNotEmpty ? telefono : null,
          email: email.isNotEmpty ? email : null,
          direccion: direccion.isNotEmpty ? direccion : null,
          notas: notas.isNotEmpty ? notas : null,
          activo: true,
          createdAt: now,
        ),
      );
    }

    final newState = ref.read(clientesProvider);
    if (newState.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Cliente actualizado' : 'Cliente creado')),
      );
      ref.read(clientesProvider.notifier).resetSuccess();
      if (context.mounted) context.pop();
    } else if (newState.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState.error!), backgroundColor: Colors.red),
      );
      ref.read(clientesProvider.notifier).resetError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
        backgroundColor: colorScheme.primary,
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
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notasController,
              decoration: InputDecoration(
                labelText: 'Notas',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            Consumer(builder: (context, ref, _) {
              final state = ref.watch(clientesProvider);
              final colors = ref.watch(empresaColorsSyncProvider);
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: state.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Guardar Cambios' : 'Crear Cliente', style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}