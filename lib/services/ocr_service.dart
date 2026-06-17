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
      final codigoRegex = RegExp(
        r'(?:'
        r'Código\s*(?:de\s*)?operación|'
        r'N[°º0]\.?\s*(?:de\s*)?operación|'
        r'Nro\.?\s*(?:de\s*)?operación|'
        r'No\.?\s*(?:de\s*)?operación|'
        r'Número\s*(?:de\s*)?operación|'
        r'Operación\s*(?:N[°º0o]\.?|Nro\.?|No\.?)?|'
        r'Código'
        r')[:\s]*(\d{6,10})',
        caseSensitive: false,
      );
      final montoRegex = RegExp(r'S[\/\s]*\.?\s*(\d+[\.,]?\d*)', caseSensitive: false);
      final fechaRegex = RegExp(
        r'(\d{1,2}\s+(?:ene|feb|mar|abr|may|jun|jul|ago|sep|oct|nov|dic)[a-z]*\.?\s*\d{4})|'
        r'(\d{1,2}[\/-]\d{1,2}[\/-]\d{4})',
        caseSensitive: false,
      );
      final horaRegex = RegExp(r'(\d{1,2}:\d{2}(?::\d{2})?\s*[ap]\.?\s*m\.?)', caseSensitive: false);

      // Fallback: buscar cualquier número de 6-10 dígitos sin decimales
      final fallbackCodigoRegex = RegExp(r'\b(\d{6,10})\b');
      
      RegExpMatch? codigoMatch = codigoRegex.firstMatch(fullText);
      if (codigoMatch == null) {
        final allNumbers = fallbackCodigoRegex.allMatches(fullText);
        for (final match in allNumbers) {
          final num = match.group(1)!;
          // Descartar si parece año (2024-2030) o parte del monto
          final year = int.tryParse(num);
          if (num.length == 4 && year != null && year >= 2024 && year <= 2030) continue;
          codigoMatch = match;
          break;
        }
      }

      final montoMatch = montoRegex.firstMatch(fullText);
      final fechaMatch = fechaRegex.firstMatch(fullText);
      final horaMatch = horaRegex.firstMatch(fullText);
      
      double? monto;
      if (montoMatch != null) {
        final raw = montoMatch.group(1)?.replaceAll(',', '.');
        monto = double.tryParse(raw ?? '0');
      }
      
      final fecha = fechaMatch?.group(1) ?? fechaMatch?.group(2);
      final hora = horaMatch?.group(1)?.replaceAll(RegExp(r'\s+'), ' ').trim();

      return {
        'codigo': codigoMatch?.group(1),
        'monto': monto,
        'fecha': fecha,
        'hora': hora,
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
