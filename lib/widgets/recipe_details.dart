// lib/widgets/recipe_details.dart
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../screens/timer_page.dart';

class RecipeDetailsDialog extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final Function(int) onDelete;
  final bool useCelsius; // Passed from Home Page

  const RecipeDetailsDialog({
    super.key,
    required this.recipe,
    required this.index,
    required this.onDelete,
    required this.useCelsius,
  });

  // Helper to convert temp if needed
  String _displayTemp(String rawTemp) {
    if (rawTemp.isEmpty) return "-";
    String numbersOnly = rawTemp.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbersOnly.isEmpty) return rawTemp;
    int c = int.tryParse(numbersOnly) ?? 0;
    if (useCelsius) return "$c°C";
    int f = ((c * 9 / 5) + 32).round();
    return "$f°F";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.coffee, color: theme.iconTheme.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(recipe.method, style: theme.textTheme.titleLarge),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow("Ratio", recipe.ratio, theme),
            const Divider(),
            Text(
              "DETAILS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),

            _detailRow(
              "Temp",
              _displayTemp(recipe.waterTemp),
              theme,
            ), // Fixed Display Logic
            _detailRow("Time", recipe.brewTime, theme),
            _detailRow("Bloom", recipe.bloom, theme),
            _detailRow(
              "Grind",
              recipe.grindSetting,
              theme,
            ), // <--- FIXED: uses grindSetting

            const SizedBox(height: 15),
            Text(
              "THE BEANS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            _detailRow("Origin", recipe.beanOrigin, theme),

            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recipe.rating.isEmpty ? "No notes." : recipe.rating,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (recipe.brewTime.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerPage(recipe: recipe),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text("OPEN TIMER"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => onDelete(index),
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
