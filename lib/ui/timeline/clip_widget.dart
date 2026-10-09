import 'dart:math' as math;
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

    final hasEffects = layer.motionBlurEnabled ||
        layer.chromaticAberration > 0 ||
        layer.vignette > 0 ||
        layer.brightness != 0 ||
        layer.contrast != 1.0 ||
        layer.saturation != 1.0 ||
        layer.temperature != 0;

    return Positioned(
      left: left,
      top: 4,
      bottom: 4,
      width: math.max(width, 24.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Clip Body
          Positioned.fill(
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
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // 1. Procedural Background Texture: Waveform for Audio, Filmstrip for Video
                    if (layer.type == LayerType.audio)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: AudioWaveformPainter(
                            color: Colors.white.withOpacity(0.35),
                            activeColor: const Color(0xFF00E5FF).withOpacity(0.6),
                            progress: ((project.playheadTime - layer.startTime) / layer.duration).clamp(0.0, 1.0),
                          ),
                        ),
                      ),

                    if (layer.type == LayerType.video)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: FilmstripPainter(
                            color: Colors.black.withOpacity(0.2),
                            sprocketColor: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      ),

                    // 2. Clip Label & Feature Badges
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
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
                          const SizedBox(width: 6),

                          // Badges for Active Advanced Features
                          if (layer.is3D)
                            _buildMiniBadge("3D", const Color(0xFFD500F9)),

                          if (layer.maskType != MaskType.none)
                            _buildMiniBadge("MASK", const Color(0xFF00E5FF)),

                          if (layer.trackMatte != TrackMatteType.none)
                            _buildMiniBadge("MATTE", const Color(0xFFFFD600)),

                          if (hasEffects)
                            _buildMiniBadge("FX", const Color(0xFFFF4081)),

                          if (layer.chromaKeyEnabled)
                            _buildMiniBadge("CHROMA", const Color(0xFF00E676)),

                          if (layer.speed != 1.0 || layer.isCurveSpeed)
                            _buildMiniBadge("${layer.speed.toStringAsFixed(1)}x", const Color(0xFFFFD600)),

                          if (layer.transitionIn != TransitionType.none || layer.transitionOut != TransitionType.none)
                            _buildMiniBadge("TRANS", const Color(0xFF00E5FF)),
                        ],
                      ),
                    ),

                    // 3. Visual Keyframe Diamond Dots (After Effects / CapCut signature feature)
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
          ),

          // Interactive Trimming Drag Handles (CapCut style)
          if (isSelected) ...[
            // Left Trim Handle
            Positioned(
              left: -6,
              top: 0,
              bottom: 0,
              width: 14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final deltaTime = details.primaryDelta! / pixelsPerSecond;
                  project.trimSelectedStart(layer.startTime + deltaTime);
                },
                child: Center(
                  child: Container(
                    width: 10,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    child: const Center(
                      child: Icon(Icons.drag_handle, size: 10, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),

            // Right Trim Handle
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              width: 14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final deltaTime = details.primaryDelta! / pixelsPerSecond;
                  project.trimSelectedEnd(layer.startTime + layer.duration + deltaTime);
                },
                child: Center(
                  child: Container(
                    width: 10,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    child: const Center(
                      child: Icon(Icons.drag_handle, size: 10, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        border: Border.all(color: color, width: 0.8),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
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

/// Procedural Audio Waveform Painter for CapCut-style audio clips
class AudioWaveformPainter extends CustomPainter {
  final Color color;
  final Color activeColor;
  final double progress;

  AudioWaveformPainter({
    required this.color,
    required this.activeColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 2.0;
    final spacing = 1.5;
    final totalWidth = barWidth + spacing;
    final numBars = (size.width / totalWidth).floor();
    final midY = size.height / 2;

    final basePaint = Paint()..color = color;
    final activePaint = Paint()..color = activeColor;

    for (int i = 0; i < numBars; i++) {
      final x = i * totalWidth;
      // Deterministic synthetic waveform pattern
      final s1 = math.sin(i * 0.22);
      final s2 = math.cos(i * 0.08);
      final s3 = math.sin(i * 0.5);
      final normAmp = (s1.abs() * 0.5 + s2.abs() * 0.3 + s3.abs() * 0.2).clamp(0.15, 0.95);
      final barHeight = (size.height * 0.75) * normAmp;

      final isPastPlayhead = (x / size.width) <= progress;
      final paint = isPastPlayhead ? activePaint : basePaint;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x + barWidth / 2, midY), width: barWidth, height: barHeight),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Procedural Filmstrip Painter for Video clips with frame dividers and sprockets
class FilmstripPainter extends CustomPainter {
  final Color color;
  final Color sprocketColor;

  FilmstripPainter({
    required this.color,
    required this.sprocketColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = 48.0;
    final numFrames = (size.width / frameWidth).ceil();

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    final sprocketPaint = Paint()..color = sprocketColor;

    // Frame vertical divider lines
    for (int i = 1; i < numFrames; i++) {
      final x = i * frameWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Top and bottom subtle sprocket dots
    final numSprockets = (size.width / 14.0).floor();
    for (int i = 0; i < numSprockets; i++) {
      final x = i * 14.0 + 4;
      // Top sprocket
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 2, 5, 3), const Radius.circular(1)),
        sprocketPaint,
      );
      // Bottom sprocket
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - 5, 5, 3), const Radius.circular(1)),
        sprocketPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FilmstripPainter oldDelegate) => false;
}
