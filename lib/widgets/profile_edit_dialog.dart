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

  // Helper to style text fields cleanly
  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF3E2723)), // Coffee Color
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF3E2723), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text(
        "Edit Profile",
        style: TextStyle(color: Color(0xFF3E2723)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: _inputStyle("Nickname"),
          ),
          const SizedBox(height: 10),
          TextField(controller: _ageController, decoration: _inputStyle("Age")),
          const SizedBox(height: 10),
          TextField(
            controller: _pronounsController,
            decoration: _inputStyle("Pronouns (he/him)"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bioController,
            maxLength: 30,
            decoration: _inputStyle("Bio"),
          ),
          TextField(
            controller: _urlController,
            decoration: _inputStyle("Avatar URL (Image Link)"),
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
