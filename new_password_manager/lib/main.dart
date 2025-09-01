import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/password_model.dart';
import 'views/home_screen.dart';
import 'views/MasterPasswordScreen.dart';
import 'controllers/password_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapter for PasswordModel
  Hive.registerAdapter(PasswordModelAdapter());

  // Open the passwordBox (make sure it opens correctly)
  await Hive.openBox<PasswordModel>('passwordBox');

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _initialScreen;
  final PasswordController _controller = PasswordController();

  @override
  void initState() {
    super.initState();
    _setupInitialScreen();
  }

  Future<void> _setupInitialScreen() async {
    try {
      // Retrieve master password (check if it exists)
      final masterPassword = await _controller.getMasterPassword().timeout(
        Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (masterPassword != null && masterPassword.isNotEmpty) {
        // If master password exists, show HomeScreen
        setState(() {
          _initialScreen = HomeScreen();
        });
      } else {
        // Otherwise, show MasterPasswordScreen
        setState(() {
          _initialScreen = MasterPasswordScreen();
        });
      }
    } catch (e) {
      // If there's an error during master password retrieval
      print("Error during initial screen setup: $e");
      setState(() {
        _initialScreen = MasterPasswordScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialScreen == null) {
      // Show loading while checking
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      theme: ThemeData(primarySwatch: Colors.green),
      home: _initialScreen,
    );
  }
}
