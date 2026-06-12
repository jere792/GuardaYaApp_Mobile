import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guardaya_app/core/constants/api_constants.dart';

class SupabaseService {
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    if (ApiConstants.supabaseUrl.isEmpty || ApiConstants.supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL o SUPABASE_ANON_KEY no están configuradas. '
        'Usa --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      publishableKey: ApiConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get supabase => Supabase.instance.client;
  static GoTrueClient get auth => supabase.auth;
  static SupabaseQueryBuilder from(String table) => supabase.from(table);
  static SupabaseStorageClient get storage => supabase.storage;

  static Future<dynamic> rpc(String fn, {Map<String, dynamic>? params}) async {
    return await supabase
        .rpc(fn, params: params ?? {})
        .timeout(_defaultTimeout, onTimeout: () => throw Exception('Timeout en RPC: $fn'));
  }

  /// Wrapper genérico para agregar timeout a cualquier Future de Supabase
  static Future<T> withTimeout<T>(Future<T> future, {String? operation}) async {
    return future.timeout(
      _defaultTimeout,
      onTimeout: () => throw Exception(
        operation != null ? 'Timeout: $operation' : 'Timeout en operación de Supabase',
      ),
    );
  }
}
