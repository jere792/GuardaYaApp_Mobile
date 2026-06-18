import 'package:guardaya_app/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class VentasDatasource {
  Future<List<Map<String, dynamic>>> obtenerVentasPorFecha(String empresaId, DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day).toIso8601String();
    final fin = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59).toIso8601String();
    
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .select()
        .eq('empresa_id', empresaId)
        .gte('created_at', inicio)
        .lte('created_at', fin)
        .order('created_at', ascending: false),
      operation: 'obtenerVentasPorFecha',
    );
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> buscarVentaPorCodigo(String empresaId, String codigo) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .select()
        .eq('empresa_id', empresaId)
        .eq('codigo_yape', codigo)
        .maybeSingle(),
      operation: 'buscarVentaPorCodigo',
    );
    
    return response;
  }

  Future<List<Map<String, dynamic>>> buscarVentaPorTelefono(String empresaId, String telefono) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .select()
        .eq('empresa_id', empresaId)
        .ilike('cliente_telefono', '%$telefono%')
        .order('created_at', ascending: false),
      operation: 'buscarVentaPorTelefono',
    );
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> registrarVenta(Map<String, dynamic> venta) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .insert(venta)
        .select()
        .single(),
      operation: 'registrarVenta',
    );
    
    return response;
  }

  Future<List<Map<String, dynamic>>> obtenerVentasPorRango(String empresaId, DateTime desde, DateTime hasta) async {
    final inicio = DateTime(desde.year, desde.month, desde.day).toIso8601String();
    final fin = DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59).toIso8601String();

    final response = await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .select()
        .eq('empresa_id', empresaId)
        .gte('created_at', inicio)
        .lte('created_at', fin)
        .order('created_at', ascending: false),
      operation: 'obtenerVentasPorRango',
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> obtenerVentaPorId(String ventaId) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .select()
        .eq('id', ventaId)
        .single(),
      operation: 'obtenerVentaPorId',
    );
    return response;
  }

  Future<void> registrarVentaProductos(String ventaId, String empresaId, List<Map<String, dynamic>> productos) async {
    if (productos.isEmpty) return;
    final payload = productos.map((p) => {
      'id': const Uuid().v4(),
      'venta_id': ventaId,
      'empresa_id': empresaId,
      'nombre': p['nombre'],
      'cantidad': p['cantidad'],
      'precio_unitario': p['precio'],
      'subtotal': p['subtotal'],
    }).toList();
    await SupabaseService.withTimeout(
      SupabaseService.from('venta_productos').insert(payload),
      operation: 'registrarVentaProductos',
    );
  }

  Future<void> cambiarEstadoVenta(String ventaId, String nuevoEstado) async {
    await SupabaseService.withTimeout(
      SupabaseService.from('ventas')
        .update({'estado': nuevoEstado, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', ventaId),
      operation: 'cambiarEstadoVenta',
    );
  }
}
