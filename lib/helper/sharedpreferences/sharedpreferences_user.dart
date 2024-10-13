import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';

class SharedPreferencesFunctions {
  static Future<void> saveUserRole(UserRole role) async {
    final key = encrypt.Key.fromUtf8('your_secure_encryption_key'); // Replace with a strong key
    final iv = encrypt.IV.fromLength(16); // Initialization vector
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encryptedRole = encrypter.encrypt(role.name, iv: iv);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', encryptedRole.base64);
  }

  static Future<UserRole?> getUserRole() async {
    final key = encrypt.Key.fromUtf8('your_secure_encryption_key');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final prefs = await SharedPreferences.getInstance();
    final encryptedRole = prefs.getString('user_role');
    if (encryptedRole != null) {
      try {
        final decryptedRole = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedRole), iv: iv);
        return UserRole.values.firstWhere((r) => r.name == decryptedRole);
      } catch (e) {
        // Handle decryption errors
        //print('Error decrypting user role: $e');
        return null;
      }
    }
    return null;
  }
}


//https://www.youtube.com/watch?v=zJrYAZ2xZwE
