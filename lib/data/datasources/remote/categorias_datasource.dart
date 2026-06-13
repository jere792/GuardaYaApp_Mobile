import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class CategoriasDatasource {
  Future<List<dynamic>> listarCategorias(String empresaId) async {
    try {
      log('CategoriasDatasource.listarCategorias: empresaId=$empresaId');
      var query = SupabaseService.from('categorias').select().eq('empresa_id', empresaId);
      final response = await SupabaseService.withTimeout(
        query.order('created_at', ascending: false),
        operation: 'listarCategorias',
      );
      log('CategoriasDatasource.listarCategorias: response length=${response.length}');
      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> crearCategoria(Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('categorias').insert(data).select().single(),
        operation: 'crearCategoria',
      );
      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> actualizarCategoria(String id, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('categorias').update(data).eq('id', id).select().single(),
        operation: 'actualizarCategoria',
      );
      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> desactivarCategoria(String id) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('categorias').update({
          'activo': false,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id),
        operation: 'desactivarCategoria',
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}