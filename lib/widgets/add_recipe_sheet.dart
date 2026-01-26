// lib/widgets/add_recipe_sheet.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe.dart';

class AddRecipeSheet extends StatefulWidget {
  final Function(Recipe) onSave;

  const AddRecipeSheet({super.key, required this.onSave});

  @override
  State<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<AddRecipeSheet> {
  // Controllers
  final _methodController = TextEditingController();
  final _beanController = TextEditingController();
  final _roastController = TextEditingController();
  final _grindController = TextEditingController();
  final _doseController = TextEditingController();
  final _waterWeightController = TextEditingController();
  final _waterTempController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  String? selectedGrinderId;
  String activeGrinderLabel = "None";

  @override
  void initState() {
    super.initState();
    _loadActiveGrinder();
  }

  Future<void> _loadActiveGrinder() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('selected_grinder_id');
    List<String>? jsonList = prefs.getStringList('saved_grinders');

    if (id != null && jsonList != null) {
      try {
        final grinderJson = jsonList.firstWhere(
          (str) => jsonDecode(str)['id'] == id,
          orElse: () => "",
        );
        if (grinderJson.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(grinderJson);
          setState(() {
            selectedGrinderId = id;
            activeGrinderLabel = "${data['brand']} ${data['model']}";
          });
        }
      } catch (e) {
        /* ignore */
      }
    }
  }

  void _submit() {
    if (_methodController.text.isEmpty) return;

    double parseDouble(String val) {
      if (val.isEmpty) return 0.0;
      return double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
    }

    double dose = parseDouble(_doseController.text);
    double water = parseDouble(_waterWeightController.text);
    String calcRatio = (dose > 0 && water > 0)
        ? "1:${(water / dose).toStringAsFixed(1)}"
        : "-";

    final newRecipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: _methodController.text,
      beanOrigin: _beanController.text,
      roastLevel: _roastController.text,
      grindSetting: _grindController.text,
      doseWeight: dose,
      waterWeight: water,
      waterTemp: parseDouble(_waterTempController.text),
      ratio: calcRatio,
      brewTime: _timeController.text,
      notes: _notesController.text,
      date: DateTime.now(),
      grinderId: selectedGrinderId ?? "",
    );

    widget.onSave(newRecipe);
    Navigator.pop(context);
  }

  // Helper for Clean, Old-School Inputs
  Widget _buildInput(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), // Better spacing
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          // Removed OutlineInputBorder to restore the clean "Line" look
          contentPadding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect Theme for Text Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24, // Increased padding
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Log Brew",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            _buildInput(_methodController, "Method (V60, etc)"),
            _buildInput(_beanController, "Bean Origin"),

            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    _doseController,
                    "Dose (g)",
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInput(
                    _waterWeightController,
                    "Water (g)",
                    isNumber: true,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    _waterTempController,
                    "Temp",
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(child: _buildInput(_timeController, "Time (min:sec)")),
              ],
            ),

            Row(
              children: [
                Expanded(child: _buildInput(_grindController, "Grind Setting")),
                const SizedBox(width: 15),
                Expanded(child: _buildInput(_roastController, "Roast Level")),
              ],
            ),

            _buildInput(_notesController, "Notes"),

            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  "Using Grinder: $activeGrinderLabel",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white
                      : const Color(0xFF3E2723), // Adaptive Button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save Entry",
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
