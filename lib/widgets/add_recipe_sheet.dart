import 'package:flutter/material.dart';
import '../models/recipe.dart';

class AddRecipeSheet extends StatefulWidget {
  final Function(Recipe) onSave;

  const AddRecipeSheet({super.key, required this.onSave});

  @override
  State<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<AddRecipeSheet> {
  // Controllers moved HERE (so they don't clutter HomePage)
  final _methodController = TextEditingController();
  final _ratioController = TextEditingController();
  final _tempController = TextEditingController();
  final _timeController = TextEditingController();
  final _bloomController = TextEditingController();
  final _grindController = TextEditingController();
  final _beanController = TextEditingController();
  final _notesController = TextEditingController();

  void _submit() {
    if (_methodController.text.isEmpty) return;

    final newRecipe = Recipe(
      method: _methodController.text,
      ratio: _ratioController.text,
      waterTemp: _tempController.text,
      brewTime: _timeController.text,
      bloom: _bloomController.text,
      beanOrigin: _beanController.text,
      rating: _notesController.text,
      grindSetting: _grindController.text,
      doseWeight: 0.0,
    );

    widget.onSave(newRecipe); // Send data back to Home
    Navigator.pop(context); // Close the sheet
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 25,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Journal Entry',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _methodController,
              decoration: const InputDecoration(
                labelText: 'Method (Required)*',
                hintText: "V60",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ratioController,
              decoration: const InputDecoration(
                labelText: 'Ratio',
                hintText: "1:15",
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DETAILS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempController,
                    decoration: const InputDecoration(
                      labelText: 'Temp',
                      hintText: "93°C",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: "3:00",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bloomController,
                    decoration: const InputDecoration(
                      labelText: 'Bloom',
                      hintText: "45g",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _grindController,
                    decoration: const InputDecoration(
                      labelText: 'Grind Setting',
                      hintText: "Medium / 14",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'THE BEANS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _beanController,
              decoration: const InputDecoration(
                labelText: 'Origin / Name',
                hintText: "e.g. Ethiopia",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Tasting Notes',
                hintText: "Fruity...",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SAVE ENTRY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
