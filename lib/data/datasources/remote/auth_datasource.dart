import 'package:guardaya_app/core/constants/api_constants.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class AuthDatasource {
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await SupabaseService.rpc(
      ApiConstants.loginRpc,
      params: {
        'p_username': username,
        'p_password': password,
      },
    );
    
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
    
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    // En auth custom, solo limpiamos local
  }
}