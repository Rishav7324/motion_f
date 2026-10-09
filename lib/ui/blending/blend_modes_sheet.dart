import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class BlendModesSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const BlendModesSheet({
    super.key,
    required this.layer,
    required this.project,
  });

  static void show(BuildContext context, LayerItem layer, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141519),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlendModesSheet(layer: layer, project: project),
    );
  }

  @override
  State<BlendModesSheet> createState() => _BlendModesSheetState();
}

class _BlendModesSheetState extends State<BlendModesSheet> {
  final List<Map<String, dynamic>> _modes = [
    {"mode": LayerBlendMode.normal, "name": "Normal", "desc": "Standard opacity stacking"},
    {"mode": LayerBlendMode.screen, "name": "Screen", "desc": "Lightens, removes black backgrounds"},
    {"mode": LayerBlendMode.multiply, "name": "Multiply", "desc": "Darkens, removes white backgrounds"},
    {"mode": LayerBlendMode.overlay, "name": "Overlay", "desc": "Boosts contrast, preserves highlights"},
    {"mode": LayerBlendMode.add, "name": "Linear Add", "desc": "Intense additive light glow"},
    {"mode": LayerBlendMode.softLight, "name": "Soft Light", "desc": "Gentle contrast diffusion"},
  ];

  @override
  Widget build(BuildContext context) {
    final curOpacity = widget.layer.opacity.evaluate(widget.project.playheadTime);

    return Container(
      height: 440,
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: Column(
        children: [
          // Drag handle
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
                    const Icon(Icons.layers_outlined, color: Color(0xFFFF4081), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "Blend Modes & Opacity • ${widget.layer.name}",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Color(0xFFFF4081)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // 1. Opacity Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Layer Opacity", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      "${(curOpacity * 100).toInt()}%",
                      style: const TextStyle(color: Color(0xFFFF4081), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: curOpacity.clamp(0.0, 1.0),
                  min: 0.0,
                  max: 1.0,
                  activeColor: const Color(0xFFFF4081),
                  inactiveColor: Colors.white12,
                  onChanged: (v) {
                    setState(() {
                      widget.layer.opacity.defaultValue = v;
                    });
                    widget.project.notifyListeners();
                  },
                ),

                const SizedBox(height: 16),

                const Text("Compositing Blend Mode", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // 2. Modes Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _modes.length,
                  itemBuilder: (context, idx) {
                    final item = _modes[idx];
                    final isSel = widget.layer.blendMode == item["mode"];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.layer.blendMode = item["mode"] as LayerBlendMode;
                        });
                        widget.project.notifyListeners();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFF4081).withOpacity(0.2) : const Color(0xFF1E2028),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? const Color(0xFFFF4081) : Colors.white10,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item["name"] as String,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["desc"] as String,
                              style: const TextStyle(color: Colors.white54, fontSize: 9),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
