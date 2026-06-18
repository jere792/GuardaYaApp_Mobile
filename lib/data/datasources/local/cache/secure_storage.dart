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

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  static Future<void> saveTokenExpiresAt(DateTime expiresAt) async {
    await _storage.write(key: 'token_expires_at', value: expiresAt.toIso8601String());
  }

  static Future<DateTime?> getTokenExpiresAt() async {
    final value = await _storage.read(key: 'token_expires_at');
    return value != null ? DateTime.tryParse(value) : null;
  }

  static Future<bool> getOfflineMode() async {
    final value = await _storage.read(key: 'offline_mode');
    return value == 'true';
  }

  static Future<void> setOfflineMode(bool value) async {
    await _storage.write(key: 'offline_mode', value: value.toString());
  }

  static Future<void> saveSessionStartedAt(DateTime value) async {
    await _storage.write(key: 'session_started_at', value: value.toIso8601String());
  }

  static Future<DateTime?> getSessionStartedAt() async {
    final value = await _storage.read(key: 'session_started_at');
    return value != null ? DateTime.tryParse(value) : null;
  }

  static Future<void> saveLastVerifiedAt(DateTime value) async {
    await _storage.write(key: 'last_verified_at', value: value.toIso8601String());
  }

  static Future<DateTime?> getLastVerifiedAt() async {
    final value = await _storage.read(key: 'last_verified_at');
    return value != null ? DateTime.tryParse(value) : null;
  }

  static Future<int> getLoginAttempts() async {
    final value = await _storage.read(key: 'login_attempts');
    return value != null ? int.tryParse(value) ?? 0 : 0;
  }

  static Future<void> incrementLoginAttempts() async {
    final current = await getLoginAttempts();
    await _storage.write(key: 'login_attempts', value: (current + 1).toString());
  }

  static Future<void> clearLoginAttempts() async {
    await _storage.delete(key: 'login_attempts');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
