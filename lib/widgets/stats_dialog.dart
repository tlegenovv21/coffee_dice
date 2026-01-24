// lib/widgets/stats_dialog.dart
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class StatsDialog extends StatelessWidget {
  final List<Recipe> recipes;

  const StatsDialog({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return AlertDialog(
        title: const Text("My Coffee Stats"),
        content: const Text("Log your first brew to see stats!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    }

    // Logic: Count methods
    var counts = <String, int>{};
    for (var r in recipes) {
      counts[r.method] = (counts[r.method] ?? 0) + 1;
    }
    // Sort to find winner
    var winner = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AlertDialog(
      title: const Text("My Coffee Stats"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.analytics, color: Color(0xFF3E2723)),
            title: const Text("Total Brews"),
            trailing: Text(
              "${recipes.length}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(),
          if (winner.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text("Favorite Method"),
              subtitle: Text(winner.first.key),
              trailing: Text("${winner.first.value}x"),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(color: Color(0xFF3E2723)),
          ),
        ),
      ],
    );
  }
}
