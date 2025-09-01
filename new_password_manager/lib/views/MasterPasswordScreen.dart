import 'package:flutter/material.dart';
import '../controllers/password_controller.dart';
import 'home_screen.dart';

class MasterPasswordScreen extends StatelessWidget {
  final _passwordController = TextEditingController();
  final PasswordController _controller = PasswordController();

  MasterPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Master Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Enter Master Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller.saveMasterPassword(
                  _passwordController.text,
                ); // Save the master password securely
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                ); // Navigate to Home Screen after setting master password
              },
              child: Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }
}
