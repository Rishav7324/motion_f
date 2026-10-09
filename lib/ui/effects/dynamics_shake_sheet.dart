import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class DynamicsShakeSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const DynamicsShakeSheet({
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
      builder: (_) => DynamicsShakeSheet(layer: layer, project: project),
    );
  }

  @override
  State<DynamicsShakeSheet> createState() => _DynamicsShakeSheetState();
}

class _DynamicsShakeSheetState extends State<DynamicsShakeSheet> {
  final List<Map<String, dynamic>> _presets = [
    {
      "name": "Handheld",
      "desc": "Natural human organic motion",
      "freq": 2.5,
      "amp": 12.0,
      "rot": 1.5,
      "icon": Icons.pan_tool,
    },
    {
      "name": "Action Impact",
      "desc": "Violent sudden explosion strike",
      "freq": 9.0,
      "amp": 45.0,
      "rot": 6.0,
      "icon": Icons.flash_on,
    },
    {
      "name": "Earthquake",
      "desc": "Continuous intense low rumble",
      "freq": 14.0,
      "amp": 60.0,
      "rot": 8.0,
      "icon": Icons.waves,
    },
    {
      "name": "Speed Jitter",
      "desc": "High frequency vibration",
      "freq": 18.0,
      "amp": 16.0,
      "rot": 2.0,
      "icon": Icons.speed,
    },
    {
      "name": "Heartbeat",
      "desc": "Rhythmic pulsing pump",
      "freq": 1.8,
      "amp": 28.0,
      "rot": 0.5,
      "icon": Icons.favorite,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
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
                    const Icon(Icons.vibration, color: Color(0xFFFF9100), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "Camera Shake & Wiggle • ${widget.layer.name}",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Switch(
                  value: widget.layer.shakeEnabled,
                  activeColor: const Color(0xFFFF9100),
                  onChanged: (val) {
                    setState(() => widget.layer.shakeEnabled = val);
                    widget.project.notifyListeners();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Presets Bar
                const Text("Dynamics Presets", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final p = _presets[idx];
                      final isSel = widget.layer.shakePreset == p["name"] && widget.layer.shakeEnabled;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.layer.shakeEnabled = true;
                            widget.layer.shakePreset = p["name"] as String;
                            widget.layer.shakeFrequency = p["freq"] as double;
                            widget.layer.shakeAmplitude = p["amp"] as double;
                            widget.layer.shakeRotation = p["rot"] as double;
                          });
                          widget.project.notifyListeners();
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFF9100).withOpacity(0.2) : const Color(0xFF1E2028),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFF9100) : Colors.white10,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(p["icon"] as IconData, size: 20, color: isSel ? const Color(0xFFFF9100) : Colors.white70),
                              const SizedBox(height: 4),
                              Text(
                                p["name"] as String,
                                style: TextStyle(
                                  color: isSel ? Colors.white : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Granular Sliders
                _buildSlider(
                  label: "Frequency (Speed)",
                  value: widget.layer.shakeFrequency,
                  min: 0.5,
                  max: 20.0,
                  displayValue: "${widget.layer.shakeFrequency.toStringAsFixed(1)} Hz",
                  onChanged: (v) => setState(() => widget.layer.shakeFrequency = v),
                ),

                _buildSlider(
                  label: "Amplitude (Intensity)",
                  value: widget.layer.shakeAmplitude,
                  min: 0.0,
                  max: 80.0,
                  displayValue: "${widget.layer.shakeAmplitude.toStringAsFixed(0)} px",
                  onChanged: (v) => setState(() => widget.layer.shakeAmplitude = v),
                ),

                _buildSlider(
                  label: "Rotational Jitter",
                  value: widget.layer.shakeRotation,
                  min: 0.0,
                  max: 15.0,
                  displayValue: "${widget.layer.shakeRotation.toStringAsFixed(1)}°",
                  onChanged: (v) => setState(() => widget.layer.shakeRotation = v),
                ),

                const SizedBox(height: 12),

                // Link to Motion Blur
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.blur_linear, color: Color(0xFFD500F9), size: 18),
                          SizedBox(width: 8),
                          Text("Add Motion Blur with Shake", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: widget.layer.motionBlurEnabled,
                        activeColor: const Color(0xFFD500F9),
                        onChanged: (v) {
                          setState(() => widget.layer.motionBlurEnabled = v);
                          widget.project.notifyListeners();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              displayValue,
              style: const TextStyle(color: Color(0xFFFF9100), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: const Color(0xFFFF9100),
          inactiveColor: Colors.white12,
          onChanged: (v) {
            onChanged(v);
            widget.project.notifyListeners();
          },
        ),
      ],
    );
  }
}
