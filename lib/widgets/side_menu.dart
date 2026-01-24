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
  final String currentGrinderName;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Standard color for icons/text to avoid purple
    final Color coffeeColor = const Color(0xFF3E2723);
    final Color iconColor = Colors.grey[600]!;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // --- IMPROVED HEADER ---
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            width: double.infinity,
            color: coffeeColor, // Solid Coffee Background
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.avatarUrl.isNotEmpty
                      ? NetworkImage(widget.avatarUrl)
                      : null,
                  child: widget.avatarUrl.isEmpty
                      ? Text(
                          widget.nickname.isNotEmpty
                              ? widget.nickname[0].toUpperCase()
                              : "C",
                          style: TextStyle(fontSize: 30, color: coffeeColor),
                        )
                      : null,
                ),
                const SizedBox(height: 15),
                Text(
                  "${widget.nickname} ${widget.pronouns.isNotEmpty ? '(${widget.pronouns})' : ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.currentGrinderName.isNotEmpty
                      ? "⚙️ ${widget.currentGrinderName}"
                      : widget.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (widget.bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.bio,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // --- MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader("BREWING"),
                SwitchListTile(
                  title: const Text("Units: °F / °C"),
                  subtitle: Text(
                    useCelsius ? "Using Celsius" : "Using Fahrenheit",
                  ),
                  value: useCelsius,
                  activeColor: const Color(0xFF8D6E63),
                  secondary: Icon(Icons.thermostat, color: iconColor),
                  onChanged: (val) async {
                    setState(() => useCelsius = val);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('pref_celsius', val);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: iconColor),
                  title: const Text("My Grinder"),
                  subtitle: Text(
                    widget.currentGrinderName,
                    style: TextStyle(color: coffeeColor),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onShowGrinder();
                  },
                ),

                const Divider(),
                _buildSectionHeader("MY DATA"),
                ListTile(
                  leading: Icon(Icons.bar_chart, color: iconColor),
                  title: const Text("My Coffee Stats"),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onShowStats();
                  },
                ),

                const Divider(),
                _buildSectionHeader("APP INFO"),
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: !widget.isLightMode,
                  activeColor: const Color(0xFF8D6E63),
                  secondary: Icon(Icons.nightlight_round, color: iconColor),
                  onChanged: (val) => widget.onToggleTheme(),
                ),
              ],
            ),
          ),

          // --- BOTTOM ACTIONS ---
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.person_outline, color: iconColor),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF3E2723), // Fixed Brown Color (No Purple!)
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
