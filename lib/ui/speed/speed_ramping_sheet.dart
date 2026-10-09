import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class SpeedRampingSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const SpeedRampingSheet({
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
      builder: (context) => SpeedRampingSheet(layer: layer, project: project),
    );
  }

  @override
  State<SpeedRampingSheet> createState() => _SpeedRampingSheetState();
}

class _SpeedRampingSheetState extends State<SpeedRampingSheet> {
  final List<_CurvePreset> _presets = const [
    _CurvePreset("Standard", Icons.linear_scale, "Constant linear playback speed"),
    _CurvePreset("Montage", Icons.auto_awesome, "Slow down at impact, fast in between"),
    _CurvePreset("Hero Moment", Icons.military_tech, "Dramatic 0.2x slowdown at keyframe action"),
    _CurvePreset("Bullet Time", Icons.flash_on, "Matrix-style freeze & high-speed acceleration"),
    _CurvePreset("Jump Cut", Icons.fast_forward, "Snappy time compression rhythm"),
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
                  Icon(Icons.speed, color: Color(0xFFFFD600), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Speed Ramping & Curve Remap",
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

          // Speed Mode Selector (Normal vs Curve)
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("Standard Speed")),
                  selected: !layer.isCurveSpeed,
                  selectedColor: const Color(0xFFFFD600),
                  backgroundColor: const Color(0xFF22232C),
                  labelStyle: TextStyle(
                    color: !layer.isCurveSpeed ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    setState(() => layer.isCurveSpeed = false);
                    project.notifyListeners();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("Curve Speed Ramping")),
                  selected: layer.isCurveSpeed,
                  selectedColor: const Color(0xFFFFD600),
                  backgroundColor: const Color(0xFF22232C),
                  labelStyle: TextStyle(
                    color: layer.isCurveSpeed ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    setState(() => layer.isCurveSpeed = true);
                    project.notifyListeners();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (!layer.isCurveSpeed) ...[
            // 1. Standard Speed Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("PLAYBACK SPEED", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(
                  "${layer.speed.toStringAsFixed(1)}x",
                  style: const TextStyle(color: Color(0xFFFFD600), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ],
            ),
            Slider(
              value: layer.speed.clamp(0.1, 10.0),
              min: 0.1,
              max: 10.0,
              divisions: 99,
              activeColor: const Color(0xFFFFD600),
              inactiveColor: Colors.white24,
              onChanged: (val) {
                setState(() => layer.speed = val);
                project.notifyListeners();
              },
            ),

            // Quick Speed Preset Buttons
            Row(
              children: [
                _buildQuickSpeedBtn("0.5x (Slow)", 0.5),
                const SizedBox(width: 8),
                _buildQuickSpeedBtn("1.0x (Normal)", 1.0),
                const SizedBox(width: 8),
                _buildQuickSpeedBtn("2.0x (Fast)", 2.0),
                const SizedBox(width: 8),
                _buildQuickSpeedBtn("4.0x (Hyper)", 4.0),
              ],
            ),
          ] else ...[
            // 2. CapCut Curve Speed Presets
            const Text("CAPCUT CURVE SPEED PRESETS", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ..._presets.map((preset) {
              final isSel = layer.curveSpeedPreset == preset.name;
              return GestureDetector(
                onTap: () {
                  setState(() => layer.curveSpeedPreset = preset.name);
                  project.notifyListeners();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFFFD600).withOpacity(0.12) : const Color(0xFF22232C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? const Color(0xFFFFD600) : Colors.white12,
                      width: isSel ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(preset.icon, color: isSel ? const Color(0xFFFFD600) : Colors.white60, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: TextStyle(
                                color: isSel ? const Color(0xFFFFD600) : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              preset.desc,
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      if (isSel)
                        const Icon(Icons.check_circle, color: Color(0xFFFFD600), size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickSpeedBtn(String label, double val) {
    final isSel = (widget.layer.speed - val).abs() < 0.05;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => widget.layer.speed = val);
          widget.project.notifyListeners();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFFFD600) : const Color(0xFF22232C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurvePreset {
  final String name;
  final IconData icon;
  final String desc;

  const _CurvePreset(this.name, this.icon, this.desc);
}
