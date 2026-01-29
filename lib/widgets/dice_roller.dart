// lib/widgets/dice_roller.dart
import 'package:flutter/material.dart';

class DiceRoller extends StatelessWidget {
  final String method;
  final String ratio;
  final String wildcard;
  final VoidCallback onRoll;

  const DiceRoller({
    super.key,
    required this.method,
    required this.ratio,
    required this.wildcard,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // --- METHOD TEXT ---
        Text(
          method.toUpperCase(),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 28,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 10),

        // --- RATIO & WILDCARD (Fixed Text Color) ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                ratio,
                style: TextStyle(
                  fontSize: 16,
                  // Use Grey[400] for Dark Mode to make it readable
                  color: isDark ? Colors.grey[400] : Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                wildcard,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- ROLL BUTTON ---
        SizedBox(
          width: 200,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: onRoll,
            icon: const Icon(Icons.casino_outlined, size: 24),
            label: const Text(
              "ROLL DICE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E2723), // Always Dark Brown
              foregroundColor: const Color(0xFFD7CCC8), // Light Text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
              shadowColor: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }
}
