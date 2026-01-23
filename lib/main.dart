// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'theme/app_theme.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart'; // Import the new Login Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // <--- START FIREBASE
  runApp(const CoffeeDiceApp());
}

class CoffeeDiceApp extends StatefulWidget {
  const CoffeeDiceApp({super.key});

  @override
  State<CoffeeDiceApp> createState() => _CoffeeDiceAppState();
}

class _CoffeeDiceAppState extends State<CoffeeDiceApp> {
  bool isLightMode = true;

  void toggleTheme() {
    setState(() {
      isLightMode = !isLightMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Dice',
      themeMode: isLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // --- THE GATEKEEPER ---
      // This listens to Firebase. If user logs in/out, it switches screens automatically.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // User IS logged in -> Show Home Page
            return HomePage(isLightMode: isLightMode, onToggle: toggleTheme);
          } else {
            // User is NOT logged in -> Show Login Page
            return LoginPage(toggleTheme: toggleTheme);
          }
        },
      ),
    );
  }
}
