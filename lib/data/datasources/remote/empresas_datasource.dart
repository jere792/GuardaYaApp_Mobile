import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class EmpresasDatasource {
  Future<List<dynamic>> listarEmpresas() async {
    try {
      var query = SupabaseService.from('empresas').select().limit(100).order('created_at', ascending: false);
      final response = await SupabaseService.withTimeout(
        query,
        operation: 'listarEmpresas',
      );
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> crearEmpresa(Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('empresas').insert(data).select().single(),
        operation: 'crearEmpresa',
      );
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> actualizarEmpresa(String id, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.withTimeout(
        SupabaseService.from('empresas').update(data).eq('id', id).select().single(),
        operation: 'actualizarEmpresa',
      );
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> desactivarEmpresa(String id) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('empresas').update({'activo': false}).eq('id', id),
        operation: 'desactivarEmpresa',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> reactivarEmpresa(String id) async {
    try {
      await SupabaseService.withTimeout(
        SupabaseService.from('empresas').update({'activo': true}).eq('id', id),
        operation: 'reactivarEmpresa',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
