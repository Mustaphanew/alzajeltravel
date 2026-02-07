import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const String _tokenKey = 'access_token';
  static const String _kBiometricEnabled = 'Biometric Enabled';

  // ✅ احذف AndroidOptions القديمة (encryptedSharedPreferences)
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: _iosOptions,
  );

  static String? _cachedToken;

  static Future<String?> getToken() async {
    _cachedToken ??= await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.write(key: _kBiometricEnabled, value: 'false');
  }
}
