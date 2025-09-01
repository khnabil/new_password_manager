import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/password_model.dart';
import '../utils/encryption.dart';

class PasswordController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<void> saveMasterPassword(String password) async {
    try {
      if (kIsWeb) {
        // Use SharedPreferences for Web (instead of dart:html)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('masterPassword', password);
        print("Master password saved (Web)"); // Debug print
      } else {
        // Use FlutterSecureStorage for mobile and desktop platforms
        await _storage.write(key: 'masterPassword', value: password);
        print("Master password saved (Mobile/Desktop)"); // Debug print
      }
    } catch (e) {
      print("Error saving master password: $e");
    }
  }

  // Retrieve master password securely
  Future<String?> getMasterPassword() async {
    try {
      if (kIsWeb) {
        // Use SharedPreferences for Web
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('masterPassword');
      } else {
        // Use FlutterSecureStorage for mobile and desktop platforms
        return await _storage.read(key: 'masterPassword');
      }
    } catch (e) {
      print("Error reading master password: $e");
      return null;
    }
  }

  // Delete password
  void deletePassword(PasswordModel password) {
    password.delete();
  }

  // Save password in Hive
  void savePassword(String name, String username, String password) async {
    try {
      final masterPassword =
          await getMasterPassword(); // Fetch the master password

      if (masterPassword == null || masterPassword.isEmpty) {
        print("Master password is not set.");
        return;
      }

      final encryptedPassword = EncryptionUtil.encryptPassword(
        password,
        masterPassword,
      ); // Encrypt using master password
      final box = Hive.box<PasswordModel>('passwordBox');

      final model = PasswordModel(
        name: name,
        username: username,
        password: encryptedPassword,
      );

      box.add(model); // Save encrypted password
      print("Password saved: $model"); // Debug print
    } catch (e) {
      print("Error saving password: $e");
    }
  }

  // Get all passwords with error handling
  List<PasswordModel> getPasswords() {
    try {
      final box = Hive.box<PasswordModel>('passwordBox');
      return box.values.toList();
    } catch (e) {
      print("Error reading passwords: $e");
      return [];
    }
  }

  // Get decrypted passwords
  // Get decrypted passwords (with master password)
  Future<List<Map<String, String>>> getDecryptedPasswords() async {
    final box = Hive.box<PasswordModel>('passwordBox');
    List<Map<String, String>> decryptedPasswords = [];

    final masterPassword = await getMasterPassword(); // Get the master password

    if (masterPassword == null || masterPassword.isEmpty) {
      print("Master password is not set.");
      return decryptedPasswords;
    }

    for (var password in box.values) {
      final decryptedPassword = EncryptionUtil.decryptPassword(
        password.password,
        masterPassword,
      ); // Decrypt using master password
      decryptedPasswords.add({
        'name': password.name,
        'username': password.username,
        'password': decryptedPassword, // Decrypted password
      });
    }

    return decryptedPasswords;
  }

  // Update existing password in Hive
  void updatePassword(
    PasswordModel password,
    String newName,
    String newUsername,
    String newPassword,
  ) async {
    try {
      final masterPassword =
          await getMasterPassword(); // Get the master password

      if (masterPassword == null || masterPassword.isEmpty) {
        print("Master password is not set.");
        return;
      }

      final encryptedPassword = EncryptionUtil.encryptPassword(
        newPassword,
        masterPassword,
      ); // Encrypt with master password

      // Update the password fields
      password.name = newName;
      password.username = newUsername;
      password.password = encryptedPassword;

      password.save(); // This saves the updated fields back to Hive
      print("Password updated: $password"); // Debug print
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  // Save master password securely
  // Future<void> saveMasterPassword(String password) async {
  //   try {
  //     await _storage.write(key: 'masterPassword', value: password);
  //     print("Master password saved"); // Debug print
  //   /} catch (e) {
  //     print("Error saving master password: $e");
  //   /}
  // /}

  // Retrieve master password
  // Future<String?> getMasterPassword() async {
  //   try {
  //     return await _storage.read(key: 'masterPassword');
  //   /} catch (e) {
  //     print("Error reading master password: $e");
  //     return null;
  //   }
  // }
}
