import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class UsuarioDatasource {
  Future<Map<String, dynamic>> crearUsuario({
    required String username,
    required String password,
    required String nombre,
    String? email,
    required String empresaId,
    required String rolNombre,
  }) async {
    try {
      final data = await SupabaseService.rpc(
        'crear_usuario_rpc',
        params: {
          'p_username': username,
          'p_password': password,
          'p_nombre': nombre,
          'p_email': email,
          'p_empresa_id': empresaId,
          'p_rol_nombre': rolNombre,
        },
      );
      return data as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<List<dynamic>> listarUsuarios(String empresaId) async {
    try {
      final data = await SupabaseService.rpc(
        'listar_usuarios_rpc',
        params: {
          'p_empresa_id': empresaId,
        },
      );
      // El RPC devuelve un JSONB array, Supabase lo parsea como List<dynamic>
      return data as List<dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> desactivarUsuario(String userId) async {
    try {
      final data = await SupabaseService.rpc(
        'desactivar_usuario_rpc',
        params: {
          'p_user_id': userId,
        },
      );
      return data as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
