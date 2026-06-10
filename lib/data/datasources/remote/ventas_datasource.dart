import 'package:guardaya_app/services/supabase_service.dart';

class VentasDatasource {
  Future<List<Map<String, dynamic>>> obtenerVentasPorFecha(String empresaId, DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day).toIso8601String();
    final fin = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59).toIso8601String();
    
    final response = await SupabaseService.from('ventas')
      .select()
      .eq('empresa_id', empresaId)
      .gte('created_at', inicio)
      .lte('created_at', fin)
      .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> buscarVentaPorCodigo(String empresaId, String codigo) async {
    final response = await SupabaseService.from('ventas')
      .select()
      .eq('empresa_id', empresaId)
      .eq('codigo_yape', codigo)
      .maybeSingle();
    
    return response;
  }

  Future<List<Map<String, dynamic>>> buscarVentaPorTelefono(String empresaId, String telefono) async {
    final response = await SupabaseService.from('ventas')
      .select()
      .eq('empresa_id', empresaId)
      .ilike('cliente_telefono', '%$telefono%')
      .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> registrarVenta(Map<String, dynamic> venta) async {
    final response = await SupabaseService.from('ventas')
      .insert(venta)
      .select()
      .single();
    
    return response;
  }

  Future<void> cambiarEstadoVenta(String ventaId, String nuevoEstado) async {
    await SupabaseService.from('ventas')
      .update({'estado': nuevoEstado, 'updated_at': DateTime.now().toIso8601String()})
      .eq('id', ventaId);
  }
}