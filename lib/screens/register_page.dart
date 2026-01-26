// lib/screens/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Sign Up Method
  Future<void> signUp() async {
    // 1. Loading Circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3E2723)),
      ),
    );

    // 2. Check if passwords match
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      Navigator.pop(context); // Close loading
      _showError("Passwords do not match!");
      return;
    }

    // 3. Try Creating User
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If successful, the StreamBuilder in main.dart will auto-switch to HomePage
      if (mounted) Navigator.pop(context); // Close loading
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      _showError(e.message ?? "An error occurred");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF3E2723))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    const coffeeColor = Color(0xFF3E2723);
    const creamColor = Color(0xFFF5F0E6);

    return Scaffold(
      backgroundColor: creamColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.coffee_maker, size: 80, color: coffeeColor),
                const SizedBox(height: 25),

                const Text(
                  "Join the Brew Crew",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: coffeeColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Register to track your coffee journey",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email
                _buildTextField(_emailController, "Email", false),
                const SizedBox(height: 10),

                // Password
                _buildTextField(_passwordController, "Password", true),
                const SizedBox(height: 10),

                // Confirm Password
                _buildTextField(
                  _confirmPasswordController,
                  "Confirm Password",
                  true,
                ),
                const SizedBox(height: 20),

                // Sign Up Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: coffeeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Toggle to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already a member? ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
          ),
        ),
      ),
    );
  }
}
