import 'dart:io';
import 'package:guardaya_app/core/constants/api_constants.dart';
import 'package:guardaya_app/services/supabase_service.dart';

class OcrDatasource {
  Future<Map<String, dynamic>> extractRemote(String imageUrl) async {
    final response = await SupabaseService.supabase.functions.invoke(
      ApiConstants.ocrEdgeFunction,
      body: {'image_url': imageUrl},
    );

    if (response.status != 200) {
      throw Exception('Error en OCR remoto: ${response.status}');
    }

    return response.data as Map<String, dynamic>;
  }

  Future<String> uploadImageForOcr(File imageFile, String empresaId) async {
    final fileName = '${empresaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'ocr-temp/$fileName';
    
    await SupabaseService.storage.from('comprobantes').upload(
      path,
      imageFile,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    
    return SupabaseService.storage.from('comprobantes').getPublicUrl(path);
  }
}