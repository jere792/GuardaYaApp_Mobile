import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase/supabase.dart' show FunctionException;
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class AuthDatasource {
  /// Login validado contra public.usuarios con bcrypt (via Edge Function)
  /// No usa Supabase Auth. Devuelve los datos del usuario directamente.
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final functionResponse = await SupabaseService.withTimeout(
        SupabaseService.supabase.functions.invoke(
          'login-custom',
          body: {'username': username, 'password': password},
        ),
        operation: 'login-custom',
      );

      final data = functionResponse.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        final errorMsg = data?['error'] ?? 'Credenciales inválidas';
        throw AuthException(message: errorMsg);
      }

      return data;
    } on AuthException catch (e) {
      print('AuthDatasource.login: AuthException: ${e.message}');
      throw AuthException(message: e.message);
    } on FunctionException catch (e) {
      final details = e.details as Map<String, dynamic>?;
      final errorMsg = details?['error'] ?? 'Usuario o contraseña incorrectos';
      print('AuthDatasource.login: FunctionException: $errorMsg');
      throw AuthException(message: errorMsg);
    } catch (e) {
      print('AuthDatasource.login: Exception: $e');
      throw AuthException(message: e.toString());
    }
  }

  /// Obtiene los datos completos del usuario por username (sin depender de auth.uid)
  Future<Map<String, dynamic>> getUsuarioCompleto(String username) async {
    try {
      final data = await SupabaseService.withTimeout(
        SupabaseService.supabase.rpc('get_usuario_completo_by_username', params: {
          'p_username': username,
        }),
        operation: 'get_usuario_completo_by_username',
      );
      return data as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Verifica que el usuario sigue activo en el servidor.
  Future<bool> verifyUsuarioActivo(String username) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.supabase.rpc('verify_usuario_activo_by_username', params: {
          'p_username': username,
        }),
        operation: 'verify_usuario_activo_by_username',
      );
      final data = response as Map<String, dynamic>;
      return data['activo'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    // No hace nada en el servidor porque no usamos Supabase Auth
    // El logout se maneja solo en el cliente (SecureStorage.clearAll)
  }
}
