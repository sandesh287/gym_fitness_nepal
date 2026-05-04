import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _phoneKey = 'user_phone';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> savePhone(String phone) async {
    await _storage.write(key: _phoneKey, value: phone);
  }

  Future<String?> getPhone() async {
    return await _storage.read(key: _phoneKey);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _phoneKey);
  }
}