import 'package:flutter/material.dart';
import '../../models/keyframe.dart';
import '../../models/curve_preset.dart';
import 'curve_canvas.dart';
import 'preset_selector.dart';

class BezierGraphEditorSheet extends StatefulWidget {
  final AnimatableProperty property;
  final Keyframe keyframe;
  final VoidCallback onUpdated;

  const BezierGraphEditorSheet({
    super.key,
    required this.property,
    required this.keyframe,
    required this.onUpdated,
  });

  static void show(
    BuildContext context, {
    required AnimatableProperty property,
    required Keyframe keyframe,
    required VoidCallback onUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141519),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BezierGraphEditorSheet(
        property: property,
        keyframe: keyframe,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<BezierGraphEditorSheet> createState() => _BezierGraphEditorSheetState();
}

class _BezierGraphEditorSheetState extends State<BezierGraphEditorSheet> {
  late Keyframe _activeKeyframe;

  @override
  void initState() {
    super.initState();
    _activeKeyframe = widget.keyframe;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      height: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: Color(0xFF00E5FF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "${widget.property.name} Curves",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Color(0xFF00E5FF)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Presets Bar
          PresetSelector(
            onSelectPreset: (preset) {
              setState(() {
                _activeKeyframe.applyPreset(preset);
              });
              widget.onUpdated();
            },
          ),

          const SizedBox(height: 16),

          // Interactive Curve Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1C22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CurveCanvas(
                  keyframe: _activeKeyframe,
                  onCurveChanged: (x1, y1, x2, y2) {
                    setState(() {
                      _activeKeyframe.cp1x = x1;
                      _activeKeyframe.cp1y = y1;
                      _activeKeyframe.cp2x = x2;
                      _activeKeyframe.cp2y = y2;
                    });
                    widget.onUpdated();
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Curve Coordinate Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "P1: (${_activeKeyframe.cp1x.toStringAsFixed(2)}, ${_activeKeyframe.cp1y.toStringAsFixed(2)})",
                  style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
                ),
                Text(
                  "P2: (${_activeKeyframe.cp2x.toStringAsFixed(2)}, ${_activeKeyframe.cp2y.toStringAsFixed(2)})",
                  style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
