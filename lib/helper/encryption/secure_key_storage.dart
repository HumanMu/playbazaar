import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> storeKeys(String key, String iv) async {
    await _storage.write(key: 'aes_key', value: key);
    await _storage.write(key: 'aes_iv', value: iv);
  }

  Future<String?> getKey() async {
    return await _storage.read(key: 'aes_key');
  }

  Future<String?> getIv() async {
    return await _storage.read(key: 'aes_iv');
  }
}


