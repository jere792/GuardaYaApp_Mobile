import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class UsuarioDatasource {
  /// Crear usuario usando RPC con bcrypt (seguro para login).
  Future<Map<String, dynamic>> crearUsuario({
    required String username,
    required String password,
    required String nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? empresaId,
    required String rolNombre,
  }) async {
    try {
      final params = <String, dynamic>{
        'p_username': username,
        'p_password': password,
        'p_nombre': nombre,
        'p_rol_nombre': rolNombre,
      };
      if (apellidos != null) params['p_apellidos'] = apellidos;
      if (telefono != null) params['p_telefono'] = telefono;
      if (email != null) params['p_email'] = email;
      if (empresaId != null) params['p_empresa_id'] = empresaId;

      final data = await SupabaseService.rpc(
        'crear_usuario_bcrypt',
        params: params,
      );
      return data as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Listar usuarios.
  /// Si es super_admin (rol == 'super_admin'), lista TODOS los usuarios.
  /// Si es admin, lista solo los de su empresa.
  Future<List<dynamic>> listarUsuarios(String? empresaId, String rol) async {
    try {
      log('UsuarioDatasource.listarUsuarios: rol=$rol, empresaId=$empresaId');

      // ⚠️ query.eq() devuelve un NUEVO builder; hay que capturarlo
      var query = SupabaseService.from('usuarios').select();

      if (rol != 'super_admin') {
        // Admin: solo usuarios de su empresa
        if (empresaId == null || empresaId.isEmpty) {
          log('UsuarioDatasource.listarUsuarios: ERROR - empresaId es null/vacio para admin');
          throw ServerException(message: 'El admin no tiene empresa asignada');
        }
        query = query.eq('empresa_id', empresaId);
        log('UsuarioDatasource.listarUsuarios: filtro empresa_id=$empresaId aplicado');
      } else {
        log('UsuarioDatasource.listarUsuarios: super_admin - sin filtro de empresa');
      }

      final response = await SupabaseService.withTimeout(
        query.order('created_at', ascending: false),
        operation: 'listarUsuarios',
      );

      log('UsuarioDatasource.listarUsuarios: response length=${(response as List).length}');
      return List<dynamic>.from(response);
    } on PostgrestException catch (e) {
      log('UsuarioDatasource.listarUsuarios: PostgrestException - ${e.message}');
      throw ServerException(message: e.message);
    } catch (e) {
      log('UsuarioDatasource.listarUsuarios: Exception - $e');
      throw ServerException(message: e.toString());
    }
  }

  /// Actualizar datos básicos de un usuario (nombre, username, email, teléfono, rol)
  Future<Map<String, dynamic>> actualizarUsuario({
    required String userId,
    required String nombre,
    required String username,
    String? email,
    String? telefono,
    required String rolNombre,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'nombre': nombre,
        'username': username,
        'rol_nombre': rolNombre,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (email != null) updateData['email'] = email;
      if (telefono != null) updateData['telefono'] = telefono;

      await SupabaseService.withTimeout(
        SupabaseService.from('usuarios')
            .update(updateData)
            .eq('id', userId),
        operation: 'actualizarUsuario',
      );
      return {'success': true};
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Desactivar usuario (query directa)
  Future<Map<String, dynamic>> desactivarUsuario(String userId) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('usuarios')
            .update({
              'activo': false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId),
        operation: 'desactivarUsuario',
      );
      return {'success': true};
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
