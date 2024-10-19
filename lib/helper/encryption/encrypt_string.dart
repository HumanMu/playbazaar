import 'package:playbazaar/helper/encryption/secure_key_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


class EncryptionHelper {
  static final _secureStorage = SecureKeyStorage();

  static Future<String> encryptPassword(String password) async {
    final key = await _secureStorage.getKey();
    final iv = await _secureStorage.getIv();

    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key!)));
    final encrypted = encrypter.encrypt(password, iv: encrypt.IV.fromUtf8(iv!));
    return encrypted.base64;
  }

  static Future<String> decryptPassword(String encryptedPassword) async {
    final key = await _secureStorage.getKey();
    final iv = await _secureStorage.getIv();

    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key!)));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: encrypt.IV.fromUtf8(iv!));
    return decrypted;
  }
}