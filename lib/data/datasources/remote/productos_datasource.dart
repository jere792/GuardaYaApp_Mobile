import 'package:guardaya_app/services/supabase_service.dart';

class ProductosDatasource {
  Future<List<Map<String, dynamic>>> obtenerProductos(String empresaId) async {
    final response = await SupabaseService.from('productos')
      .select()
      .eq('empresa_id', empresaId)
      .eq('activo', true)
      .order('nombre');
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> obtenerProductoPorId(String id) async {
    return await SupabaseService.from('productos')
      .select()
      .eq('id', id)
      .maybeSingle();
  }
}
