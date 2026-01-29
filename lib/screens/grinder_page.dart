// lib/screens/grinder_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound_manager.dart';

class GrinderPage extends StatefulWidget {
  const GrinderPage({super.key});

  @override
  State<GrinderPage> createState() => _GrinderPageState();
}

class _GrinderPageState extends State<GrinderPage> {
  // Grinder Data
  List<Map<String, String>> grinders = [
    {
      "id": "c40",
      "brand": "Comandante",
      "model": "C40 MK4",
      "type": "conicalBurr",
      "adjust": "stepped",
    },
    {
      "id": "kinu",
      "brand": "Kinu",
      "model": "M47",
      "type": "conicalBurr",
      "adjust": "stepless",
    },
    {
      "id": "timemore",
      "brand": "Timemore",
      "model": "C2/C3",
      "type": "conicalBurr",
      "adjust": "stepped",
    },
    {
      "id": "encore",
      "brand": "Baratza",
      "model": "Encore",
      "type": "conicalBurr",
      "adjust": "stepped",
    },
    {
      "id": "ode",
      "brand": "Fellow",
      "model": "Ode",
      "type": "flatBurr",
      "adjust": "stepped",
    },
  ];

  String? selectedGrinderId;
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGrinders();
  }

  Future<void> _loadGrinders() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Custom Grinders
    List<String>? savedList = prefs.getStringList('saved_grinders');
    if (savedList != null) {
      setState(() {
        grinders = savedList
            .map((item) => Map<String, String>.from(jsonDecode(item)))
            .toList();
      });
    } else {
      // First time? Save defaults
      _saveGrinders();
    }

    // Load Selected
    setState(() {
      selectedGrinderId = prefs.getString('selected_grinder_id');
    });
  }

  Future<void> _saveGrinders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedList = grinders.map((g) => jsonEncode(g)).toList();
    await prefs.setStringList('saved_grinders', encodedList);
  }

  Future<void> _selectGrinder(String id) async {
    SoundManager().play('click.ogg');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_grinder_id', id);
    setState(() {
      selectedGrinderId = id;
    });
  }

  void _addCustomGrinder() {
    _brandController.clear();
    _modelController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Grinder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: "Brand"),
            ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: "Model"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_brandController.text.isNotEmpty &&
                  _modelController.text.isNotEmpty) {
                final newGrinder = {
                  "id": DateTime.now().millisecondsSinceEpoch.toString(),
                  "brand": _brandController.text,
                  "model": _modelController.text,
                  "type": "conicalBurr", // Default
                  "adjust": "stepped",
                };
                setState(() {
                  grinders.add(newGrinder);
                });
                _saveGrinders();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _deleteGrinder(String id) {
    setState(() {
      grinders.removeWhere((g) => g['id'] == id);
      if (selectedGrinderId == id) selectedGrinderId = null;
    });
    _saveGrinders();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Grinder Inventory",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: grinders.isEmpty
          ? const Center(child: Text("No grinders added."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grinders.length,
              itemBuilder: (context, index) {
                final g = grinders[index];
                final isSelected = g['id'] == selectedGrinderId;

                return Card(
                  color: theme.cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: isSelected
                        ? const BorderSide(color: Color(0xFF3E2723), width: 2)
                        : BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      // FIX: White in Dark Mode, Grey in Light Mode
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    title: Text(
                      g['brand'] ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      "${g['model']} • ${g['type']}",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF8D6E63), // Brown Checkmark
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            // FIX: White in Dark Mode
                            color: isDark ? Colors.white70 : Colors.grey,
                            onPressed: () => _deleteGrinder(g['id']!),
                          ),
                    onTap: () => _selectGrinder(g['id']!),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomGrinder,
        backgroundColor: const Color(0xFF3E2723),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Grinder", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
