import 'dart:io';
import 'package:guardaya_app/core/constants/api_constants.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class OcrDatasource {
  Future<Map<String, dynamic>> extractRemote(String imageUrl) async {
    final response = await SupabaseService.withTimeout(
      SupabaseService.supabase.functions.invoke(
        ApiConstants.ocrEdgeFunction,
        body: {'image_url': imageUrl},
      ),
      operation: 'extractRemote OCR',
    );

    if (response.status != 200) {
      throw Exception('Error en OCR remoto: ${response.status}');
    }

    return response.data as Map<String, dynamic>;
  }

  /// Sube la imagen a un bucket privado y devuelve una URL firmada (signed URL)
  /// con tiempo de expiración. Esto evita que la imagen sea accesible públicamente.
  Future<String> uploadImageForOcr(File imageFile, String empresaId) async {
    final fileName = '${empresaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'ocr-temp/$fileName';

    await SupabaseService.withTimeout(
      SupabaseService.storage.from('comprobantes').upload(path, imageFile),
      operation: 'uploadImageForOcr',
    );

    // Generar signed URL válida por 5 minutos (300 segundos)
    final signedUrl = await SupabaseService.withTimeout(
      SupabaseService.storage.from('comprobantes').createSignedUrl(path, 300),
      operation: 'createSignedUrl',
    );

    return signedUrl;
  }

  /// Elimina la imagen temporal del bucket después de procesarla.
  Future<void> deleteTempImage(String path) async {
    await SupabaseService.withTimeout(
      SupabaseService.storage.from('comprobantes').remove([path]),
      operation: 'deleteTempImage',
    );
  }
}
