// lib/widgets/profile_edit_dialog.dart
import 'package:flutter/material.dart';

class ProfileEditDialog extends StatefulWidget {
  final String currentName;
  final String currentAge;
  final String currentPronouns;
  final String currentBio;
  final String currentAvatar;
  final Function(String, String, String, String, String) onSave;

  const ProfileEditDialog({
    super.key,
    required this.currentName,
    required this.currentAge,
    required this.currentPronouns,
    required this.currentBio,
    required this.currentAvatar,
    required this.onSave,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _pronounsController;
  late TextEditingController _bioController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _ageController = TextEditingController(text: widget.currentAge);
    _pronounsController = TextEditingController(text: widget.currentPronouns);
    _bioController = TextEditingController(text: widget.currentBio);
    _urlController = TextEditingController(text: widget.currentAvatar);
  }

  // FIXED STYLE HELPER
  InputDecoration _inputStyle(String label, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : const Color(0xFF3E2723),
      ),

      // Add a background fill so text is readable in Dark Mode
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3E2723), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine title color based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return AlertDialog(
      scrollable: true,
      backgroundColor: Theme.of(context).cardColor, // Adapts to theme
      title: Text(
        "Edit Profile",
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: _inputStyle("Nickname", context),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ageController,
            decoration: _inputStyle("Age", context),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pronounsController,
            decoration: _inputStyle("Pronouns (he/him)", context),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bioController,
            maxLength: 30,
            decoration: _inputStyle("Bio", context),
          ),
          TextField(
            controller: _urlController,
            decoration: _inputStyle("Avatar URL (Image Link)", context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              _nameController.text,
              _ageController.text,
              _pronounsController.text,
              _bioController.text,
              _urlController.text,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E2723),
          ),
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
