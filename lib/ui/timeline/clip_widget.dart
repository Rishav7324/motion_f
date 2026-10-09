import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class ClipWidget extends StatelessWidget {
  final LayerItem layer;
  final ProjectModel project;
  final double pixelsPerSecond;

  const ClipWidget({
    super.key,
    required this.layer,
    required this.project,
    required this.pixelsPerSecond,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = project.selectedLayerId == layer.id;
    final width = layer.duration * pixelsPerSecond;
    final left = layer.startTime * pixelsPerSecond;

    final keyframeTimes = layer.getAllKeyframeTimes();

    return Positioned(
      left: left,
      top: 4,
      bottom: 4,
      width: width,
      child: GestureDetector(
        onTap: () => project.selectLayer(layer.id),
        child: Container(
          decoration: BoxDecoration(
            color: layer.layerColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Clip Label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getLayerIcon(layer.type),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      layer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              // Visual Keyframe Diamond Dots (AE / CapCut signature feature)
              ...keyframeTimes.map((kfTime) {
                final kfOffset = (kfTime - layer.startTime) * pixelsPerSecond;
                if (kfOffset < 0 || kfOffset > width) return const SizedBox.shrink();

                return Positioned(
                  left: kfOffset - 5,
                  top: 2,
                  child: Transform.rotate(
                    angle: 0.785398, // 45 degrees for diamond shape
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black54, width: 1.0),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.video:
        return const Icon(Icons.movie, size: 14, color: Colors.white);
      case LayerType.audio:
        return const Icon(Icons.audiotrack, size: 14, color: Colors.white);
      case LayerType.text:
        return const Icon(Icons.title, size: 14, color: Colors.white);
      case LayerType.nullObject:
        return const Icon(Icons.control_camera, size: 14, color: Colors.white);
      case LayerType.camera:
        return const Icon(Icons.videocam, size: 14, color: Colors.white);
      case LayerType.adjustment:
        return const Icon(Icons.tune, size: 14, color: Colors.white);
    }
  }
}
