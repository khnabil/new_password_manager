import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionUtil {
  // Helper function to derive key from password
  static encrypt.Key _generateKeyFromPassword(String password) {
    // Generate a 256-bit key from the password using SHA-256
    final keyBytes = utf8.encode(password); // Convert password to bytes
    final keyHash = sha256.convert(keyBytes); // SHA-256 hash of password
    return encrypt.Key.fromUtf8(
      keyHash.toString().substring(0, 32),
    ); // Use first 32 characters (256-bit)
  }

  // Helper function to derive IV from password (fixed length of 16 bytes)
  static encrypt.IV _generateIVFromPassword(String password) {
    // Use SHA-1 to create a 128-bit IV (16 bytes)
    final ivBytes = utf8.encode(password); // Convert password to bytes
    final ivHash = sha1.convert(ivBytes); // SHA-1 hash of password
    return encrypt.IV.fromUtf8(
      ivHash.toString().substring(0, 16),
    ); // Use first 16 bytes (128-bit)
  }

  // Encrypt a password using a consistent key
  static String encryptPassword(String password, String masterPassword) {
    final key = _generateKeyFromPassword(
      masterPassword,
    ); // Generate key from master password
    final iv = _generateIVFromPassword(
      masterPassword,
    ); // Generate IV from master password
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64; // Return the encrypted password in base64 format
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
