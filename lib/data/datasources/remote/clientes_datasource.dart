import 'package:guardaya_app/services/supabase_service.dart';

class ClientesDatasource {
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

  Future<Map<String, dynamic>> crearCliente(Map<String, dynamic> cliente) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('clientes')
        .insert(cliente)
        .select()
        .single(),
      operation: 'crearCliente',
    );
    
    return response;
  }
}
