import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/empresa_colors_provider.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class CrearEmpleadoPage extends ConsumerStatefulWidget {
  const CrearEmpleadoPage({super.key});

  @override
  ConsumerState<CrearEmpleadoPage> createState() => _CrearEmpleadoPageState();
}

class _CrearEmpleadoPageState extends ConsumerState<CrearEmpleadoPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  String _rolSeleccionado = 'empleado';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El usuario debe tener al menos 3 caracteres')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }
    if (email.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El email no es válido')),
      );
      return;
    }

    final empresaId = ref.read(authProvider).usuario?.empresaId;
    if (empresaId == null || empresaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró empresa asociada')),
      );
      return;
    }

    await ref.read(usuariosProvider.notifier).crearEmpleado(
      username: username,
      password: password,
      nombre: nombre,
      email: email.isNotEmpty ? email : null,
      empresaId: empresaId,
      rolNombre: _rolSeleccionado,
    );

    final currentState = ref.read(usuariosProvider);
    if (currentState.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado creado exitosamente')),
      );
      ref.read(usuariosProvider.notifier).resetSuccess();
      context.pop();
    } else if (currentState.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentState.error!)),
      );
      ref.read(usuariosProvider.notifier).resetError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuariosState = ref.watch(usuariosProvider);
    final rolActual = ref.watch(authProvider).usuario?.rolId ?? 'empleado';
    final empresaColors = ref.watch(empresaColorsSyncProvider);

    // Solo admin puede crear empleado, super_admin puede crear empleado y admin
    final rolesDisponibles = <String>['empleado'];
    if (rolActual == 'super_admin') rolesDisponibles.add('admin');
    if (rolActual == 'admin') rolesDisponibles.add('admin');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Empleado'),
        backgroundColor: empresaColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Usuario *',
                prefixIcon: const Icon(Icons.person),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: empresaColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña *',
                prefixIcon: const Icon(Icons.lock),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: empresaColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre completo *',
                prefixIcon: const Icon(Icons.badge),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: empresaColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: empresaColors.primary),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _rolSeleccionado,
              decoration: InputDecoration(
                labelText: 'Rol',
                prefixIcon: const Icon(Icons.security),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: empresaColors.primary),
                ),
              ),
              items: rolesDisponibles.map((rol) => DropdownMenuItem(
                value: rol,
                child: Text(rol.toUpperCase()),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _rolSeleccionado = value);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: usuariosState.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: empresaColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: usuariosState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Crear Empleado', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
