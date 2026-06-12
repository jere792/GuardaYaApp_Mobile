import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class AuthDatasource {
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final data = await SupabaseService.rpc(
        'login_usuario',
        params: {
          'p_username': username,
          'p_password': password,
        },
      );
      return data as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  Future<void> logout() async {
    // En auth custom, solo limpiamos local
  }
}
