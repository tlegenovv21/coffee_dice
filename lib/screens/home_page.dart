// lib/screens/home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// --- WIDGET IMPORTS ---
import '../models/recipe.dart';
import '../data/pro_recipes.dart';
import '../widgets/side_menu.dart';
import '../widgets/dice_roller.dart';
import '../widgets/recipe_details.dart';
import '../widgets/add_recipe_sheet.dart';
import '../widgets/stats_dialog.dart';
import '../widgets/profile_edit_dialog.dart';
import '../widgets/recipe_card.dart';
import 'grinder_page.dart';
import '../services/sound_manager.dart';

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
  // --- STATE VARIABLES ---
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String nickname = "Coffee Lover";
  String age = "";
  String pronouns = "";
  String bio = "";
  String avatarUrl = "";
  bool useCelsius = true;
  String activeGrinderName = "Generic";
  String activeGrinderId = "";
  List<Recipe> myRecipes = [];

  // --- DICE STATE ---
  Recipe? currentRolledRecipe;
  String currentMethod = "V60 Pour Over";
  String currentRatio = "1:15 (Balanced)";
  String currentWildcard = "Roll to find out!";
  bool canSaveRoll = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRecipes();
  }

  // --- DATA LOADING ---
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

    String? selectedId = prefs.getString('selected_grinder_id');
    List<String>? jsonList = prefs.getStringList('saved_grinders');
    if (selectedId != null && jsonList != null) {
      try {
        final grinderJson = jsonList.firstWhere(
          (str) => jsonDecode(str)['id'] == selectedId,
          orElse: () => "",
        );
        if (grinderJson.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(grinderJson);
          setState(() {
            activeGrinderName = "${data['brand']} ${data['model']}";
            activeGrinderId = selectedId;
          });
        }
      } catch (e) {
        /* ignore */
      }
    }
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('my_recipes')) return;
    final String? recipesJson = prefs.getString('my_recipes');
    if (recipesJson != null) {
      List<dynamic> decodedList = jsonDecode(recipesJson);
      setState(
        () => myRecipes = decodedList
            .map((item) => Recipe.fromJson(item))
            .toList(),
      );
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedList = jsonEncode(myRecipes.map((e) => e.toJson()).toList());
    await prefs.setString('my_recipes', encodedList);
  }

  // --- ACTIONS: DICE ROLL ---
  void _rollDice() {
    // 🔇 Sound Completely Removed per request

    // 20% Chance: User Memory
    if (myRecipes.isNotEmpty && Random().nextInt(5) == 0) {
      final randomRecipe = myRecipes[Random().nextInt(myRecipes.length)];
      setState(() {
        currentRolledRecipe = randomRecipe;
        canSaveRoll = false;

        currentMethod = randomRecipe.method;
        currentRatio = randomRecipe.ratio.isNotEmpty
            ? randomRecipe.ratio
            : "1:15";
        String origin = randomRecipe.beanOrigin.isNotEmpty
            ? randomRecipe.beanOrigin
            : "Saved Brew";
        currentWildcard = "Try your '$origin' recipe!";
      });
    } else {
      // 80% Chance: Pro Recipe
      final proRecipe =
          ProRecipes.list[Random().nextInt(ProRecipes.list.length)];
      setState(() {
        currentRolledRecipe = proRecipe;
        canSaveRoll = true;
        currentMethod = proRecipe.method;
        currentRatio = proRecipe.ratio;
        currentWildcard = proRecipe.notes.split('\n')[0];
      });
    }
  }

  // --- ACTIONS: SAVE & STATS ---
  Future<void> _saveRolledRecipe() async {
    if (currentRolledRecipe == null) return;
    SoundManager().play('success.mp3');

    Recipe newEntry = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: currentRolledRecipe!.method,
      beanOrigin: "Dice Roll (${currentRolledRecipe!.beanOrigin})",
      roastLevel: currentRolledRecipe!.roastLevel,
      grindSetting: currentRolledRecipe!.grindSetting,
      doseWeight: currentRolledRecipe!.doseWeight,
      waterWeight: currentRolledRecipe!.waterWeight,
      waterTemp: currentRolledRecipe!.waterTemp,
      ratio: currentRolledRecipe!.ratio,
      brewTime: currentRolledRecipe!.brewTime,
      notes: "Rolled on Coffee Dice!\n\n${currentRolledRecipe!.notes}",
      date: DateTime.now(),
      grinderId: activeGrinderId,
    );

    setState(() {
      myRecipes.add(newEntry);
      canSaveRoll = false;
    });
    await _saveData();
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to Journal!')));
  }

  Future<void> _handleSaveRecipe(Recipe newRecipe) async {
    SoundManager().play('success.mp3');
    setState(() => myRecipes.add(newRecipe));
    await _saveData();
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recipe Saved! ☕')));
  }

  Future<void> _deleteRecipe(int index) async {
    SoundManager().play('click.ogg');
    setState(() => myRecipes.removeAt(index));
    await _saveData();
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry Deleted')));
  }

  // --- STATS QUICK ACTIONS ---
  void _quickAddStat(String method) {
    SoundManager().play('success.mp3');
    Recipe quickEntry = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      beanOrigin: "Quick Log",
      roastLevel: "Medium",
      grindSetting: "Generic",
      doseWeight: 0,
      waterWeight: 0,
      waterTemp: 0,
      ratio: "-",
      brewTime: "-",
      notes: "Added via Stats Quick-Log",
      date: DateTime.now(),
      grinderId: activeGrinderId,
    );
    setState(() => myRecipes.add(quickEntry));
    _saveData();
    Navigator.pop(context);
    _showStats();
  }

  void _quickRemoveStat(String method) {
    int indexToRemove = -1;
    for (int i = myRecipes.length - 1; i >= 0; i--) {
      if (myRecipes[i].method == method) {
        indexToRemove = i;
        break;
      }
    }

    if (indexToRemove != -1) {
      SoundManager().play('click.ogg');
      setState(() => myRecipes.removeAt(indexToRemove));
      _saveData();
      Navigator.pop(context);
      _showStats();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No entries to remove!')));
    }
  }

  // --- NAVIGATION HELPERS ---
  void _openAddSheet() {
    SoundManager().play('click.ogg');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor, // Adapts to theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddRecipeSheet(onSave: _handleSaveRecipe),
    );
  }

  void _showStats() {
    SoundManager().play('click.ogg');
    showDialog(
      context: context,
      builder: (context) => StatsDialog(
        recipes: myRecipes,
        onQuickAdd: _quickAddStat,
        onQuickRemove: _quickRemoveStat,
      ),
    );
  }

  void _editRecipeFromCard(int index) {
    SoundManager().play('click.ogg');
    showDialog(
      context: context,
      builder: (context) => RecipeDetailsDialog(
        recipe: myRecipes[index],
        index: index,
        onDelete: _deleteRecipe,
        useCelsius: useCelsius,
      ),
    );
  }

  void _showProfileSettings() {
    SoundManager().play('click.ogg');
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        currentName: nickname,
        currentAge: age,
        currentPronouns: pronouns,
        currentBio: bio,
        currentAvatar: avatarUrl,
        onSave: _saveProfile,
      ),
    );
  }

  Future<void> _saveProfile(
    String n,
    String a,
    String p,
    String b,
    String u,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nickname', n);
    await prefs.setString('user_age', a);
    await prefs.setString('user_pronouns', p);
    await prefs.setString('user_bio', b);
    await prefs.setString('user_avatar', u);
    setState(() {
      nickname = n;
      age = a;
      pronouns = p;
      bio = b;
      avatarUrl = u;
    });
    if (mounted) Navigator.pop(context);
  }

  void _openGrinderSettings() {
    SoundManager().play('click.ogg');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GrinderPage()),
    ).then((_) => _loadProfile());
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _scaffoldKey.currentState?.openDrawer();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,

        drawer: SideMenu(
          nickname: nickname,
          email: user?.email ?? "Guest",
          avatarUrl: avatarUrl,
          bio: bio,
          pronouns: pronouns,
          isLightMode: widget.isLightMode,
          currentGrinderName: activeGrinderName,
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
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: isDark ? Colors.white : const Color(0xFF3E2723),
            ), // Fixed Icon Color
            onPressed: () {
              SoundManager().play('click.ogg');
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              Column(
                children: [
                  DiceRoller(
                    method: currentMethod,
                    ratio: currentRatio,
                    wildcard: currentWildcard,
                    onRoll: _rollDice,
                  ),
                  if (canSaveRoll)
                    TextButton.icon(
                      onPressed: _saveRolledRecipe,
                      icon: Icon(
                        Icons.bookmark_add,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF3E2723),
                      ),
                      label: Text(
                        "Save this Recipe",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF3E2723),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MY JOURNAL",
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                          return RecipeCard(
                            recipe: myRecipes[reversedIndex],
                            onTap: () {
                              SoundManager().play('click.ogg');
                              showDialog(
                                context: context,
                                builder: (context) => RecipeDetailsDialog(
                                  recipe: myRecipes[reversedIndex],
                                  index: reversedIndex,
                                  onDelete: _deleteRecipe,
                                  useCelsius: useCelsius,
                                ),
                              );
                            },
                            onEdit: () => _editRecipeFromCard(reversedIndex),
                            onDelete: () => _deleteRecipe(reversedIndex),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddSheet,
          backgroundColor: isDark
              ? Colors.white
              : const Color(0xFF3E2723), // Adaptive FAB
          icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
          label: Text(
            "Log Brew",
            style: TextStyle(
              color: isDark ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
