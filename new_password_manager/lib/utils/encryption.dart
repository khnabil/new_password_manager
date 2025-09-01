import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtil {
  // Encrypt a password
  static String encryptPassword(String password) {
    final key = encrypt.Key.fromSecureRandom(32); // 32 bytes for AES-256
    final iv = encrypt.IV.fromSecureRandom(16); // 16 bytes for AES
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Decrypt a password
  static String decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromSecureRandom(32); // Same key for decryption
    final iv = encrypt.IV.fromSecureRandom(16); // Same iv for decryption
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }
}
