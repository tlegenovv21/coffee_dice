// lib/widgets/side_menu.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  final String nickname;
  final String email;
  final String avatarUrl;
  final String bio;
  final String pronouns;
  final bool isLightMode;
  final String currentGrinderName; // Passed from Home Page
  final VoidCallback onToggleTheme;
  final VoidCallback onEditProfile;
  final VoidCallback onShowStats;
  final VoidCallback onShowGrinder;

  const SideMenu({
    super.key,
    required this.nickname,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.pronouns,
    required this.isLightMode,
    required this.currentGrinderName,
    required this.onToggleTheme,
    required this.onEditProfile,
    required this.onShowStats,
    required this.onShowGrinder,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // We keep useCelsius here so the toggle remembers its state locally
  bool useCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useCelsius = prefs.getBool('pref_celsius') ?? true;
      // We DO NOT load grinder here anymore. We use the one passed from Home Page.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // --- HEADER ---
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF3E2723)),
            accountName: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.nickname} ${widget.pronouns.isNotEmpty ? '(${widget.pronouns})' : ''}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (widget.bio.isNotEmpty)
                  Text(
                    widget.bio,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            accountEmail: Text(
              widget.currentGrinderName.isNotEmpty
                  ? "Grinder: ${widget.currentGrinderName}"
                  : widget.email,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: widget.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.avatarUrl)
                  : null,
              child: widget.avatarUrl.isEmpty
                  ? Text(
                      widget.nickname.isNotEmpty
                          ? widget.nickname[0].toUpperCase()
                          : "C",
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color(0xFF3E2723),
                      ),
                    )
                  : null,
            ),
          ),

          // --- MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader(theme, "BREWING"),
                SwitchListTile(
                  title: const Text("Units: °C / °F"),
                  subtitle: Text(
                    useCelsius ? "Using Celsius" : "Using Fahrenheit",
                  ),
                  value: useCelsius,
                  activeColor: const Color(0xFF8D6E63),
                  secondary: const Icon(Icons.thermostat),
                  onChanged: (val) async {
                    setState(() => useCelsius = val);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('pref_celsius', val);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text("My Grinder"),
                  // FIX: Use 'widget.currentGrinderName' instead of local variable
                  subtitle: Text(widget.currentGrinderName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onShowGrinder();
                  },
                ),
                const Divider(),
                _buildSectionHeader(theme, "MY DATA"),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text("My Coffee Stats"),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onShowStats();
                  },
                ),
                const Divider(),
                _buildSectionHeader(theme, "APP INFO"),
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: !widget.isLightMode,
                  activeColor: const Color(0xFF8D6E63),
                  secondary: const Icon(Icons.nightlight_round),
                  onChanged: (val) => widget.onToggleTheme(),
                ),
              ],
            ),
          ),

          // --- BOTTOM ACTIONS ---
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.pop(context);
              widget.onEditProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Log Out",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
