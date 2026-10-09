import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class EffectsSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const EffectsSheet({
    super.key,
    required this.layer,
    required this.project,
  });

  static void show(BuildContext context, LayerItem layer, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181920),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EffectsSheet(layer: layer, project: project),
    );
  }

  @override
  State<EffectsSheet> createState() => _EffectsSheetState();
}

class _EffectsSheetState extends State<EffectsSheet> {
  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final project = widget.project;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_fix_high, color: Color(0xFFD500F9), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Effects & Color: ${layer.name}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white12),

          // --- SECTION 1: MOTION BLUR ---
          const SizedBox(height: 6),
          const Text(
            "MOTION BLUR (PHYSICAL SHUTTER)",
            style: TextStyle(
              color: Color(0xFFD500F9),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Calculates velocity vectors from Bezier curves to synthesize shutter angle blur.",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Enable Motion Blur", style: TextStyle(color: Colors.white, fontSize: 13)),
            value: layer.motionBlurEnabled,
            activeColor: const Color(0xFFD500F9),
            onChanged: (val) {
              setState(() => layer.motionBlurEnabled = val);
              project.notifyListeners();
            },
          ),
          if (layer.motionBlurEnabled) ...[
            Row(
              children: [
                const Text("Samples: ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("8 Samples"),
                  selected: layer.motionBlurSamples == 8,
                  selectedColor: const Color(0xFFD500F9),
                  backgroundColor: const Color(0xFF22232C),
                  labelStyle: TextStyle(
                    color: layer.motionBlurSamples == 8 ? Colors.white : Colors.white70,
                    fontSize: 11,
                  ),
                  onSelected: (sel) {
                    if (sel) {
                      setState(() => layer.motionBlurSamples = 8);
                      project.notifyListeners();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("16 Samples (HQ)"),
                  selected: layer.motionBlurSamples == 16,
                  selectedColor: const Color(0xFFD500F9),
                  backgroundColor: const Color(0xFF22232C),
                  labelStyle: TextStyle(
                    color: layer.motionBlurSamples == 16 ? Colors.white : Colors.white70,
                    fontSize: 11,
                  ),
                  onSelected: (sel) {
                    if (sel) {
                      setState(() => layer.motionBlurSamples = 16);
                      project.notifyListeners();
                    }
                  },
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),

          // --- SECTION 2: STYLISTIC EFFECTS ---
          const SizedBox(height: 6),
          const Text(
            "OPTICAL & STYLISTIC EFFECTS",
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Chromatic Aberration
          _buildSliderRow(
            label: "Chromatic Aberration",
            value: layer.chromaticAberration,
            min: 0.0,
            max: 0.05,
            displayValue: "${(layer.chromaticAberration * 2000).toInt()}%",
            accentColor: const Color(0xFF00E5FF),
            onChanged: (val) {
              setState(() => layer.chromaticAberration = val);
              project.notifyListeners();
            },
          ),

          // Vignette
          _buildSliderRow(
            label: "Vignette Falloff",
            value: layer.vignette,
            min: 0.0,
            max: 1.0,
            displayValue: "${(layer.vignette * 100).toInt()}%",
            accentColor: const Color(0xFF00E5FF),
            onChanged: (val) {
              setState(() => layer.vignette = val);
              project.notifyListeners();
            },
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),

          // --- SECTION 3: COLOR GRADING ---
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "COLOR GRADING",
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.restart_alt, size: 14, color: Colors.white54),
                label: const Text("Reset All", style: TextStyle(color: Colors.white54, fontSize: 11)),
                onPressed: () {
                  setState(() {
                    layer.brightness = 0.0;
                    layer.contrast = 1.0;
                    layer.saturation = 1.0;
                    layer.temperature = 0.0;
                    layer.vignette = 0.0;
                    layer.chromaticAberration = 0.0;
                    layer.motionBlurEnabled = false;
                  });
                  project.notifyListeners();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Brightness
          _buildSliderRow(
            label: "Brightness",
            value: layer.brightness,
            min: -1.0,
            max: 1.0,
            displayValue: "${(layer.brightness * 100).toInt()}%",
            accentColor: const Color(0xFFFFD600),
            onChanged: (val) {
              setState(() => layer.brightness = val);
              project.notifyListeners();
            },
          ),

          // Contrast
          _buildSliderRow(
            label: "Contrast",
            value: layer.contrast,
            min: 0.0,
            max: 2.0,
            displayValue: "${(layer.contrast * 100).toInt()}%",
            accentColor: const Color(0xFFFFD600),
            onChanged: (val) {
              setState(() => layer.contrast = val);
              project.notifyListeners();
            },
          ),

          // Saturation
          _buildSliderRow(
            label: "Saturation",
            value: layer.saturation,
            min: 0.0,
            max: 2.0,
            displayValue: "${(layer.saturation * 100).toInt()}%",
            accentColor: const Color(0xFFFFD600),
            onChanged: (val) {
              setState(() => layer.saturation = val);
              project.notifyListeners();
            },
          ),

          // Temperature
          _buildSliderRow(
            label: "Temperature",
            value: layer.temperature,
            min: -1.0,
            max: 1.0,
            displayValue: layer.temperature < 0
                ? "Cool ${(layer.temperature.abs() * 100).toInt()}%"
                : "Warm ${(layer.temperature * 100).toInt()}%",
            accentColor: const Color(0xFFFF9100),
            onChanged: (val) {
              setState(() => layer.temperature = val);
              project.notifyListeners();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
    Color accentColor = const Color(0xFF00E5FF),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: accentColor,
              inactiveColor: Colors.white24,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
