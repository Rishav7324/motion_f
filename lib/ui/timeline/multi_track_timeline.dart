import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/layer.dart';
import 'track_lane.dart';
import 'playhead_line.dart';

class MultiTrackTimeline extends StatefulWidget {
  const MultiTrackTimeline({super.key});

  @override
  State<MultiTrackTimeline> createState() => _MultiTrackTimelineState();
}

class _MultiTrackTimelineState extends State<MultiTrackTimeline> {
  final ScrollController _scrollController = ScrollController();
  double _pixelsPerSecond = 60.0; // Zoom factor (30 to 200)

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectModel>();
    final totalWidth = project.duration * _pixelsPerSecond;
    final playheadX = project.playheadTime * _pixelsPerSecond;

    // Group layers by track index
    final Map<int, List<LayerItem>> trackGroups = {};
    for (int i = 0; i < 4; i++) {
      trackGroups[i] = [];
    }
    for (final layer in project.layers) {
      trackGroups.putIfAbsent(layer.trackIndex, () => []).add(layer);
    }

    return Container(
      color: const Color(0xFF101115),
      child: Column(
        children: [
          // 1. Time Ruler Header with Magnetic Snapping & Beat Indicators
          GestureDetector(
            onPanUpdate: (details) {
              final localX = details.localPosition.dx + _scrollController.offset;
              final rawTime = (localX / _pixelsPerSecond).clamp(0.0, project.duration);
              final newTime = project.snapTime(rawTime);
              project.setPlayheadTime(newTime);
            },
            onTapDown: (details) {
              final localX = details.localPosition.dx + _scrollController.offset;
              final rawTime = (localX / _pixelsPerSecond).clamp(0.0, project.duration);
              final newTime = project.snapTime(rawTime);
              project.setPlayheadTime(newTime);
            },
            child: Container(
              height: 24,
              color: const Color(0xFF14151B),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: totalWidth + 200,
                  child: CustomPaint(
                    size: Size(totalWidth, 24),
                    painter: _TimelineRulerPainter(
                      duration: project.duration,
                      pixelsPerSecond: _pixelsPerSecond,
                      project: project,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Track Lanes Container with Zoom Gesture
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (details) {
                if (details.horizontalScale != 1.0) {
                  setState(() {
                    _pixelsPerSecond = (_pixelsPerSecond * details.horizontalScale).clamp(25.0, 240.0);
                  });
                }
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth + 200,
                  child: Stack(
                    children: [
                      // List of Tracks
                      Column(
                        children: List.generate(4, (trackIdx) {
                          return TrackLane(
                            trackIndex: trackIdx,
                            layers: trackGroups[trackIdx] ?? [],
                            project: project,
                            pixelsPerSecond: _pixelsPerSecond,
                            totalWidth: totalWidth,
                          );
                        }),
                      ),

                      // Scrubbable Playhead Needle
                      PlayheadLine(
                        positionX: playheadX,
                        height: 200,
                        time: project.playheadTime,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRulerPainter extends CustomPainter {
  final double duration;
  final double pixelsPerSecond;
  final ProjectModel project;

  _TimelineRulerPainter({
    required this.duration,
    required this.pixelsPerSecond,
    required this.project,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace');
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    for (int sec = 0; sec <= duration; sec++) {
      final x = sec * pixelsPerSecond;

      // Major second tick
      canvas.drawLine(Offset(x, 12), Offset(x, 24), tickPaint);

      // Label
      final tp = TextPainter(
        text: TextSpan(text: "${sec}s", style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 2, 2));

      // Minor sub-second ticks
      for (int sub = 1; sub < 4; sub++) {
        final subX = x + (sub / 4.0) * pixelsPerSecond;
        canvas.drawLine(Offset(subX, 18), Offset(subX, 24), tickPaint);
      }
    }

    // Glowing Beat markers along top ruler
    final beatPaint = Paint()..color = const Color(0xFFFFD600);
    for (final layer in project.layers) {
      for (final bm in layer.beatMarkers) {
        final bX = (layer.startTime + bm) * pixelsPerSecond;
        if (bX >= 0 && bX <= size.width) {
          canvas.drawCircle(Offset(bX, 18), 2.5, beatPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineRulerPainter oldDelegate) {
    return oldDelegate.pixelsPerSecond != pixelsPerSecond ||
        oldDelegate.duration != duration ||
        oldDelegate.project.layers != project.layers;
  }
}
