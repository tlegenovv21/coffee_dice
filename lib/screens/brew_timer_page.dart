// lib/screens/brew_timer_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sound_manager.dart';

class BrewTimerPage extends StatefulWidget {
  const BrewTimerPage({super.key});

  @override
  State<BrewTimerPage> createState() => _BrewTimerPageState();
}

class _BrewTimerPageState extends State<BrewTimerPage> {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // Settings
  bool _bloomAlert = true;
  final int _bloomTime = 45; // Seconds for bloom

  // Display String
  String get _formattedTime {
    final duration = _stopwatch.elapsed;
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _startTimer() {
    setState(() {
      _stopwatch.start();
    });
    SoundManager().play('click.ogg');

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {}); // Update UI

      // Bloom Alert Logic
      if (_bloomAlert &&
          _stopwatch.elapsed.inSeconds == _bloomTime &&
          _stopwatch.elapsed.inMilliseconds % 1000 < 100) {
        // Play sound exactly at 45s (and prevent multi-triggering)
        SoundManager().play('success.mp3');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🌸 Bloom Phase Complete! Start Pouring."),
          ),
        );
      }
    });
  }

  void _stopTimer() {
    SoundManager().play('click.ogg');
    setState(() {
      _stopwatch.stop();
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    SoundManager().play('click.ogg');
    _stopTimer();
    setState(() {
      _stopwatch.reset();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    // Dynamic Background Color based on phase
    Color bgColor = theme.scaffoldBackgroundColor;
    String statusText = "Ready to Brew";

    if (_stopwatch.isRunning) {
      if (_bloomAlert && _stopwatch.elapsed.inSeconds < _bloomTime) {
        statusText = "🌸 BLOOMING";
        bgColor = isDark ? Colors.purple[900]! : Colors.purple[50]!;
      } else {
        statusText = "☕ BREWING";
        bgColor = isDark ? Colors.brown[900]! : Colors.orange[50]!;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Brew Timer",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status Text
          Text(
            statusText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.7),
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 40),

          // BIG CLOCK
          Text(
            _formattedTime,
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.w200, // Thin modern font
              color: textColor,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ], // Keeps numbers from jumping width
            ),
          ),

          const SizedBox(height: 20),

          // Bloom Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: _bloomAlert,
                activeColor: const Color(0xFF3E2723),
                onChanged: (val) {
                  setState(() => _bloomAlert = val);
                  SoundManager().play('click.ogg');
                },
              ),
              Text("Alert at 45s (Bloom)", style: TextStyle(color: textColor)),
            ],
          ),

          const SizedBox(height: 60),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.refresh),
                color: Colors.grey,
                onPressed: _resetTimer,
              ),

              // Play / Pause
              GestureDetector(
                onTap: _stopwatch.isRunning ? _stopTimer : _startTimer,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                    color: isDark ? Colors.black : Colors.white,
                    size: 40,
                  ),
                ),
              ),

              // Dummy spacer to balance layout
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }
}
