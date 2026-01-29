// lib/widgets/recipe_details.dart
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/timer_page.dart';

class RecipeDetailsDialog extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final Function(int) onDelete;
  final bool useCelsius;

  const RecipeDetailsDialog({
    super.key,
    required this.recipe,
    required this.index,
    required this.onDelete,
    required this.useCelsius,
  });

  String _displayTemp(double tempC) {
    if (useCelsius) {
      return "${tempC.toStringAsFixed(0)}°C";
    } else {
      double tempF = (tempC * 9 / 5) + 32;
      return "${tempF.toStringAsFixed(0)}°F";
    }
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    if (value.isEmpty || value == "0" || value == "0.0")
      return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(recipe.date);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.method,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Bean", recipe.beanOrigin, theme),
            _detailRow("Roast", recipe.roastLevel, theme),
            _detailRow(
              "Grinder",
              recipe.grinderId.isNotEmpty ? "Linked" : "None",
              theme,
            ),
            _detailRow("Setting", recipe.grindSetting, theme),
            const Divider(),
            _detailRow("Dose", "${recipe.doseWeight}g", theme),
            _detailRow("Water", "${recipe.waterWeight}g", theme),
            _detailRow("Ratio", recipe.ratio, theme),
            _detailRow("Temp", _displayTemp(recipe.waterTemp), theme),
            _detailRow("Time", recipe.brewTime, theme),
            const Divider(),
            const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              recipe.notes.isEmpty ? "No notes." : recipe.notes,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        // --- NEW: START BREW BUTTON ---
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context); // Close the popup
            Navigator.push(
              context,
              MaterialPageRoute(
                // Use the recipe data to set the timer automatically
                builder: (context) => TimerPage(recipe: recipe),
              ),
            );
          },
          icon: const Icon(Icons.timer, size: 20),
          label: const Text("Start Brew"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E2723), // Coffee Brown
            foregroundColor: Colors.white,
          ),
        ),
        // --- SHARE BUTTON (TEXT ONLY) ---
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context); // Close dialog

            // Simple Share Text
            String shareText =
                """
☕ My Brew: ${recipe.method}
---------------------------
🫘 Bean: ${recipe.beanOrigin}
⚖️ Dose: ${recipe.doseWeight}g
💧 Water: ${recipe.waterWeight}g
⏱️ Time: ${recipe.brewTime}

📝 Notes: ${recipe.notes}

Shared via Coffee Dice App
""";
            Share.share(shareText);
          },
          icon: const Icon(Icons.share, size: 20),
          label: const Text("Share"),
          style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
        ),

        // --------------------------------
        TextButton(
          onPressed: () {
            onDelete(index);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Delete"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E2723),
          ),
          child: const Text("Close", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
