import 'package:flutter/material.dart';
import '../../models/curve_preset.dart';

class PresetSelector extends StatelessWidget {
  final Function(CurvePreset) onSelectPreset;

  const PresetSelector({
    super.key,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CurvePreset.allPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final preset = CurvePreset.allPresets[index];
          return ActionChip(
            label: Text(
              preset.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF262830),
            labelStyle: const TextStyle(color: Colors.white),
            side: const BorderSide(color: Colors.white24, width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () => onSelectPreset(preset),
          );
        },
      ),
    );
  }
}
