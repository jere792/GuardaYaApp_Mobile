import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class EmpresaSimple {
  final String id;
  final String nombre;
  EmpresaSimple({required this.id, required this.nombre});
}

final empresasActivasProvider = FutureProvider<List<EmpresaSimple>>((ref) async {
  final data = await SupabaseService.from('empresas')
      .select('id, nombre')
      .order('nombre', ascending: true)
      .timeout(const Duration(seconds: 15));

  return (data as List).map((e) => EmpresaSimple(
    id: e['id'] as String,
    nombre: e['nombre'] as String,
  )).toList();
});
