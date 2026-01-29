// lib/widgets/stats_dialog.dart
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class StatsDialog extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(String) onQuickAdd;
  final Function(String) onQuickRemove;

  const StatsDialog({
    super.key,
    required this.recipes,
    required this.onQuickAdd,
    required this.onQuickRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF3E2723);

    // 1. Calculate Stats
    var counts = <String, int>{};
    for (var r in recipes) {
      counts[r.method] = (counts[r.method] ?? 0) + 1;
    }

    // Sort by count (Highest first)
    var sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return AlertDialog(
      // Use a deep brown for Dark Mode, Cream for Light Mode
      backgroundColor: isDark
          ? const Color(0xFF2D1E1B)
          : const Color(0xFFFFF8E1),
      title: Row(
        children: [
          Icon(Icons.analytics, color: iconColor),
          const SizedBox(width: 10),
          Text("Coffee Stats", style: TextStyle(color: textColor)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- RESTORED TOTAL BREWS ---
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Total Brews",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                "${recipes.length}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
            ),
            const Divider(),

            // ---------------------------
            Expanded(
              child: sortedKeys.isEmpty
                  ? Center(
                      child: Text(
                        "Log a brew to see stats!",
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        String method = sortedKeys[index];
                        int count = counts[method]!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Method Name
                              Expanded(
                                child: Text(
                                  method,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),

                              // Minus Button
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red[300],
                                ),
                                onPressed: () => onQuickRemove(method),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),

                              // Count Text
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Text(
                                  "$count",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                              ),

                              // Plus Button
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () => onQuickAdd(method),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF3E2723),
            ),
          ),
        ),
      ],
    );
  }
}
