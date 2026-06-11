import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardaya_app/core/constants/app_constants.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveSession(String token) async {
    await _storage.write(key: AppConstants.jwtSessionKey, value: token);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: AppConstants.jwtSessionKey);
  }

  static Future<void> deleteSession() async {
    await _storage.delete(key: AppConstants.jwtSessionKey);
  }

  static Future<void> saveEmpresaId(String empresaId) async {
    await _storage.write(key: AppConstants.empresaIdKey, value: empresaId);
  }

  static Future<String?> getEmpresaId() async {
    return await _storage.read(key: AppConstants.empresaIdKey);
  }

  static Future<void> deleteEmpresaId() async {
    await _storage.delete(key: AppConstants.empresaIdKey);
  }

  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: AppConstants.userKey, value: userJson);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  static Future<void> saveEmpresaColors(String colorsJson) async {
    await _storage.write(key: AppConstants.empresaColorsKey, value: colorsJson);
  }

  static Future<String?> getEmpresaColors() async {
    return await _storage.read(key: AppConstants.empresaColorsKey);
  }

  static Future<void> deleteEmpresaColors() async {
    await _storage.delete(key: AppConstants.empresaColorsKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
