import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionUtil {
  static encrypt.Key _generateKeyFromPassword(String password) {
    final keyBytes = utf8.encode(password);
    final keyHash = sha256.convert(keyBytes);
    return encrypt.Key.fromUtf8(keyHash.toString().substring(0, 32));
  }

  static encrypt.IV _generateIVFromPassword(String password) {
    final ivBytes = utf8.encode(password);
    final ivHash = sha1.convert(ivBytes);
    return encrypt.IV.fromUtf8(ivHash.toString().substring(0, 16));
  }

  // Encrypt a password using a consistent key
  static String encryptPassword(String password, String masterPassword) {
    final key = _generateKeyFromPassword(masterPassword);
    final iv = _generateIVFromPassword(masterPassword);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Decrypt a password using the same key
  static String decryptPassword(
    String encryptedPassword,
    String masterPassword,
  ) {
    final key = _generateKeyFromPassword(
      masterPassword,
    ); // Generate key from master password
    final iv = _generateIVFromPassword(
      masterPassword,
    ); // Generate IV from master password
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted; // Return the decrypted password
  }
}
