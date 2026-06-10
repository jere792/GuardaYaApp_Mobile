import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseSecretKey => dotenv.env['SUPABASE_SECRET_KEY'] ?? '';
  
  static String get ocrEdgeFunction => dotenv.env['OCR_EDGE_FUNCTION'] ?? 'ocr-extract';
  static String get loginRpc => 'login_usuario';
  static String get buscarVentasRpc => 'buscar_ventas';
  
  static double get ocrConfidenceThreshold {
    final value = dotenv.env['OCR_CONFIDENCE_THRESHOLD'];
    return value != null ? double.tryParse(value) ?? 0.7 : 0.7;
  }
}
