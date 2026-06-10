import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guardaya_app/core/constants/api_constants.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get supabase => Supabase.instance.client;
  static GoTrueClient get auth => supabase.auth;
  static SupabaseQueryBuilder from(String table) => supabase.from(table);
  static SupabaseStorageClient get storage => supabase.storage;

  static Future<PostgrestResponse> rpc(String fn, {Map<String, dynamic>? params}) async {
    return await supabase.rpc(fn, params: params ?? {});
  }
}