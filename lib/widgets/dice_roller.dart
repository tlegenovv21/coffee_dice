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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            method.toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(height: 1.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$ratio  •  $wildcard',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8D6E63),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 60,
            width: 200,
            child: ElevatedButton(
              onPressed: onRoll,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2723),
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino_outlined),
                  SizedBox(width: 10),
                  Text(
                    "ROLL DICE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
