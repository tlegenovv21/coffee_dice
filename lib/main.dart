// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/sound_manager.dart';
import 'screens/home_page.dart';
import 'screens/auth_page.dart'; // <--- Import the Auth Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SoundManager().init();
  runApp(const CoffeeDiceApp());
}

class CoffeeDiceApp extends StatefulWidget {
  const CoffeeDiceApp({super.key});

  @override
  State<CoffeeDiceApp> createState() => _CoffeeDiceAppState();
}

class _CoffeeDiceAppState extends State<CoffeeDiceApp> {
  // Default to light mode (or load from prefs if you prefer)
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

      // --- THEME SETUP ---
      theme: isLightMode
          ? ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F0E6), // Cream
              primaryColor: const Color(0xFF3E2723), // Coffee Brown
              cardColor: const Color(0xFFFFF8E1),

              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleTextStyle: TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: Color(0xFF3E2723)),
              ),

              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Color(0xFF3E2723)),
                titleLarge: TextStyle(color: Color(0xFF3E2723)),
              ),

              iconTheme: const IconThemeData(color: Color(0xFF8D6E63)),
            )
          : ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212), // Dark Grey
              primaryColor: const Color(0xFFD7CCC8),
              cardColor: const Color(0xFF1E1E1E),

              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),

              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(color: Colors.white),
              ),

              iconTheme: const IconThemeData(color: Colors.white70),
            ),

      // --- THE GATEKEEPER ---
      // This checks if the user is logged in or out
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. User is logged in -> Show Home
          if (snapshot.hasData) {
            return HomePage(isLightMode: isLightMode, onToggle: toggleTheme);
          }
          // 2. User is logged out -> Show Auth (Login/Register)
          else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
