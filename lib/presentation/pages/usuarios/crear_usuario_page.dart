import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/presentation/providers/empresas_provider.dart';
import 'package:guardaya_app/presentation/providers/usuarios_provider.dart';

class CrearUsuarioPage extends ConsumerStatefulWidget {
  const CrearUsuarioPage({super.key});

  @override
  ConsumerState<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends ConsumerState<CrearUsuarioPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  String _rolSeleccionado = 'empleado';
  String? _empresaSeleccionada;

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
        const SnackBar(content: Text('La contrase\u00f1a debe tener al menos 6 caracteres')),
      );
      return;
    }
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }
    if (_rolSeleccionado != 'super_admin' && _empresaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una empresa')),
      );
      return;
    }
    if (email.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El email no es v\u00e1lido')),
      );
      return;
    }

    await ref.read(usuariosProvider.notifier).crearEmpleado(
      username: username,
      password: password,
      nombre: nombre,
      email: email.isNotEmpty ? email : null,
      empresaId: _empresaSeleccionada,
      rolNombre: _rolSeleccionado,
    );

    final currentState = ref.read(usuariosProvider);
    if (currentState.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado exitosamente')),
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
    final colorScheme = Theme.of(context).colorScheme;
    final empresasAsync = ref.watch(empresasActivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Empresa selector
            empresasAsync.when(
              data: (empresas) {
                if (_rolSeleccionado == 'super_admin') return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _empresaSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Empresa *',
                        prefixIcon: const Icon(Icons.business),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                      ),
                      items: empresas.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.nombre),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _empresaSeleccionada = value);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Error al cargar empresas: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Usuario *',
                prefixIcon: const Icon(Icons.person),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contrase\u00f1a *',
                prefixIcon: const Icon(Icons.lock),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
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
                  borderSide: BorderSide(color: colorScheme.primary),
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
                  borderSide: BorderSide(color: colorScheme.primary),
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
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
              ),
              items: ['empleado', 'admin', 'super_admin'].map((rol) => DropdownMenuItem(
                value: rol,
                child: Text(rol == 'super_admin' ? 'SUPER ADMIN' : rol.toUpperCase()),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rolSeleccionado = value;
                    if (value == 'super_admin') _empresaSeleccionada = null;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            Consumer(builder: (context, ref, _) {
              final state = ref.watch(usuariosProvider);
              return ElevatedButton(
                onPressed: state.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Crear Usuario', style: TextStyle(fontSize: 16)),
              );
            }),
          ],
        ),
      ),
    );
  }
}
