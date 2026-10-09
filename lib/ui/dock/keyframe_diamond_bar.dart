import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/keyframe.dart';
import '../graph_editor/bezier_graph_editor.dart';

class KeyframeDiamondBar extends StatelessWidget {
  const KeyframeDiamondBar({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectModel>();
    final selectedLayer = project.selectedLayer;

    if (selectedLayer == null) return const SizedBox.shrink();

    final time = project.playheadTime;
    final hasKeyframe = selectedLayer.hasKeyframeAt(time);

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF16181E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Property indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selectedLayer.layerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                selectedLayer.name,
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Center: Keyframe Navigation & Diamond Button
          Row(
            children: [
              // Previous Keyframe
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 16, color: Colors.white54),
                tooltip: "Previous Keyframe",
                onPressed: () => _jumpKeyframe(project, selectedLayer, -1),
              ),

              // Signature Diamond Keyframe Button (+◇ / -◇)
              GestureDetector(
                onTap: () {
                  _toggleKeyframes(project, selectedLayer, time);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasKeyframe ? const Color(0xFF00E5FF) : Colors.white12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasKeyframe ? const Color(0xFF00E5FF) : Colors.white38,
                    ),
                  ),
                  child: Row(
                    children: [
                      Transform.rotate(
                        angle: 0.785398, // 45 deg diamond
                        child: Container(
                          width: 8,
                          height: 8,
                          color: hasKeyframe ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasKeyframe ? "- Keyframe" : "+ Keyframe",
                        style: TextStyle(
                          color: hasKeyframe ? Colors.black : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Next Keyframe
              IconButton(
                icon: const Icon(Icons.skip_next, size: 16, color: Colors.white54),
                tooltip: "Next Keyframe",
                onPressed: () => _jumpKeyframe(project, selectedLayer, 1),
              ),
            ],
          ),

          // Right: Graph Curve Editor Button (AE / CapCut curves)
          TextButton.icon(
            icon: const Icon(Icons.show_chart, size: 16, color: Color(0xFF00E5FF)),
            label: const Text(
              "Curves",
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // Open Bezier Graph Editor for Position X or Scale
              final prop = selectedLayer.posX;
              final kf = prop.getKeyframeAt(time) ??
                  (prop.keyframes.isNotEmpty ? prop.keyframes.first : null);

              if (kf != null) {
                BezierGraphEditorSheet.show(
                  context,
                  property: prop,
                  keyframe: kf,
                  onUpdated: () => project.notifyListeners(),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Add a keyframe first to edit curves!")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _toggleKeyframes(ProjectModel project, selectedLayer, double time) {
    if (selectedLayer.hasKeyframeAt(time)) {
      selectedLayer.posX.removeKeyframeAt(time);
      selectedLayer.posY.removeKeyframeAt(time);
      selectedLayer.scaleX.removeKeyframeAt(time);
      selectedLayer.scaleY.removeKeyframeAt(time);
      selectedLayer.rotZ.removeKeyframeAt(time);
    } else {
      selectedLayer.posX.addOrUpdateKeyframe(Keyframe(time: time, value: selectedLayer.posX.evaluate(time)));
      selectedLayer.posY.addOrUpdateKeyframe(Keyframe(time: time, value: selectedLayer.posY.evaluate(time)));
      selectedLayer.scaleX.addOrUpdateKeyframe(Keyframe(time: time, value: selectedLayer.scaleX.evaluate(time)));
      selectedLayer.scaleY.addOrUpdateKeyframe(Keyframe(time: time, value: selectedLayer.scaleY.evaluate(time)));
      selectedLayer.rotZ.addOrUpdateKeyframe(Keyframe(time: time, value: selectedLayer.rotZ.evaluate(time)));
    }
    project.notifyListeners();
  }

  void _jumpKeyframe(ProjectModel project, selectedLayer, int direction) {
    final times = selectedLayer.getAllKeyframeTimes();
    if (times.isEmpty) return;

    if (direction < 0) {
      // Find previous
      final prev = times.lastWhere((t) => t < project.playheadTime - 0.05, orElse: () => times.first);
      project.setPlayheadTime(prev);
    } else {
      // Find next
      final next = times.firstWhere((t) => t > project.playheadTime + 0.05, orElse: () => times.last);
      project.setPlayheadTime(next);
    }
  }
}
