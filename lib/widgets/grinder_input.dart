// lib/widgets/grinder_input.dart
import 'package:flutter/material.dart';
import '../models/grinder.dart';

class GrinderSettingInput extends StatefulWidget {
  final Grinder grinder;
  final double currentSetting;
  final Function(double) onChanged;

  const GrinderSettingInput({
    super.key,
    required this.grinder,
    required this.currentSetting,
    required this.onChanged,
  });

  @override
  State<GrinderSettingInput> createState() => _GrinderSettingInputState();
}

class _GrinderSettingInputState extends State<GrinderSettingInput> {
  @override
  Widget build(BuildContext context) {
    // UI LOGIC: Check Adjustment Type
    if (widget.grinder.adjustmentType == AdjustmentType.stepped) {
      return _buildSteppedInput();
    } else {
      return _buildSteplessInput();
    }
  }

  // 1. STEPPED: Shows "+" and "-" buttons for clicks
  Widget _buildSteppedInput() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            if (widget.currentSetting > widget.grinder.minRange) {
              widget.onChanged(
                widget.currentSetting - 1,
              ); // Decrease by 1 click
            }
          },
        ),
        Text(
          "Click: ${widget.currentSetting.toInt()}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            if (widget.currentSetting < widget.grinder.maxRange) {
              widget.onChanged(
                widget.currentSetting + 1,
              ); // Increase by 1 click
            }
          },
        ),
      ],
    );
  }

  // 2. STEPLESS: Shows a Slider for fine adjustment
  Widget _buildSteplessInput() {
    return Column(
      children: [
        Text("Setting: ${widget.currentSetting.toStringAsFixed(1)}"),
        Slider(
          value: widget.currentSetting,
          min: widget.grinder.minRange,
          max: widget.grinder.maxRange,
          divisions: 100, // Allows for .1 increments
          label: widget.currentSetting.toString(),
          activeColor: const Color(0xFF3E2723),
          onChanged: (val) => widget.onChanged(val),
        ),
      ],
    );
  }
}
