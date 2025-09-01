import 'package:flutter/material.dart';
import '../controllers/password_controller.dart';
import '../models/password_model.dart';

class EditPasswordScreen extends StatefulWidget {
  final PasswordModel password;

  const EditPasswordScreen({super.key, required this.password});

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final PasswordController _controller = PasswordController();

  @override
  void initState() {
    super.initState();
    // Set the initial values to the fields
    _nameController.text = widget.password.name;
    _usernameController.text = widget.password.username;
    _passwordController.text = widget.password.password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the password in Hive
                _controller.updatePassword(
                  widget.password, // Pass the current password
                  _nameController.text,
                  _usernameController.text,
                  _passwordController.text,
                );
                Navigator.pop(context); // Return to the HomeScreen
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
