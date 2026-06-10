import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    return picked != null ? File(picked.path) : null;
  }

  static Future<File?> pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    return picked != null ? File(picked.path) : null;
  }
}