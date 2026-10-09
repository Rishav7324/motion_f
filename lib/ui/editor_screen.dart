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
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () {},
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

            // 2. Playback Transport Bar
            Container(
              height: 36,
              color: const Color(0xFF14151B),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_formatSec(project.playheadTime)} / ${_formatSec(project.duration)}",
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                  ),
                  IconButton(
                    icon: Icon(
                      project.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
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
                  Row(
                    children: [
                      const Icon(Icons.hd, size: 16, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        "${project.canvasWidth}x${project.canvasHeight}",
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
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
}
