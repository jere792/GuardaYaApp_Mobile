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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _rolSeleccionado = 'empleado';
  String? _empresaSeleccionada;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value, String campo) {
    if (value == null || value.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rolSeleccionado != 'super_admin' && _empresaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una empresa')),
      );
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();

    await ref.read(usuariosProvider.notifier).crearEmpleado(
      username: username,
      password: password,
      nombre: nombre,
      apellidos: apellidos,
      email: email.isNotEmpty ? email : null,
      telefono: telefono,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        validator: (v) {
                          if (_rolSeleccionado != 'super_admin' && v == null) return 'Seleccione una empresa';
                          return null;
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
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                maxLength: 30,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'El usuario es obligatorio';
                  if (v.trim().length < 3) return 'Debe tener al menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contrase\u00f1a *',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                maxLength: 50,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'La contrase\u00f1a es obligatoria';
                  if (v.trim().length < 6) return 'Debe tener al menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                validator: (v) => _validarRequerido(v, 'El nombre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidosController,
                decoration: InputDecoration(
                  labelText: 'Apellidos *',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Los apellidos son obligatorios';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email (opcional)',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
                keyboardType: TextInputType.emailAddress,
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'El teléfono es obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Rol *',
                  prefixIcon: const Icon(Icons.security),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }
}
