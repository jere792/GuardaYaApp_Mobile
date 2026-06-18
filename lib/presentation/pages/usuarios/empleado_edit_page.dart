import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class EmpleadoEditPage extends ConsumerStatefulWidget {
  final String empleadoId;

  const EmpleadoEditPage({super.key, required this.empleadoId});

  @override
  ConsumerState<EmpleadoEditPage> createState() => _EmpleadoEditPageState();
}

class _EmpleadoEditPageState extends ConsumerState<EmpleadoEditPage> {
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuariosState = ref.watch(usuariosProvider);
    final empleado = usuariosState.usuarios.where((u) => u.id == widget.empleadoId).firstOrNull;
    final colorScheme = Theme.of(context).colorScheme;

    if (empleado == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Empleado'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: const Center(child: Text('Empleado no encontrado')),
      );
    }

    if (_usernameController.text.isEmpty) {
      _usernameController.text = empleado.username;
      _nombreController.text = empleado.nombre;
      _emailController.text = empleado.email ?? '';
      _telefonoController.text = empleado.telefono ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Empleado'),
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
            Text(
              'Editando a ${empleado.nombre}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            _buildField('Nombre', _nombreController, Icons.person),
            const SizedBox(height: 16),
            _buildField('Usuario', _usernameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildField('Email', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField('Teléfono', _telefonoController, Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cambios guardados')),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}