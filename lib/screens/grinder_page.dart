// lib/screens/grinder_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grinder.dart';
import '../services/sound_manager.dart';

class GrinderPage extends StatefulWidget {
  const GrinderPage({super.key});

  @override
  State<GrinderPage> createState() => _GrinderPageState();
}

class _GrinderPageState extends State<GrinderPage> {
  List<Grinder> myGrinders = [];
  String? selectedGrinderId;

  // Controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _minController = TextEditingController(text: "0");
  final _maxController = TextEditingController(text: "40");
  GrinderType _selectedType = GrinderType.conicalBurr;
  AdjustmentType _selectedAdj = AdjustmentType.stepped;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = myGrinders
        .map((g) => jsonEncode(g.toJson()))
        .toList();
    await prefs.setStringList('saved_grinders', jsonList);

    if (selectedGrinderId != null) {
      await prefs.setString('selected_grinder_id', selectedGrinderId!);
    } else {
      await prefs.remove('selected_grinder_id');
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('saved_grinders');

    if (jsonList == null || jsonList.isEmpty) {
      List<Grinder> defaults = [
        Grinder(
          id: "def1",
          brand: "Baratza",
          model: "Encore",
          type: GrinderType.conicalBurr,
          adjustmentType: AdjustmentType.stepped,
          minRange: 0,
          maxRange: 40,
        ),
        Grinder(
          id: "def2",
          brand: "Timemore",
          model: "C2/C3",
          type: GrinderType.conicalBurr,
          adjustmentType: AdjustmentType.stepped,
          minRange: 0,
          maxRange: 36,
        ),
        Grinder(
          id: "def3",
          brand: "Comandante",
          model: "C40",
          type: GrinderType.conicalBurr,
          adjustmentType: AdjustmentType.stepped,
          minRange: 0,
          maxRange: 45,
        ),
        Grinder(
          id: "def4",
          brand: "Fellow",
          model: "Ode",
          type: GrinderType.flatBurr,
          adjustmentType: AdjustmentType.stepped,
          minRange: 1,
          maxRange: 11,
        ),
      ];
      myGrinders = defaults;
      _saveData();
    } else {
      setState(() {
        myGrinders = jsonList
            .map((str) => Grinder.fromJson(jsonDecode(str)))
            .toList();
      });
    }

    setState(() {
      selectedGrinderId = prefs.getString('selected_grinder_id');
    });
  }

  // --- ADD DIALOG ---
  void _showAddGrinderDialog() {
    SoundManager().play('click.ogg'); // Still OGG

    _brandController.clear();
    _modelController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add New Grinder"),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 10),
                    DropdownButton<GrinderType>(
                      value: _selectedType,
                      isExpanded: true,
                      items: GrinderType.values
                          .map(
                            (t) =>
                                DropdownMenuItem(value: t, child: Text(t.name)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setStateDialog(() => _selectedType = val!),
                    ),
                    DropdownButton<AdjustmentType>(
                      value: _selectedAdj,
                      isExpanded: true,
                      items: AdjustmentType.values
                          .map(
                            (t) =>
                                DropdownMenuItem(value: t, child: Text(t.name)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setStateDialog(() => _selectedAdj = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_brandController.text.isEmpty) return;

                    // 🔊 SOUND: Success (Now MP3)
                    SoundManager().play('success.mp3');

                    final newGrinder = Grinder(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      brand: _brandController.text,
                      model: _modelController.text,
                      type: _selectedType,
                      adjustmentType: _selectedAdj,
                      minRange: 0,
                      maxRange: 40,
                    );
                    setState(() {
                      myGrinders.add(newGrinder);
                      selectedGrinderId = newGrinder.id;
                    });
                    _saveData();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteGrinder(String id) {
    SoundManager().play('click.ogg');
    setState(() {
      myGrinders.removeWhere((g) => g.id == id);
      if (selectedGrinderId == id) selectedGrinderId = null;
    });
    _saveData();
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Grinder Inventory")),
      body: myGrinders.isEmpty
          ? const Center(child: Text("No grinders added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myGrinders.length,
              itemBuilder: (context, index) {
                final grinder = myGrinders[index];
                final isSelected = grinder.id == selectedGrinderId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: theme.cardColor,
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: isSelected ? const Color(0xFF3E2723) : Colors.grey,
                    ),
                    title: Text(
                      "${grinder.brand} ${grinder.model}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      "${grinder.type.name} • ${grinder.adjustmentType.name}",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF3E2723),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            onPressed: () => _deleteGrinder(grinder.id),
                          ),
                    onTap: () {
                      SoundManager().play('click.ogg');
                      setState(() {
                        if (selectedGrinderId == grinder.id) {
                          selectedGrinderId = null;
                        } else {
                          selectedGrinderId = grinder.id;
                        }
                      });
                      _saveData();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGrinderDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Grinder", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3E2723),
      ),
    );
  }
}
