// lib/services/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _isSoundOn = true;
  bool get isSoundOn => _isSoundOn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundOn = prefs.getBool('pref_sound') ?? true;
    print(
      "🔊 AUDIO DEBUG: Init complete. Sound system is ${_isSoundOn ? 'ON' : 'OFF'}",
    );
  }

  Future<void> toggleSound(bool value) async {
    _isSoundOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_sound', value);
    print("🔊 AUDIO DEBUG: Toggled sound to $value");
  }

  Future<void> play(String fileName) async {
    // 1. Check if Master Switch is ON
    if (!_isSoundOn) {
      print(
        "🔊 AUDIO DEBUG: Skipped '$fileName' (Sound is turned OFF in settings)",
      );
      return;
    }

    try {
      final player = AudioPlayer();

      // 2. Force Volume to Max (1.0)
      await player.setVolume(1.0);

      // 3. Log the path we are trying to find
      // Note: AssetSource('audio/x') looks for 'assets/audio/x'
      print("🔊 AUDIO DEBUG: Attempting to play 'assets/audio/$fileName'...");

      await player.play(AssetSource('audio/$fileName'));

      print("🔊 AUDIO DEBUG: Success! Command sent to play '$fileName'");

      // Cleanup when done
      player.onPlayerComplete.listen((event) {
        print("🔊 AUDIO DEBUG: Finished playing $fileName");
        player.dispose();
      });
    } catch (e) {
      // 4. Catch Errors
      print("🔴 AUDIO ERROR: Could not play '$fileName'. Reason: $e");
    }
  }
}
