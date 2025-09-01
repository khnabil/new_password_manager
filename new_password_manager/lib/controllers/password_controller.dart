import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_model.dart';
import '../utils/encryption.dart';

class PasswordController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Delete password
  void deletePassword(PasswordModel password) {
    password.delete();
  }

  // Save password in Hive
  void savePassword(String name, String username, String password) {
    try {
      final encryptedPassword = EncryptionUtil.encryptPassword(password);
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

  // Get all passwords
  List<PasswordModel> getPasswords() {
    final box = Hive.box<PasswordModel>('passwordBox');
    return box.values.toList();
  }

  // Get decrypted passwords
  List<Map<String, String>> getDecryptedPasswords() {
    final box = Hive.box<PasswordModel>('passwordBox');
    List<Map<String, String>> decryptedPasswords = [];

    for (var password in box.values) {
      final decryptedPassword = EncryptionUtil.decryptPassword(
        password.password,
      );
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
  ) {
    try {
      final encryptedPassword = EncryptionUtil.encryptPassword(newPassword);

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
  Future<void> saveMasterPassword(String password) async {
    try {
      await _storage.write(key: 'masterPassword', value: password);
      print("Master password saved"); // Debug print
    } catch (e) {
      print("Error saving master password: $e");
    }
  }

  // Retrieve master password
  Future<String?> getMasterPassword() async {
    try {
      return await _storage.read(key: 'masterPassword');
    } catch (e) {
      print("Error reading master password: $e");
      return null;
    }
  }
}
