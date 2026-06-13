import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class AuthDatasource {
  /// Construye el email para Supabase Auth.
  /// Si ya tiene formato de email, lo usa directamente.
  /// Si no, usa username@guardaya.com (dominio de la app)
  String _buildEmail(String username) {
    if (username.contains('@')) return username;
    return '$username@guardaya.com';
  }

  Future<AuthResponse> login(String username, String password) async {
    try {
      final email = _buildEmail(username);
      print('AuthDatasource.login: email=$email');
      final response = await SupabaseService.withTimeout(
        SupabaseService.auth.signInWithPassword(
          email: email,
          password: password,
        ),
        operation: 'signInWithPassword',
      );
      print('AuthDatasource.login: success, session=${response.session != null}');
      return response;
    } on AuthException catch (e) {
      print('AuthDatasource.login: AuthException: ${e.message}');
      throw AuthException(message: e.message);
    } catch (e) {
      print('AuthDatasource.login: Exception: $e');
      throw AuthException(message: e.toString());
    }
  }

  /// Obtiene los datos completos del usuario (empresa, colores, rol)
  /// DESPUÉS de hacer login exitoso con Supabase Auth.
  Future<Map<String, dynamic>> getUsuarioCompleto() async {
    try {
      final data = await SupabaseService.withTimeout(
        SupabaseService.supabase.rpc('get_usuario_completo'),
        operation: 'get_usuario_completo',
      );
      return data as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Verifica que el usuario sigue activo en el servidor.
  /// Si no hay internet, devuelve false (el modo offline maneja eso).
  Future<bool> verifyUsuarioActivo() async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.supabase.rpc('verify_usuario_activo'),
        operation: 'verify_usuario_activo',
      );
      final data = response as Map<String, dynamic>;
      return data['activo'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Renueva el token de sesión usando el refresh token.
  Future<AuthResponse> refreshSession(String refreshToken) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.auth.refreshSession(refreshToken),
        operation: 'refreshSession',
      );
      return response;
    } catch (e) {
      throw AuthException(message: 'Error al renovar sesión: $e');
    }
  }

  /// Obtiene la sesión actual de Supabase.
  Future<Session?> getCurrentSession() async {
    return SupabaseService.auth.currentSession;
  }

  Future<void> logout() async {
    try {
      await SupabaseService.auth.signOut();
    } catch (e) {
      // Ignorar errores de logout
    }
  }
}
