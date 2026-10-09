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

    double baseOpacity = layer.opacity.evaluate(time).clamp(0.0, 1.0);
    double transitionOpacity = 1.0;
    double transitionScale = 1.0;
    Offset transitionOffset = Offset.zero;

    // 1. In-Transition calculation
    final layerTime = time - layer.startTime;
    if (layer.transitionIn != TransitionType.none && layerTime < layer.transitionInDuration && layer.transitionInDuration > 0) {
      final t = (layerTime / layer.transitionInDuration).clamp(0.0, 1.0);
      switch (layer.transitionIn) {
        case TransitionType.fade:
        case TransitionType.dissolve:
          transitionOpacity *= t;
          break;
        case TransitionType.crossZoom:
          transitionScale *= (0.4 + 0.6 * t);
          transitionOpacity *= t;
          break;
        case TransitionType.wipeLeft:
          transitionOffset += Offset((1.0 - t) * 150, 0);
          break;
        case TransitionType.wipeRight:
          transitionOffset += Offset(-(1.0 - t) * 150, 0);
          break;
        default:
          break;
      }
    }

    // 2. Out-Transition calculation
    final remainingTime = (layer.startTime + layer.duration) - time;
    if (layer.transitionOut != TransitionType.none && remainingTime < layer.transitionOutDuration && layer.transitionOutDuration > 0) {
      final t = (remainingTime / layer.transitionOutDuration).clamp(0.0, 1.0);
      switch (layer.transitionOut) {
        case TransitionType.fade:
        case TransitionType.dissolve:
          transitionOpacity *= t;
          break;
        case TransitionType.crossZoom:
          transitionScale *= (0.4 + 0.6 * t);
          transitionOpacity *= t;
          break;
        case TransitionType.wipeLeft:
          transitionOffset += Offset(-(1.0 - t) * 150, 0);
          break;
        case TransitionType.wipeRight:
          transitionOffset += Offset((1.0 - t) * 150, 0);
          break;
        default:
          break;
      }
    }

    final finalOpacity = (baseOpacity * transitionOpacity).clamp(0.0, 1.0);

    Widget content = _renderLayerContent(layer);
    content = _applyEffectsAndMask(layer, content);

    if (transitionOffset != Offset.zero) {
      content = Transform.translate(offset: transitionOffset, child: content);
    }
    if (transitionScale != 1.0) {
      content = Transform.scale(scale: transitionScale, child: content);
    }

    return Positioned.fill(
      child: Opacity(
        opacity: finalOpacity,
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
        if (layer.chromaKeyEnabled) {
          return Container(
            width: 220,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00E676), width: 1.5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 40, color: Color(0xFF00E676)),
                  const SizedBox(height: 4),
                  Text(
                    "${layer.name} [KEYED]",
                    style: const TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
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
          decoration: layer.hasTextBackground
              ? BoxDecoration(
                  color: layer.textBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Stack(
            children: [
              if (layer.hasTextStroke)
                Text(
                  layer.textContent,
                  style: TextStyle(
                    fontSize: layer.fontSize,
                    letterSpacing: layer.textLetterSpacing,
                    fontFamily: layer.textFontFamily,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = layer.textStrokeWidth
                      ..color = layer.textStrokeColor,
                  ),
                ),
              Text(
                layer.textContent,
                style: TextStyle(
                  color: layer.textColor,
                  fontSize: layer.fontSize,
                  letterSpacing: layer.textLetterSpacing,
                  fontFamily: layer.textFontFamily,
                  fontWeight: FontWeight.w900,
                  shadows: layer.hasTextShadow
                      ? [
                          const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2)),
                          Shadow(color: layer.textShadowColor, blurRadius: layer.textShadowBlur),
                        ]
                      : null,
                ),
              ),
            ],
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
