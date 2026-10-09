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

    Widget content = _renderLayerContent(layer);
    content = _applyEffectsAndMask(layer, content);

    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: content,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_creation_outlined, size: 40, color: Colors.white70),
                const SizedBox(height: 4),
                Text(
                  layer.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );

      case LayerType.audio:
        return Container(
          width: 180,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.audiotrack, color: Colors.black87, size: 24),
                SizedBox(width: 6),
                Text("Audio Wave", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
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
        // Null objects are invisible in final render, but show red dashed cross in editor
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

  Widget _applyEffectsAndMask(LayerItem layer, Widget child) {
    Widget processed = child;

    // 1. Vector Mask
    if (layer.maskType != MaskType.none) {
      processed = ClipPath(
        clipper: LayerMaskClipper(
          type: layer.maskType,
          scaleX: layer.maskSizeX,
          scaleY: layer.maskSizeY,
          inverted: layer.isMaskInverted,
        ),
        child: processed,
      );
    }

    // 2. Chromatic Aberration
    if (layer.chromaticAberration > 0) {
      final shift = layer.chromaticAberration * 200.0;
      processed = Stack(
        alignment: Alignment.center,
        children: [
          // Red Channel Shift
          Transform.translate(
            offset: Offset(shift, 0),
            child: Opacity(
              opacity: 0.7,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.redAccent, BlendMode.modulate),
                child: child,
              ),
            ),
          ),
          // Cyan Channel Shift
          Transform.translate(
            offset: Offset(-shift, 0),
            child: Opacity(
              opacity: 0.7,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Color(0xFF00E5FF), BlendMode.modulate),
                child: child,
              ),
            ),
          ),
          // Center main
          processed,
        ],
      );
    }

    // 3. Color Grading (Brightness, Contrast, Saturation, Temperature)
    final hasColorGrading = layer.brightness != 0 ||
        layer.contrast != 1.0 ||
        layer.saturation != 1.0 ||
        layer.temperature != 0.0;

    if (hasColorGrading) {
      final matrix = _buildColorMatrix(
        brightness: layer.brightness,
        contrast: layer.contrast,
        saturation: layer.saturation,
        temperature: layer.temperature,
      );
      processed = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: processed,
      );
    }

    // 4. Vignette Overlay
    if (layer.vignette > 0) {
      processed = Stack(
        alignment: Alignment.center,
        children: [
          processed,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(layer.vignette.clamp(0.0, 0.9)),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return processed;
  }

  List<double> _buildColorMatrix({
    required double brightness,
    required double contrast,
    required double saturation,
    required double temperature,
  }) {
    final c = contrast;
    final b = brightness * 255.0;

    // Saturation luminance factors
    final lr = 0.2126 * (1.0 - saturation);
    final lg = 0.7152 * (1.0 - saturation);
    final lb = 0.0722 * (1.0 - saturation);

    // Color temperature warm/cool factors
    final tempR = temperature > 0 ? (temperature * 20.0) : 0.0;
    final tempB = temperature < 0 ? (temperature.abs() * 20.0) : 0.0;

    return <double>[
      (lr + saturation) * c, lg * c, lb * c, 0, b + tempR,
      lr * c, (lg + saturation) * c, lb * c, 0, b,
      lr * c, lg * c, (lb + saturation) * c, 0, b + tempB,
      0, 0, 0, 1, 0,
    ];
  }

  String _formatTime(double sec) {
    int m = (sec / 60).floor();
    int s = (sec % 60).floor();
    int ms = ((sec - sec.floor()) * 100).floor();
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}:${ms.toString().padLeft(2, '0')}";
  }
}

/// Custom Clipper for Vector Masks (Rectangle, Ellipse, Linear)
class LayerMaskClipper extends CustomClipper<Path> {
  final MaskType type;
  final double scaleX;
  final double scaleY;
  final bool inverted;

  LayerMaskClipper({
    required this.type,
    required this.scaleX,
    required this.scaleY,
    required this.inverted,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final maskWidth = size.width * scaleX.clamp(0.05, 1.0);
    final maskHeight = size.height * scaleY.clamp(0.05, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: maskWidth, height: maskHeight);

    if (type == MaskType.rectangle) {
      if (inverted) {
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
        path.fillType = PathFillType.evenOdd;
      } else {
        path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
      }
    } else if (type == MaskType.ellipse) {
      if (inverted) {
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        path.addOval(rect);
        path.fillType = PathFillType.evenOdd;
      } else {
        path.addOval(rect);
      }
    } else if (type == MaskType.linear) {
      // Linear half-split
      if (inverted) {
        path.addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
      } else {
        path.addRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height));
      }
    } else {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    return path;
  }

  @override
  bool shouldReclip(covariant LayerMaskClipper oldClipper) {
    return oldClipper.type != type ||
        oldClipper.scaleX != scaleX ||
        oldClipper.scaleY != scaleY ||
        oldClipper.inverted != inverted;
  }
}
