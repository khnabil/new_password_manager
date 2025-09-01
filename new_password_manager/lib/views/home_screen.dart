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
  late Box<PasswordModel> passwordBox; // Declare the password box variable
  bool isBoxReady = false; // Flag to check if the box is ready

  @override
  void initState() {
    super.initState();
    _setupHiveBox(); // Ensure the Hive box is initialized when the widget is created
  }

  // Open the Hive box and handle any errors
  void _setupHiveBox() async {
    try {
      // Open the Hive box for PasswordModel
      passwordBox = await Hive.openBox<PasswordModel>('passwordBox');
      print("Hive box opened successfully!");

      // Set the state to reflect that the box is ready
      setState(() {
        isBoxReady = true; // Now the box is ready
      });
    } catch (e) {
      print("Error opening Hive box: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the box is not ready, show a loading indicator
    if (!isBoxReady) {
      return Center(child: CircularProgressIndicator());
    }

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
                  _controller,
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: passwordBox.listenable(),
        builder: (context, Box<PasswordModel> box, _) {
          // Filter passwords based on the search query, but show all if query is empty
          final filteredPasswords = _searchQuery.isEmpty
              ? passwordBox.values.toList()
              : passwordBox.values.where((password) {
                  return password.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      password.username.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                }).toList();

          // If no passwords exist, show a message
          if (filteredPasswords.isEmpty) {
            return Center(child: Text("No passwords saved yet!"));
          }

          return ListView.builder(
            itemCount: filteredPasswords.length,
            itemBuilder: (context, index) {
              final password = filteredPasswords[index];

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
                          _copyPasswordToClipboard(password.password);
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
  void _copyPasswordToClipboard(String encryptedPassword) async {
    final masterPassword = await _controller.getMasterPassword();

    // Check if the master password is null
    if (masterPassword == null || masterPassword.isEmpty) {
      // If the master password is null or empty, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Master password is not set or is invalid')),
      );
      return; // Exit the method
    }

    // Proceed with decryption if the master password is valid
    final decryptedPassword = EncryptionUtil.decryptPassword(
      encryptedPassword,
      masterPassword,
    );

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
  final PasswordController _controller; // Add _controller to the class

  PasswordSearchDelegate(
    this.passwordBox,
    this.initialSearchQuery,
    this.onSearchQueryChanged,
    this._controller, // Accept _controller in the constructor
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
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  // Build the search results using FutureBuilder to get the master password
  Widget _buildSearchResults(BuildContext context) {
    final results = passwordBox.values.where((password) {
      return password.name.toLowerCase().contains(query.toLowerCase()) ||
          password.username.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(child: Text("No results found"));
    }

    return FutureBuilder<String?>(
      future: _getMasterPassword(), // Use _controller here
      builder: (context, snapshot) {
        // While waiting for the master password
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // If there was an error fetching the master password
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching master password"));
        }

        // If no master password is found
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Master password not set"));
        }

        final masterPassword = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final password = results[index];
            final decryptedPassword = EncryptionUtil.decryptPassword(
              password.password,
              masterPassword,
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
      },
    );
  }

  Future<String?> _getMasterPassword() async {
    // This method fetches the master password asynchronously
    return await _controller.getMasterPassword();
  }
}
