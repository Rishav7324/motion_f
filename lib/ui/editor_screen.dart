import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import 'preview/preview_viewport.dart';
import 'timeline/multi_track_timeline.dart';
import 'dock/keyframe_diamond_bar.dart';
import 'dock/action_dock.dart';
import 'export/export_sheet.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  Timer? _playbackTimer;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _startPlaybackTimer(ProjectModel project) {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!project.isPlaying) {
        timer.cancel();
        return;
      }
      double nextTime = project.playheadTime + 0.033;
      if (nextTime >= project.duration) {
        nextTime = 0.0;
        project.togglePlayPause();
        timer.cancel();
      }
      project.setPlayheadTime(nextTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141519),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "MOTION F",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              project.name,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF00E5FF), size: 22),
            tooltip: "Add Media",
            onPressed: () => project.importMediaFile(),
          ),
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white70, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.white70, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
          // Export Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text("Export", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => ExportSheet.show(context, project),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Preview Viewport (Takes responsive upper space)
            const Expanded(
              flex: 5,
              child: PreviewViewport(),
            ),

            // 2. Playback Transport Bar with Precision Frame Stepping & Magnetic Snapping
            Container(
              height: 40,
              color: const Color(0xFF14151B),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timecode with frames
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 4),
                      Text(
                        "${_formatSecWithFrames(project.playheadTime, project.fps)} / ${_formatSec(project.duration)}",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Center Playback & Frame Stepping Controls
                  Row(
                    children: [
                      // Step Back 1 Frame
                      IconButton(
                        icon: const Icon(Icons.arrow_left, color: Colors.white70, size: 20),
                        tooltip: "Previous Frame",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => project.stepFrame(-1),
                      ),
                      // Play / Pause Button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2028),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            project.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFF00E5FF),
                            size: 20,
                          ),
                          onPressed: () {
                            project.togglePlayPause();
                            if (project.isPlaying) {
                              _startPlaybackTimer(project);
                            } else {
                              _playbackTimer?.cancel();
                            }
                          },
                        ),
                      ),
                      // Step Forward 1 Frame
                      IconButton(
                        icon: const Icon(Icons.arrow_right, color: Colors.white70, size: 20),
                        tooltip: "Next Frame",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => project.stepFrame(1),
                      ),
                    ],
                  ),

                  // Right: Magnetic Snapping & Resolution
                  Row(
                    children: [
                      // Magnetic Snapping Toggle
                      GestureDetector(
                        onTap: () => project.toggleSnapping(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: project.isSnappingEnabled ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: project.isSnappingEnabled ? const Color(0xFF00E5FF) : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.center_focus_strong,
                                size: 13,
                                color: project.isSnappingEnabled ? const Color(0xFF00E5FF) : Colors.white54,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "SNAP",
                                style: TextStyle(
                                  color: project.isSnappingEnabled ? const Color(0xFF00E5FF) : Colors.white54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${project.fps}FPS",
                        style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Keyframe Diamond Control Bar (+◇ / -◇ and Curves button)
            const KeyframeDiamondBar(),

            // 4. Multi-Track Timeline (Pinch-to-zoom & Magnetic scrubbing)
            const Expanded(
              flex: 4,
              child: MultiTrackTimeline(),
            ),

            // 5. CapCut Contextual Bottom Action Dock
            const ActionDock(),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1C22),
        title: const Text("Export Composition", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Resolution: ${project.canvasWidth}x${project.canvasHeight} (Full HD)", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text("Frame Rate: ${project.fps} FPS", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            const Text("Engine: Media3 Hardware H.264 Encoder + C++ Compositor", style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
            child: const Text("Start Export"),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Export started via Android Media3 Hardware Pipeline...")),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatSec(double sec) {
    int m = (sec / 60).floor();
    int s = (sec % 60).floor();
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String _formatSecWithFrames(double sec, int fps) {
    int m = (sec / 60).floor();
    int s = (sec % 60).floor();
    int f = ((sec - (m * 60 + s)) * (fps > 0 ? fps : 30)).floor();
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${f.toString().padLeft(2, '0')}";
  }
}

