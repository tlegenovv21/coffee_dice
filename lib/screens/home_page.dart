// lib/screens/home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// --- IMPORTS FOR OUR NEW WIDGETS ---
import '../models/recipe.dart';
import '../widgets/side_menu.dart';
import '../widgets/dice_roller.dart';
import '../widgets/recipe_details.dart';
import '../widgets/add_recipe_sheet.dart';
import 'grinder_page.dart';

class HomePage extends StatefulWidget {
  final bool isLightMode;
  final VoidCallback onToggle;

  const HomePage({
    super.key,
    required this.isLightMode,
    required this.onToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- USER DATA ---
  final user = FirebaseAuth.instance.currentUser;
  String nickname = "Coffee Lover";
  String age = "";
  String pronouns = "";
  String bio = "";
  String avatarUrl = "";
  bool useCelsius = true;
  String activeGrinderName = "Generic"; // <--- Holds the name for Side Menu

  // --- RECIPE DATA ---
  List<Recipe> myRecipes = [];

  // --- DICE LOGIC ---
  final List<String> brewingMethods = [
    "V60 Pour Over",
    "French Press",
    "Aeropress",
    "Chemex",
    "Moka Pot",
    "Espresso",
    "Cold Brew",
  ];
  final List<String> coffeeRatios = ["1:15", "1:16", "1:17", "1:12", "1:10"];
  final List<String> wildcards = [
    "Use cooler water",
    "Stir twice",
    "Grind finer",
    "Pour slowly",
    "Trust your instincts",
  ];

  String currentMethod = "V60 Pour Over";
  String currentRatio = "1:15";
  String currentWildcard = "Trust your instincts";

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRecipes();
  }

  // --- 1. LOADING DATA (Includes Grinder Name Logic) ---
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('user_nickname') ?? "Coffee Lover";
      age = prefs.getString('user_age') ?? "";
      pronouns = prefs.getString('user_pronouns') ?? "";
      bio = prefs.getString('user_bio') ?? "";
      avatarUrl = prefs.getString('user_avatar') ?? "";
      useCelsius = prefs.getBool('pref_celsius') ?? true;
    });

    // --- LOAD ACTIVE GRINDER NAME ---
    String? selectedId = prefs.getString('selected_grinder_id');
    List<String>? jsonList = prefs.getStringList('saved_grinders');

    if (selectedId != null && jsonList != null) {
      try {
        // Find the grinder that matches the saved ID
        final grinderJson = jsonList.firstWhere(
          (str) => jsonDecode(str)['id'] == selectedId,
          orElse: () => "",
        );

        if (grinderJson.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(grinderJson);
          setState(() {
            activeGrinderName = "${data['brand']} ${data['model']}";
          });
        }
      } catch (e) {
        print("Error loading grinder name: $e");
      }
    }
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('my_recipes')) return;

    final String? recipesJson = prefs.getString('my_recipes');
    if (recipesJson != null) {
      List<dynamic> decodedList = jsonDecode(recipesJson);
      setState(() {
        myRecipes = decodedList.map((item) => Recipe.fromJson(item)).toList();
      });
    }
  }

  // --- 2. SAVING DATA ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedList = jsonEncode(myRecipes.map((e) => e.toJson()).toList());
    await prefs.setString('my_recipes', encodedList);
  }

  Future<void> _saveProfile(
    String name,
    String userAge,
    String userPronouns,
    String userBio,
    String url,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nickname', name);
    await prefs.setString('user_age', userAge);
    await prefs.setString('user_pronouns', userPronouns);
    await prefs.setString('user_bio', userBio);
    await prefs.setString('user_avatar', url);
    setState(() {
      nickname = name;
      age = userAge;
      pronouns = userPronouns;
      bio = userBio;
      avatarUrl = url;
    });
  }

  // --- 3. ACTIONS ---
  void rollDice() {
    setState(() {
      currentMethod = brewingMethods[Random().nextInt(brewingMethods.length)];
      currentRatio = coffeeRatios[Random().nextInt(coffeeRatios.length)];
      currentWildcard = wildcards[Random().nextInt(wildcards.length)];
    });
  }

  Future<void> _handleSaveRecipe(Recipe newRecipe) async {
    setState(() {
      myRecipes.add(newRecipe);
    });
    await _saveData(); // Save to phone

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe Saved! ☕'),
          backgroundColor: Color(0xFF3E2723),
        ),
      );
    }
  }

  Future<void> _deleteRecipe(int index) async {
    setState(() {
      myRecipes.removeAt(index);
    });
    await _saveData();
    if (mounted) {
      Navigator.pop(context); // Close details dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry Deleted')));
    }
  }

  // --- 4. NAVIGATION & DIALOGS ---
  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddRecipeSheet(onSave: _handleSaveRecipe),
    );
  }

  void _openGrinderSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GrinderPage()),
    ).then((_) {
      // Reload profile when returning to update the Side Menu name
      _loadProfile();
    });
  }

  void _showStats() {
    // Basic stats logic
    if (myRecipes.isEmpty) return;
    var counts = <String, int>{};
    for (var r in myRecipes) {
      counts[r.method] = (counts[r.method] ?? 0) + 1;
    }
    var winner = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("My Coffee Stats"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Total Brews"),
              trailing: Text("${myRecipes.length}"),
            ),
            ListTile(
              title: const Text("Favorite Method"),
              subtitle: Text(winner.first.key),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showProfileSettings() {
    final nameController = TextEditingController(text: nickname);
    final ageController = TextEditingController(text: age);
    final pronounsController = TextEditingController(text: pronouns);
    final bioController = TextEditingController(text: bio);
    final urlController = TextEditingController(text: avatarUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nickname"),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              TextField(
                controller: pronounsController,
                decoration: const InputDecoration(labelText: "Pronouns"),
              ),
              TextField(
                controller: bioController,
                maxLength: 30,
                decoration: const InputDecoration(labelText: "Bio"),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: "Avatar URL"),
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
                _saveProfile(
                  nameController.text,
                  ageController.text,
                  pronounsController.text,
                  bioController.text,
                  urlController.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // --- 5. MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // SIDE MENU
      drawer: SideMenu(
        nickname: nickname,
        email: user?.email ?? "Guest",
        avatarUrl: avatarUrl,
        bio: bio,
        pronouns: pronouns,
        isLightMode: widget.isLightMode,
        currentGrinderName: activeGrinderName, // <--- PASSING THE NAME!
        onToggleTheme: widget.onToggle,
        onEditProfile: _showProfileSettings,
        onShowStats: _showStats,
        onShowGrinder: _openGrinderSettings,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "COFFEE DICE",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.iconTheme.color),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TOP: Dice Roller
            DiceRoller(
              method: currentMethod,
              ratio: currentRatio,
              wildcard: currentWildcard,
              onRoll: rollDice,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Divider(),
            ),

            // HEADER: My Journal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "MY JOURNAL",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "${myRecipes.length} Entries",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),

            // LIST: Recipes
            Expanded(
              child: myRecipes.isEmpty
                  ? Center(
                      child: Text(
                        "Roll the dice & log your first brew!",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: myRecipes.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = myRecipes.length - 1 - index;
                        final recipe = myRecipes[reversedIndex];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => RecipeDetailsDialog(
                                  recipe: recipe,
                                  index: reversedIndex,
                                  onDelete: _deleteRecipe,
                                  useCelsius: useCelsius,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF3E2723,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.coffee,
                                      color: Color(0xFF3E2723),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.method,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                        Text(
                                          // Display Origin + Dose if available, otherwise Grind
                                          "${recipe.beanOrigin.isNotEmpty ? recipe.beanOrigin : 'Unknown Bean'} • ${recipe.doseWeight > 0 ? '${recipe.doseWeight}g' : recipe.grindSetting}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet, // Opens our new form
        backgroundColor: const Color(0xFF3E2723),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Log Brew",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
