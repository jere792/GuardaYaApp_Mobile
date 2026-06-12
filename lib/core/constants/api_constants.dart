import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  /// IMPORTANT: No incluir nunca la SUPABASE_SECRET_KEY en el cliente.
  /// La secret key solo debe usarse en el backend (edge functions, triggers).
  /// Si alguien la extrae del APK puede saltarse todas las políticas RLS.
  ///
  /// Para PRODUCCIÓN, usar --dart-define:
  ///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  /// Para DESARROLLO, usar .env (cargado automáticamente por main.dart)
  
  static String get supabaseUrl {
    const dartValue = String.fromEnvironment('SUPABASE_URL');
    if (dartValue.isNotEmpty) return dartValue;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  static String get supabaseAnonKey {
    const dartValue = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (dartValue.isNotEmpty) return dartValue;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static String get ocrEdgeFunction {
    const dartValue = String.fromEnvironment('OCR_EDGE_FUNCTION');
    if (dartValue.isNotEmpty) return dartValue;
    return dotenv.env['OCR_EDGE_FUNCTION'] ?? 'ocr-extract';
  }
  
  static const String buscarVentasRpc = 'buscar_ventas';

  static double get ocrConfidenceThreshold {
    const dartValue = String.fromEnvironment('OCR_CONFIDENCE_THRESHOLD');
    if (dartValue.isNotEmpty) {
      return double.tryParse(dartValue) ?? 0.7;
    }
    final dotenvValue = dotenv.env['OCR_CONFIDENCE_THRESHOLD'];
    return dotenvValue != null ? double.tryParse(dotenvValue) ?? 0.7 : 0.7;
  }
}
