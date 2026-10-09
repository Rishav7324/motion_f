import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';
import 'clip_widget.dart';

class TrackLane extends StatelessWidget {
  final int trackIndex;
  final List<LayerItem> layers;
  final ProjectModel project;
  final double pixelsPerSecond;
  final double totalWidth;

  const TrackLane({
    super.key,
    required this.trackIndex,
    required this.layers,
    required this.project,
    required this.pixelsPerSecond,
    required this.totalWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF181A20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Background grid line
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
              ),
            ),
          ),

          // Clips in this track
          ...layers.map((layer) => ClipWidget(
                layer: layer,
                project: project,
                pixelsPerSecond: pixelsPerSecond,
              )),

          // Inline "+ Add Media" button on primary track (CapCut style)
          if (trackIndex == 0)
            Positioned(
              left: layers.isEmpty
                  ? 12.0
                  : (layers.map((l) => l.startTime + l.duration).reduce((a, b) => a > b ? a : b) * pixelsPerSecond + 8.0),
              top: 7,
              bottom: 7,
              child: GestureDetector(
                onTap: () => project.importMediaFile(),
                child: Container(
                  width: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF222532),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 18, color: Color(0xFF00E5FF)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
