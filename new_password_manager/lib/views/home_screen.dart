import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../controllers/password_controller.dart';
import '../models/password_model.dart';
import 'add_password_screen.dart';
import 'edit_password_screen.dart';
import '../utils/encryption.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PasswordController _controller = PasswordController();
  String _searchQuery = ''; // This stores the search query

  @override
  Widget build(BuildContext context) {
    final Box<PasswordModel> passwordBox = Hive.box<PasswordModel>(
      'passwordBox',
    );

    // Filter passwords based on the search query, but show all if query is empty
    final filteredPasswords = _searchQuery.isEmpty
        ? passwordBox.values
              .toList() // Show all passwords if search query is empty
        : passwordBox.values.where((password) {
            return password.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                password.username.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList(); // Filter passwords if search query is not empty

    return Scaffold(
      appBar: AppBar(
        title: Text("Password Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PasswordSearchDelegate(
                  passwordBox,
                  _searchQuery,
                  _onSearchQueryChanged,
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: passwordBox.listenable(),
        builder: (context, Box<PasswordModel> box, _) {
          // If no passwords exist, show a message
          if (filteredPasswords.isEmpty) {
            return Center(
              child: Text(
                "No passwords saved yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredPasswords.length,
            itemBuilder: (context, index) {
              final password = filteredPasswords[index];
              final decryptedPassword = EncryptionUtil.decryptPassword(
                password.password,
              );

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(password.name),
                  subtitle: Text(password.username),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Copy password button
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.blue),
                        onPressed: () {
                          _copyPasswordToClipboard(decryptedPassword);
                        },
                      ),
                      // Edit password button
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPasswordScreen(password: password),
                            ),
                          );
                        },
                      ),
                      // Delete password button
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _controller.deletePassword(password);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPasswordScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Copy decrypted password to clipboard
  void _copyPasswordToClipboard(String decryptedPassword) {
    Clipboard.setData(ClipboardData(text: decryptedPassword));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Update search query
  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
}

// Search delegate
class PasswordSearchDelegate extends SearchDelegate {
  final Box<PasswordModel> passwordBox;
  final String initialSearchQuery;
  final Function(String) onSearchQueryChanged;

  PasswordSearchDelegate(
    this.passwordBox,
    this.initialSearchQuery,
    this.onSearchQueryChanged,
  );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchQueryChanged(query); // Reset search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search and return null
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = passwordBox.values.where((password) {
      return password.name.toLowerCase().contains(query.toLowerCase()) ||
          password.username.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = passwordBox.values.where((password) {
      return password.name.toLowerCase().contains(query.toLowerCase()) ||
          password.username.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results);
  }

  Widget _buildSearchResults(List<PasswordModel> results) {
    if (results.isEmpty) return Center(child: Text("No results found"));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final password = results[index];
        final decryptedPassword = EncryptionUtil.decryptPassword(
          password.password,
        );

        return ListTile(
          title: Text(password.name),
          subtitle: Text(password.username),
          onTap: () {
            Clipboard.setData(ClipboardData(text: decryptedPassword));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password copied to clipboard!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}
