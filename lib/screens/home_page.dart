// lib/screens/home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// --- WIDGET IMPORTS ---
import '../models/recipe.dart';
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
    "Origami Dripper",
  ];
  final List<String> coffeeRatios = [
    "1:15 (Balanced)",
    "1:16 (Tea-like)",
    "1:17 (Light)",
    "1:12 (Strong)",
    "1:10 (Concentrate)",
  ];
  final List<String> wildcards = [
    "Use cooler water (88°C)",
    "Stir bloom vigorously",
    "Grind one step finer",
    "Pour really slowly",
    "Trust your instincts",
    "Use boiling water",
  ];

  String currentMethod = "V60 Pour Over";
  String currentRatio = "1:15 (Balanced)";
  String currentWildcard = "Trust your instincts";

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
          setState(
            () => activeGrinderName = "${data['brand']} ${data['model']}",
          );
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

  // --- ACTIONS ---
  void _rollDice() {
    // 🔇 Sound Removed here per request

    if (myRecipes.isNotEmpty && Random().nextInt(5) == 0) {
      // Memory Roll Logic
      final randomRecipe = myRecipes[Random().nextInt(myRecipes.length)];
      setState(() {
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
      // Standard Roll
      setState(() {
        currentMethod = brewingMethods[Random().nextInt(brewingMethods.length)];
        currentRatio = coffeeRatios[Random().nextInt(coffeeRatios.length)];
        currentWildcard = wildcards[Random().nextInt(wildcards.length)];
      });
    }
  }

  Future<void> _handleSaveRecipe(Recipe newRecipe) async {
    // 🔊 SOUND: Success (MP3)
    SoundManager().play('success.mp3');

    setState(() => myRecipes.add(newRecipe));
    await _saveData();
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe Saved! ☕'),
          backgroundColor: Color(0xFF3E2723),
        ),
      );
  }

  Future<void> _deleteRecipe(int index) async {
    // 🔊 SOUND: Click (OGG)
    SoundManager().play('click.ogg');

    setState(() => myRecipes.removeAt(index));
    await _saveData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry Deleted')));
    }
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

  // --- NAVIGATION HELPERS ---
  void _openAddSheet() {
    SoundManager().play('click.ogg');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
      builder: (context) => StatsDialog(recipes: myRecipes),
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
            icon: Icon(Icons.menu, color: theme.iconTheme.color),
            onPressed: () {
              SoundManager().play('click.ogg');
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              DiceRoller(
                method: currentMethod,
                ratio: currentRatio,
                wildcard: currentWildcard,
                onRoll: _rollDice,
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
          backgroundColor: const Color(0xFF3E2723),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Log Brew",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
