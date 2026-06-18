import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class ProductosDatasource {
  Future<List<dynamic>> listarProductos(String empresaId) async {
    try {
      var query = SupabaseService.from('productos').select().eq('empresa_id', empresaId);
      final response = await SupabaseService.withTimeout(
        query.order('created_at', ascending: false),
        operation: 'listarProductos',
      );
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('productos').insert(data).select().single(),
        operation: 'crearProducto',
      );
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> actualizarProducto(String id, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('productos').update(data).eq('id', id).select().single(),
        operation: 'actualizarProducto',
      );
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> desactivarProducto(String id) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('productos').update({
          'activo': false,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id),
        operation: 'desactivarProducto',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> reactivarProducto(String id) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('productos').update({
          'activo': true,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id),
        operation: 'reactivarProducto',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
