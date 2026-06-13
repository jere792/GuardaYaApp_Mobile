import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class CrearUsuarioTempPage extends ConsumerStatefulWidget {
  const CrearUsuarioTempPage({super.key});

  @override
  ConsumerState<CrearUsuarioTempPage> createState() => _CrearUsuarioTempPageState();
}

class _CrearUsuarioTempPageState extends ConsumerState<CrearUsuarioTempPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  String? _empresaId;
  String? _rolId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final List<Map<String, String>> _empresas = [
    {'id': '41716bfd-d569-465a-a7cc-743d9731d1f6', 'nombre': 'Tech Solutions'},
    {'id': 'fc43b8f3-0d05-457b-a886-6371edd987fa', 'nombre': 'Digital Store'},
  ];

  final List<Map<String, String>> _roles = [
    {'id': '77cdd9df-e7fe-4984-9bd9-9ab2168abf5b', 'nombre': 'empleado'},
    {'id': '6801325e-df02-4391-a882-66247e664dcf', 'nombre': 'admin'},
    {'id': 'c63abe3d-5de8-442b-b8d8-9738ad9a7be5', 'nombre': 'super_admin'},
  ];

  Future<void> _crearUsuario() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final nombre = _nombreController.text.trim();
      final apellidos = _apellidosController.text.trim().isEmpty
          ? null
          : _apellidosController.text.trim();
      final telefono = _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim();
      // Email para Supabase Auth (interno, nunca visible al usuario)
      final emailAuth = '$username@user.local';
      // Email opcional del usuario (solo para guardar en public.usuarios)
      final emailUsuario = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();

      if (username.isEmpty || password.isEmpty || nombre.isEmpty || _rolId == null) {
        setState(() {
          _errorMessage = 'Complete todos los campos obligatorios';
          _isLoading = false;
        });
        return;
      }

      // Si es super_admin, empresa_id puede ser null
      final isSuperAdmin = _rolId == 'c63abe3d-5de8-442b-b8d8-9738ad9a7be5';
      if (!isSuperAdmin && _empresaId == null) {
        setState(() {
          _errorMessage = 'Seleccione una empresa (requerido para admin y empleado)';
          _isLoading = false;
        });
        return;
      }

      // Crear usuario en Supabase Auth
      final userData = {
        'username': username,
        'nombre': nombre,
        'rol_id': _rolId,
      };
      // Solo agregar campos opcionales si el usuario los ingresó
      if (apellidos != null) {
        userData['apellidos'] = apellidos;
      }
      if (telefono != null) {
        userData['telefono'] = telefono;
      }
      if (!isSuperAdmin && _empresaId != null) {
        userData['empresa_id'] = _empresaId;
      }
      if (emailUsuario != null) {
        userData['email_usuario'] = emailUsuario;
      }

      final response = await SupabaseService.auth.signUp(
        email: emailAuth,
        password: password,
        data: userData,
      );

      if (response.user != null) {
        setState(() {
          _successMessage = 'Usuario $username creado exitosamente!\n\nIMPORTANTE: El usuario fue creado pero el email NO está confirmado. Debes confirmar el email desde el panel de Supabase o usar un Edge Function para confirmarlo automáticamente.';
          _isLoading = false;
        });

        // Limpiar campos
        _usernameController.clear();
        _passwordController.clear();
        _nombreController.clear();
        _apellidosController.clear();
        _telefonoController.clear();
        _emailController.clear();
        setState(() {
          _empresaId = null;
          _rolId = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al crear usuario';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario (Temporal)'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Página temporal para crear usuarios en Supabase Auth',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'ej: admin1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'ej: admin123',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Nombre
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'ej: Juan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Apellidos
              TextField(
                controller: _apellidosController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  hintText: 'ej: Perez Garcia',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Telefono
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'ej: +51 999 888 777',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email (opcional)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                  hintText: 'ej: admin@gmail.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Empresa
              DropdownButtonFormField<String>(
                value: _empresaId,
                decoration: const InputDecoration(
                  labelText: 'Empresa',
                  border: OutlineInputBorder(),
                ),
                items: _empresas.map((empresa) {
                  return DropdownMenuItem(
                    value: empresa['id'],
                    child: Text(empresa['nombre']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _empresaId = value);
                },
              ),
              const SizedBox(height: 16),
              
              // Rol
              DropdownButtonFormField<String>(
                value: _rolId,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((rol) {
                  return DropdownMenuItem(
                    value: rol['id'],
                    child: Text(rol['nombre']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _rolId = value);
                },
              ),
              const SizedBox(height: 24),
              
              // Error
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              // Success
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Botón crear
              ElevatedButton(
                onPressed: _isLoading ? null : _crearUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear Usuario',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              
              const SizedBox(height: 32),
              
              // Usuarios predefinidos
              const Text(
                'Usuarios predefinidos para crear:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildUsuarioPredefinido('admin1', 'admin123', 'Juan', 'Perez', '+51 999 888 777', 'Tech Solutions', 'admin'),
              _buildUsuarioPredefinido('admin2', 'admin123', 'Maria', 'Lopez', '+51 999 888 666', 'Digital Store', 'admin'),
              _buildUsuarioPredefinido('empleado1', 'empleado123', 'Pedro', 'Garcia', '+51 999 888 555', 'Tech Solutions', 'empleado'),
              _buildUsuarioPredefinido('empleado2', 'empleado123', 'Ana', 'Martinez', '+51 999 888 444', 'Digital Store', 'empleado'),
              _buildUsuarioPredefinido('jeremy12', 'jeremy12', 'Jeremy', 'Yazid', '+51 999 888 333', 'Tech Solutions', 'super_admin'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioPredefinido(String username, String password, String nombre, String apellidos, String telefono, String empresa, String rol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(username),
        subtitle: Text('$nombre $apellidos - $empresa ($rol)'),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            _usernameController.text = username;
            _passwordController.text = password;
            _nombreController.text = nombre;
            _apellidosController.text = apellidos;
            _telefonoController.text = telefono;
            _empresaId = _empresas.firstWhere((e) => e['nombre'] == empresa)['id'];
            _rolId = _roles.firstWhere((r) => r['nombre'] == rol)['id'];
            setState(() {});
          },
        ),
      ),
    );
  }
}
