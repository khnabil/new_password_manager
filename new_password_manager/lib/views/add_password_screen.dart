import 'package:flutter/material.dart';
import '../controllers/password_controller.dart';
import '../utils/password_generator.dart';

class AddPasswordScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final PasswordController _controller = PasswordController();

  AddPasswordScreen({super.key});
  void _generatePassword() {
    final password = PasswordGenerator.generateStrongPassword(
      length: 16,
    ); // Set desired length (e.g., 16)
    _passwordController.text = password; // Display the generated password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'URL'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            // Add a button to generate a strong password
            ElevatedButton(
              onPressed: _generatePassword,
              child: Text('Generate Strong Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller.savePassword(
                  _nameController.text,
                  _usernameController.text,
                  _passwordController.text,
                );
                Navigator.pop(context); // Go back to HomeScreen
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
