import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class CameraOrbitGizmo extends StatelessWidget {
  final LayerItem camera;
  final ProjectModel project;

  const CameraOrbitGizmo({
    super.key,
    required this.camera,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final time = project.playheadTime;
    final fov = camera.cameraFov.evaluate(time);

    return Positioned(
      right: 16,
      top: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD500F9), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, color: Color(0xFFD500F9), size: 16),
                const SizedBox(width: 4),
                Text(
                  "3D Camera (FOV: ${fov.toStringAsFixed(0)}°)",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Orbit Joystick
            GestureDetector(
              onPanUpdate: (details) {
                final curX = camera.posX.evaluate(time);
                final curY = camera.posY.evaluate(time);

                final newX = curX + details.delta.dx * 5.0;
                final newY = curY - details.delta.dy * 5.0;

                if (camera.posX.hasKeyframeAt(time)) {
                  camera.posX.addOrUpdateKeyframe(camera.posX.getKeyframeAt(time)!.copyWith(value: newX));
                } else {
                  camera.posX.defaultValue = newX;
                }
                if (camera.posY.hasKeyframeAt(time)) {
                  camera.posY.addOrUpdateKeyframe(camera.posY.getKeyframeAt(time)!.copyWith(value: newY));
                } else {
                  camera.posY.defaultValue = newY;
                }
                project.notifyListeners();
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Icon(Icons.threed_rotation, color: Colors.white70, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text("Drag to Orbit", style: TextStyle(color: Colors.white54, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
