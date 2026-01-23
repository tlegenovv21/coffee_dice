import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/recipe.dart';

class TimerPage extends StatefulWidget {
  final Recipe recipe;

  const TimerPage({super.key, required this.recipe});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late int totalSeconds;
  late int remainingSeconds;
  Timer? _timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _parseTime();
  }

  // Convert string "3:00" or "3" to seconds
  void _parseTime() {
    try {
      String timeText = widget.recipe.brewTime.replaceAll(RegExp(r'[^0-9:]'), '');
      if (timeText.contains(':')) {
        List<String> parts = timeText.split(':');
        int min = int.parse(parts[0]);
        int sec = int.parse(parts[1]);
        totalSeconds = (min * 60) + sec;
      } else {
        totalSeconds = int.parse(timeText) * 60; // Assume minutes if no colon
      }
    } catch (e) {
      totalSeconds = 180; // Default to 3 minutes if parsing fails
    }
    remainingSeconds = totalSeconds;
  }

  void _toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      setState(() => isRunning = false);
    } else {
      setState(() => isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          setState(() => remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => isRunning = false);
          // TODO: Add Sound Effect here later!
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("☕ Brew Complete! Enjoy!")),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get timerText {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double percent = (totalSeconds - remainingSeconds) / totalSeconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.method, style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("BREWING", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold, color: Colors.grey[500])),
            const SizedBox(height: 40),
            
            // --- THE CIRCULAR TIMER ---
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 15.0,
              percent: percent,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(timerText, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color)),
                  Text(isRunning ? "Brewing..." : "Paused", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
              progressColor: const Color(0xFF8D6E63), // Coffee Color
              backgroundColor: theme.inputDecorationTheme.fillColor!,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animateFromLastPercent: true,
            ),
            
            const SizedBox(height: 60),
            
            // --- CONTROLS ---
            SizedBox(
              height: 60,
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _toggleTimer,
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(isRunning ? "PAUSE" : "START BREW"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning ? Colors.orange[800] : const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                setState(() {
                  isRunning = false;
                  remainingSeconds = totalSeconds;
                });
              },
              child: const Text("Reset", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}