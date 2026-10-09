import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class ChromaKeySheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const ChromaKeySheet({
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
      builder: (context) => ChromaKeySheet(layer: layer, project: project),
    );
  }

  @override
  State<ChromaKeySheet> createState() => _ChromaKeySheetState();
}

class _ChromaKeySheetState extends State<ChromaKeySheet> {
  final List<Color> _keyColors = const [
    Color(0xFF00FF00), // Standard Green Screen
    Color(0xFF0074D9), // Blue Screen
    Color(0xFFFF0055), // Magenta Screen
    Color(0xFFFFFFFF), // White Screen
    Color(0xFF000000), // Black Screen
  ];

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final project = widget.project;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.palette, color: Color(0xFF00E676), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Chroma Key (Green Screen Removal)",
                    style: TextStyle(
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

          // Enable Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Enable Chroma Key", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text("Removes solid color backgrounds using GLSL fragment shader", style: TextStyle(color: Colors.white54, fontSize: 11)),
            value: layer.chromaKeyEnabled,
            activeColor: const Color(0xFF00E676),
            onChanged: (val) {
              setState(() => layer.chromaKeyEnabled = val);
              project.notifyListeners();
            },
          ),
          const SizedBox(height: 12),

          if (layer.chromaKeyEnabled) ...[
            // Key Color Palette
            const Text("KEY COLOR TO REMOVE", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Row(
              children: _keyColors.map((c) {
                final isSel = layer.chromaKeyColor.value == c.value;
                return GestureDetector(
                  onTap: () {
                    setState(() => layer.chromaKeyColor = c);
                    project.notifyListeners();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSel ? Colors.white : Colors.white24,
                        width: isSel ? 3 : 1,
                      ),
                      boxShadow: isSel ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8)] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Similarity Slider
            _buildSliderRow(
              label: "Similarity (Threshold)",
              value: layer.chromaSimilarity,
              min: 0.05,
              max: 0.9,
              displayValue: "${(layer.chromaSimilarity * 100).toInt()}%",
              onChanged: (val) {
                setState(() => layer.chromaSimilarity = val);
                project.notifyListeners();
              },
            ),

            // Smoothness Slider
            _buildSliderRow(
              label: "Edge Smoothness",
              value: layer.chromaSmoothness,
              min: 0.01,
              max: 0.5,
              displayValue: "${(layer.chromaSmoothness * 100).toInt()}%",
              onChanged: (val) {
                setState(() => layer.chromaSmoothness = val);
                project.notifyListeners();
              },
            ),

            // Spill Reduction
            _buildSliderRow(
              label: "Spill Suppression",
              value: layer.chromaSpill,
              min: 0.0,
              max: 1.0,
              displayValue: "${(layer.chromaSpill * 100).toInt()}%",
              onChanged: (val) {
                setState(() => layer.chromaSpill = val);
                project.notifyListeners();
              },
            ),
          ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: const Color(0xFF00E676),
              inactiveColor: Colors.white24,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 45,
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
