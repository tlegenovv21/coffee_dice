import 'package:flutter/material.dart';
import 'dart:math'; 

void main() {
  runApp(const CoffeeDiceApp());
}

class CoffeeDiceApp extends StatelessWidget {
  const CoffeeDiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Dice',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color.fromARGB(255, 195, 142, 115),
      ),
      home: const DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  // --- BARISTA DATA ---
  final List<String> methods = [
    'V60 Pour Over', 'Aeropress', 'French Press', 'Chemex', 'Moka Pot', 'Cold Brew'
  ];
  final List<String> ratios = [
    '1:12 (Strong)', '1:15 (Standard)', '1:16 (Light)', '1:10 (Concentrate)'
  ];
  final List<String> wildcards = [
    'Grind Finer!', 'Use hotter water', 'Stir 3 times', 'Pour very slowly', 'Double filter', 'Trust your instincts'
  ];

  // --- APP STATE ---
  String currentMethod = 'Press the Button';
  String currentRatio = 'to roll';
  String currentWildcard = 'the dice!';

  // --- THE LOGIC ---
  void rollDice() {
    setState(() {
      currentMethod = methods[Random().nextInt(methods.length)];
      currentRatio = ratios[Random().nextInt(ratios.length)];
      currentWildcard = wildcards[Random().nextInt(wildcards.length)];
    });
  }

  // --- THE UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Coffee Dice'),
        centerTitle: true,
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('METHOD', style: TextStyle(color: Colors.brown[300], letterSpacing: 2)),
              Text(currentMethod, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Text('RATIO', style: TextStyle(color: Colors.brown[300], letterSpacing: 2)),
              Text(currentRatio, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Text('WILD CARD', style: TextStyle(color: Colors.brown[300], letterSpacing: 2)),
              Text(currentWildcard, style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.brown[600]), textAlign: TextAlign.center),
              const SizedBox(height: 60),
              SizedBox(
                width: 200, height: 60,
                child: ElevatedButton.icon(
                  onPressed: rollDice,
                  icon: const Icon(Icons.casino),
                  label: const Text('ROLL DICE', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700], foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}