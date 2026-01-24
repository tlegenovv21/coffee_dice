// lib/screens/grinder_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grinder.dart'; // Ensure this matches your folder structure

class GrinderPage extends StatefulWidget {
  const GrinderPage({super.key});

  @override
  State<GrinderPage> createState() => _GrinderPageState();
}

class _GrinderPageState extends State<GrinderPage> {
  List<Grinder> myGrinders = [];
  String? selectedGrinderId;

  // Controllers for the "Add Grinder" form
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

  // --- 1. SAVING & LOADING LOGIC (The Missing Link) ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert list of objects to list of JSON strings
    List<String> jsonList = myGrinders
        .map((g) => jsonEncode(g.toJson()))
        .toList();
    await prefs.setStringList('saved_grinders', jsonList);

    if (selectedGrinderId != null) {
      await prefs.setString('selected_grinder_id', selectedGrinderId!);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? jsonList = prefs.getStringList('saved_grinders');

    if (jsonList == null || jsonList.isEmpty) {
      // --- ADD DEFAULTS IF LIST IS EMPTY ---
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
      _saveData(); // Save them immediately
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

  // --- 2. ADD NEW GRINDER FORM ---
  void _showAddGrinderDialog() {
    // Reset form
    _brandController.clear();
    _modelController.clear();
    _minController.text = "0";
    _maxController.text = "40";
    _selectedType = GrinderType.conicalBurr;
    _selectedAdj = AdjustmentType.stepped;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Needed to update dropdowns inside dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add New Grinder"),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: "Brand (e.g. Baratza)",
                    ),
                  ),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: "Model (e.g. Encore)",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<GrinderType>(
                          value: _selectedType,
                          isExpanded: true,
                          items: GrinderType.values
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setStateDialog(() => _selectedType = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<AdjustmentType>(
                          value: _selectedAdj,
                          isExpanded: true,
                          items: AdjustmentType.values
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setStateDialog(() => _selectedAdj = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Min Setting",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Max Setting",
                          ),
                        ),
                      ),
                    ],
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
                    if (_brandController.text.isEmpty ||
                        _modelController.text.isEmpty)
                      return;

                    final newGrinder = Grinder(
                      id: DateTime.now().millisecondsSinceEpoch
                          .toString(), // Unique ID
                      brand: _brandController.text,
                      model: _modelController.text,
                      type: _selectedType,
                      adjustmentType: _selectedAdj,
                      minRange: double.tryParse(_minController.text) ?? 0,
                      maxRange: double.tryParse(_maxController.text) ?? 40,
                    );

                    setState(() {
                      myGrinders.add(newGrinder);
                      selectedGrinderId ??=
                          newGrinder.id; // Auto-select if first one
                    });

                    _saveData(); // <--- CRITICAL SAVE CALL
                    Navigator.pop(context);
                  },
                  child: const Text("Save Grinder"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteGrinder(String id) {
    setState(() {
      myGrinders.removeWhere((g) => g.id == id);
      if (selectedGrinderId == id) selectedGrinderId = null;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Grinder Inventory")),
      body: myGrinders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.coffee_maker, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("No grinders added yet."),
                  TextButton(
                    onPressed: _showAddGrinderDialog,
                    child: const Text("Add Your First Grinder"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: myGrinders.length,
              itemBuilder: (context, index) {
                final grinder = myGrinders[index];
                final isSelected = grinder.id == selectedGrinderId;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: isSelected
                      ? const Color(0xFFEFEBE9)
                      : null, // Highlight selected
                  child: ListTile(
                    leading: Icon(
                      grinder.type == GrinderType.blade
                          ? Icons.api
                          : Icons.settings, // Simple icon logic
                      color: isSelected ? const Color(0xFF3E2723) : Colors.grey,
                    ),
                    title: Text(
                      "${grinder.brand} ${grinder.model}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${grinder.type.name} • ${grinder.adjustmentType.name}",
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF3E2723),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteGrinder(grinder.id),
                          ),
                    onTap: () {
                      setState(() => selectedGrinderId = grinder.id);
                      _saveData();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGrinderDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Grinder"),
        backgroundColor: const Color(0xFF3E2723),
      ),
    );
  }
}
