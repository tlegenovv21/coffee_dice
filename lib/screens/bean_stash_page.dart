// lib/screens/bean_stash_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/coffee_bean.dart';
import '../services/sound_manager.dart';

class BeanStashPage extends StatefulWidget {
  const BeanStashPage({super.key});

  @override
  State<BeanStashPage> createState() => _BeanStashPageState();
}

class _BeanStashPageState extends State<BeanStashPage> {
  List<CoffeeBean> myBeans = [];

  // Controllers
  final _nameController = TextEditingController();
  final _roasterController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadBeans();
  }

  Future<void> _loadBeans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? beansJson = prefs.getString('my_beans');
    if (beansJson != null) {
      List<dynamic> decoded = jsonDecode(beansJson);
      setState(() {
        myBeans = decoded.map((item) => CoffeeBean.fromJson(item)).toList();
        // Sort: Newest Roast Date first
        myBeans.sort((a, b) => b.roastDate.compareTo(a.roastDate));
      });
    }
  }

  Future<void> _saveBeans() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(myBeans.map((e) => e.toJson()).toList());
    await prefs.setString('my_beans', encoded);
  }

  void _addBean() {
    // Reset inputs
    _nameController.clear();
    _roasterController.clear();
    _selectedDate = DateTime.now();
    SoundManager().play('click.ogg');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add Coffee Bag"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Bean Name (e.g. Kenya AA)",
                    ),
                  ),
                  TextField(
                    controller: _roasterController,
                    decoration: const InputDecoration(
                      labelText: "Roaster (e.g. Onyx)",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Roast Date:"),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF3E2723),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setStateDialog(() => _selectedDate = picked);
                          }
                        },
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
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
                    if (_nameController.text.isEmpty) return;
                    SoundManager().play('success.mp3');

                    final newBean = CoffeeBean(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      roaster: _roasterController.text,
                      roastDate: _selectedDate,
                      notes: "",
                    );

                    setState(() {
                      myBeans.insert(0, newBean); // Add to top
                    });
                    _saveBeans();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                  ),
                  child: const Text(
                    "Add to Stash",
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

  void _deleteBean(String id) {
    SoundManager().play('click.ogg');
    setState(() => myBeans.removeWhere((b) => b.id == id));
    _saveBeans();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bean Stash",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: myBeans.isEmpty
          ? Center(
              child: Text(
                "Your stash is empty.\nAdd your first bag!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myBeans.length,
              itemBuilder: (context, index) {
                final bean = myBeans[index];
                final days = bean.daysOffRoast;

                // Freshness Logic
                Color badgeColor = Colors.green;
                String badgeText = "FRESH";
                if (days < 3) {
                  badgeColor = Colors.orange;
                  badgeText = "RESTING"; // Too fresh
                } else if (days > 45) {
                  badgeColor = Colors.grey;
                  badgeText = "OLD";
                }

                return Dismissible(
                  key: Key(bean.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red[900],
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteBean(bean.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    color: theme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Icon / Badge
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(Icons.inventory_2, color: badgeColor),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bean.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  bean.roaster.isNotEmpty
                                      ? bean.roaster
                                      : "Unknown Roaster",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Days Counter
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "$days",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: textColor,
                                ),
                              ),
                              const Text(
                                "days",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBean,
        backgroundColor: isDark ? Colors.white : const Color(0xFF3E2723),
        icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
        label: Text(
          "Add Bag",
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
