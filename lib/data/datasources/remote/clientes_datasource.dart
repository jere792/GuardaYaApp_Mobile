import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class ClientesDatasource {
  Future<List<dynamic>> listarClientes(String empresaId) async {
    try {
      log('ClientesDatasource.listarClientes: empresaId=$empresaId');
      var query = SupabaseService.from('clientes').select().eq('empresa_id', empresaId);
      final response = await SupabaseService.withTimeout(
        query.order('created_at', ascending: false),
        operation: 'listarClientes',
      );
      log('ClientesDatasource.listarClientes: response length=${response.length}');
      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> obtenerClientes(String empresaId) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('clientes')
        .select()
        .eq('empresa_id', empresaId)
        .eq('activo', true)
        .order('nombre'),
      operation: 'obtenerClientes',
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> buscarClientePorTelefono(String empresaId, String telefono) async {
    return await SupabaseService.withTimeout(
      SupabaseService.from('clientes')
        .select()
        .eq('empresa_id', empresaId)
        .eq('telefono', telefono)
        .maybeSingle(),
      operation: 'buscarClientePorTelefono',
    );
  }

  Future<Map<String, dynamic>> crearCliente(Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('clientes').insert(data).select().single(),
        operation: 'crearCliente',
      );
      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> actualizarCliente(String id, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('clientes').update(data).eq('id', id).select().single(),
        operation: 'actualizarCliente',
      );
      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> desactivarCliente(String id, {bool reactivar = false}) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('clientes').update({
          'activo': reactivar,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id),
        operation: 'desactivarCliente',
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
