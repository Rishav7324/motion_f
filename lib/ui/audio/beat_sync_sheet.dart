import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class BeatSyncSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const BeatSyncSheet({
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
      builder: (_) => BeatSyncSheet(layer: layer, project: project),
    );
  }

  @override
  State<BeatSyncSheet> createState() => _BeatSyncSheetState();
}

class _BeatSyncSheetState extends State<BeatSyncSheet> {
  final List<String> _voicePresets = [
    "None",
    "Studio Mic",
    "Deep Voice",
    "Bass Boost",
    "Vocal Clarity",
    "Echo Chamber",
    "Vintage Radio",
    "Chipmunk",
  ];

  @override
  Widget build(BuildContext context) {
    final beatCount = widget.layer.beatMarkers.length;

    return Container(
      height: 520,
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
                    const Icon(Icons.music_note, color: Color(0xFFFFD600), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "Beats & Audio Sync • ${widget.layer.name}",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Color(0xFFFFD600)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // 1. CapCut "Match Cut / Beats" Section
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt, color: Color(0xFFFFD600), size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Beat Detection (Match Cut)",
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD600).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$beatCount Beats",
                              style: const TextStyle(color: Color(0xFFFFD600), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Auto-generate yellow snap dots on timeline so your video cuts sync perfectly to the music.",
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 14),

                      // Auto Beat Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF262833),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.graphic_eq, size: 16, color: Color(0xFFFFD600)),
                              label: const Text("Beat 1 (Pulse)", style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                widget.project.generateAutoBeats(fastBeats: false);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF262833),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.flash_on, size: 16, color: Color(0xFFFFD600)),
                              label: const Text("Beat 2 (Fast)", style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                widget.project.generateAutoBeats(fastBeats: true);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Manual Tap Beat Button & Clear
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD600),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.touch_app, size: 16),
                              label: const Text("+ Tap to Add Beat", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                widget.project.addBeatMarker(widget.project.playheadTime);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Clear", style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              widget.project.clearBeatMarkers();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Audio Ducking
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.volume_down, color: Color(0xFF00E5FF), size: 18),
                              SizedBox(width: 8),
                              Text("Audio Ducking", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Switch(
                            value: widget.layer.audioDuckingEnabled,
                            activeColor: const Color(0xFF00E5FF),
                            onChanged: (val) {
                              setState(() => widget.layer.audioDuckingEnabled = val);
                              widget.project.notifyListeners();
                            },
                          ),
                        ],
                      ),
                      if (widget.layer.audioDuckingEnabled) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Music Volume Lowered By", style: TextStyle(color: Colors.white60, fontSize: 11)),
                            Text(
                              "${(widget.layer.audioDuckingAmount * 100).toInt()}%",
                              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Slider(
                          value: widget.layer.audioDuckingAmount,
                          min: 0.1,
                          max: 0.9,
                          activeColor: const Color(0xFF00E5FF),
                          onChanged: (val) {
                            setState(() => widget.layer.audioDuckingAmount = val);
                            widget.project.notifyListeners();
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Voice Changer & Equalizer Presets
                const Text(
                  "Voice Effects & EQ Presets",
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _voicePresets.map((preset) {
                    final isSel = widget.layer.voiceEffectPreset == preset;
                    return ChoiceChip(
                      label: Text(preset),
                      selected: isSel,
                      selectedColor: const Color(0xFFFFD600),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : Colors.white70,
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: const Color(0xFF1E2028),
                      onSelected: (selected) {
                        setState(() {
                          widget.layer.voiceEffectPreset = selected ? preset : "None";
                        });
                        widget.project.notifyListeners();
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // 4. Fade In / Fade Out Envelopes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Fade In Duration", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("${widget.layer.fadeInDuration.toStringAsFixed(1)}s", style: const TextStyle(color: Color(0xFFFFD600), fontSize: 12)),
                  ],
                ),
                Slider(
                  value: widget.layer.fadeInDuration,
                  min: 0.0,
                  max: 3.0,
                  activeColor: const Color(0xFFFFD600),
                  onChanged: (v) {
                    setState(() => widget.layer.fadeInDuration = v);
                    widget.project.notifyListeners();
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Fade Out Duration", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("${widget.layer.fadeOutDuration.toStringAsFixed(1)}s", style: const TextStyle(color: Color(0xFFFFD600), fontSize: 12)),
                  ],
                ),
                Slider(
                  value: widget.layer.fadeOutDuration,
                  min: 0.0,
                  max: 3.0,
                  activeColor: const Color(0xFFFFD600),
                  onChanged: (v) {
                    setState(() => widget.layer.fadeOutDuration = v);
                    widget.project.notifyListeners();
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
