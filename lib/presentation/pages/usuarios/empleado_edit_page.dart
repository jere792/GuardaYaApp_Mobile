import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
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
  String _rolSeleccionado = 'empleado';
  bool _initialized = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _initControllers(empleado) {
    if (_initialized) return;
    _initialized = true;
    _usernameController.text = empleado.username;
    _nombreController.text = empleado.nombre;
    _emailController.text = empleado.email ?? '';
    _telefonoController.text = empleado.telefono ?? '';
    _rolSeleccionado = _normalizarRol(empleado.rolId);
  }

  String _normalizarRol(String rolId) {
    final id = rolId.toLowerCase();
    if (id.contains('admin') || id == '6801325e-df02-4391-a882-66247e664dcf') return 'admin';
    if (id.contains('super') || id == 'c63abe3d-5de8-442b-b8d8-9738ad9a7be5') return 'super_admin';
    return 'empleado';
  }

  void _handleGuardar() async {
    final nombre = _nombreController.text.trim();
    final username = _usernameController.text.trim();
    if (nombre.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y usuario son obligatorios')),
      );
      return;
    }
    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();

    await ref.read(usuariosProvider.notifier).actualizarEmpleado(
      userId: widget.empleadoId,
      nombre: nombre,
      username: username,
      email: email.isNotEmpty ? email : null,
      telefono: telefono.isNotEmpty ? telefono : null,
      rolNombre: _rolSeleccionado,
    );

    final state = ref.read(usuariosProvider);
    if (state.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado actualizado')),
      );
      ref.read(usuariosProvider.notifier).resetSuccess();
      context.pop();
    } else if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
      );
      ref.read(usuariosProvider.notifier).resetError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuariosState = ref.watch(usuariosProvider);
    final empleado = usuariosState.usuarios.where((u) => u.id == widget.empleadoId).firstOrNull;
    final colorScheme = Theme.of(context).colorScheme;
    final rolActual = ref.watch(authProvider).usuario?.rolId ?? 'empleado';

    if (empleado == null) {
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
        body: const Center(child: Text('Empleado no encontrado')),
      );
    }

    _initControllers(empleado);

    final rolesDisponibles = <String>['empleado'];
    if (rolActual == 'super_admin') rolesDisponibles.add('admin');
    if (rolActual == 'admin') rolesDisponibles.add('admin');

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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: rolesDisponibles.contains(_rolSeleccionado) ? _rolSeleccionado : rolesDisponibles.first,
              decoration: InputDecoration(
                labelText: 'Rol',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
              ),
              items: rolesDisponibles.map((rol) => DropdownMenuItem(
                value: rol,
                child: Text(rol == 'admin' ? 'Admin' : 'Empleado'),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _rolSeleccionado = value);
              },
            ),
            const SizedBox(height: 32),
            Consumer(builder: (context, ref, _) {
              final state = ref.watch(usuariosProvider);
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: state.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      ),
    );
  }
}