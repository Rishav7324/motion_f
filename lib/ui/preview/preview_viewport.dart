import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/layer.dart';
import '../../engine/scene_hierarchy.dart';
import 'transform_gizmo.dart';
import 'camera_orbit_gizmo.dart';

class PreviewViewport extends StatelessWidget {
  const PreviewViewport({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectModel>();
    final selectedLayer = project.selectedLayer;
    final cameraLayer = project.activeCameraLayer;

    // Viewport Aspect Ratio calculation
    double aspect = 9 / 16;
    if (project.aspectRatio == CanvasAspectRatio.landscape16_9) aspect = 16 / 9;
    if (project.aspectRatio == CanvasAspectRatio.square1_1) aspect = 1 / 1;

    return Center(
      child: AspectRatio(
        aspectRatio: aspect,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF141519),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 16, spreadRadius: 2),
            ],
            border: Border.all(color: Colors.white12, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Render all active layers from bottom to top
                  ...project.layers.where((l) => l.isVisible).map((layer) {
                    if (layer.type == LayerType.camera) {
                      return const SizedBox.shrink(); // Camera has no visual pixels
                    }
                    return _buildLayerWidget(layer, project, canvasSize);
                  }),

                  // 2. Interactive Transform Gizmo for selected layer
                  if (selectedLayer != null && selectedLayer.type != LayerType.camera)
                    TransformGizmo(
                      layer: selectedLayer,
                      project: project,
                      canvasSize: canvasSize,
                    ),

                  // 3. Camera Orbit Gizmo if 3D Camera layer is selected
                  if (selectedLayer != null && selectedLayer.type == LayerType.camera)
                    CameraOrbitGizmo(
                      camera: selectedLayer,
                      project: project,
                    ),

                  // 4. Timecode & Status HUD in Top-Left
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatTime(project.playheadTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLayerWidget(LayerItem layer, ProjectModel project, Size canvasSize) {
    final time = project.playheadTime;
    final camera = project.activeCameraLayer;

    // Check if layer is active at current time
    if (time < layer.startTime || time > layer.startTime + layer.duration) {
      return const SizedBox.shrink();
    }

    final matrix = SceneHierarchySolver.computeFinalRenderMatrix(
      layer: layer,
      allLayers: project.layers,
      camera: camera,
      time: time,
      canvasAspect: canvasSize.width / canvasSize.height,
    );

    final opacity = layer.opacity.evaluate(time).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: _renderLayerContent(layer),
          ),
        ),
      ),
    );
  }

  Widget _renderLayerContent(LayerItem layer) {
    switch (layer.type) {
      case LayerType.video:
        return Container(
          width: 220,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: const Center(
            child: Icon(Icons.movie_creation_outlined, size: 48, color: Colors.white70),
          ),
        );

      case LayerType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            layer.textContent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2)),
                Shadow(color: Color(0xFF00E5FF), blurRadius: 15),
              ],
            ),
          ),
        );

      case LayerType.nullObject:
        // Null objects are invisible in render, but show red dashed cross in editor
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF1744), width: 1.5),
            shape: BoxShape.rectangle,
          ),
          child: const Center(
            child: Icon(Icons.control_camera, color: Color(0xFFFF1744), size: 16),
          ),
        );

      case LayerType.adjustment:
        return Container(
          width: 200,
          height: 120,
          color: const Color(0x3300E5FF),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTime(double sec) {
    int m = (sec / 60).floor();
    int s = (sec % 60).floor();
    int ms = ((sec - sec.floor()) * 100).floor();
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}:${ms.toString().padLeft(2, '0')}";
  }
}
