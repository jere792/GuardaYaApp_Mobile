import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';

class OcrService {
  static final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<Map<String, dynamic>> extractFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _recognizer.processImage(inputImage);
      
      final fullText = recognizedText.text;
      
      // Regex para comprobantes Yape/Plin peruanos
      final codigoRegex = RegExp(r'(?:Código de operación|N° Operación|Operación|Nro)[^\d]*(\d{6,9})', caseSensitive: false);
      final montoRegex = RegExp(r'(?:S\/?\s*\/\s*|S\/?\s*\.\s*)\s*(\d+[\.,]?\d*)', caseSensitive: false);
      final fechaRegex = RegExp(r'(\d{2}[\/-]\d{2}[\/-]\d{4})');
      final horaRegex = RegExp(r'(\d{2}:\d{2}:\d{2})');
      
      final codigoMatch = codigoRegex.firstMatch(fullText);
      final montoMatch = montoRegex.firstMatch(fullText);
      final fechaMatch = fechaRegex.firstMatch(fullText);
      final horaMatch = horaRegex.firstMatch(fullText);
      
      double? monto;
      if (montoMatch != null) {
        final raw = montoMatch.group(1)?.replaceAll(',', '.');
        monto = double.tryParse(raw ?? '0');
      }
      
      return {
        'codigo': codigoMatch?.group(1),
        'monto': monto,
        'fecha': fechaMatch?.group(1),
        'hora': horaMatch?.group(1),
        'texto_completo': fullText,
        'confianza': _calculateConfidence(codigoMatch, montoMatch, fechaMatch),
      };
    } catch (e) {
      throw OcrException(message: 'Error al procesar OCR local: ${e.toString()}');
    }
  }

  static double _calculateConfidence(RegExpMatch? codigo, RegExpMatch? monto, RegExpMatch? fecha) {
    int matches = 0;
    if (codigo != null) matches++;
    if (monto != null) matches++;
    if (fecha != null) matches++;
    return matches / 3;
  }

  static void dispose() {
    _recognizer.close();
  }
}