import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class TransformGizmo extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;
  final Size canvasSize;

  const TransformGizmo({
    super.key,
    required this.layer,
    required this.project,
    required this.canvasSize,
  });

  @override
  State<TransformGizmo> createState() => _TransformGizmoState();
}

class _TransformGizmoState extends State<TransformGizmo> {
  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final time = widget.project.playheadTime;

    final px = layer.posX.evaluate(time);
    final py = layer.posY.evaluate(time);
    final pz = layer.posZ.evaluate(time);
    final sx = layer.scaleX.evaluate(time);
    final sy = layer.scaleY.evaluate(time);
    final rz = layer.rotZ.evaluate(time);

    // Bounding box size
    final boxW = 160.0 * sx;
    final boxH = 90.0 * sy;

    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(px, py, pz)
          ..rotateZ(rz * math.pi / 180.0),
        child: SizedBox(
          width: boxW,
          height: boxH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bounding outline
              GestureDetector(
                onPanUpdate: (details) {
                  final newX = px + details.delta.dx;
                  final newY = py + details.delta.dy;
                  if (layer.posX.hasKeyframeAt(time)) {
                    layer.posX.addOrUpdateKeyframe(layer.posX.getKeyframeAt(time)!.copyWith(value: newX));
                  } else {
                    layer.posX.defaultValue = newX;
                  }
                  if (layer.posY.hasKeyframeAt(time)) {
                    layer.posY.addOrUpdateKeyframe(layer.posY.getKeyframeAt(time)!.copyWith(value: newY));
                  } else {
                    layer.posY.defaultValue = newY;
                  }
                  widget.project.notifyListeners();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                    color: Colors.transparent,
                  ),
                ),
              ),

              // Corner Scale Handle (Top-Left)
              Positioned(
                left: -6,
                top: -6,
                child: _buildHandle(Colors.white, (delta) {
                  _updateScale(-delta.dx, -delta.dy, sx, sy, time);
                }),
              ),

              // Corner Scale Handle (Bottom-Right)
              Positioned(
                right: -6,
                bottom: -6,
                child: _buildHandle(Colors.white, (delta) {
                  _updateScale(delta.dx, delta.dy, sx, sy, time);
                }),
              ),

              // Rotation Knob (Top Center)
              Positioned(
                left: (boxW / 2) - 8,
                top: -28,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newRot = rz + details.delta.dx * 0.8;
                    if (layer.rotZ.hasKeyframeAt(time)) {
                      layer.rotZ.addOrUpdateKeyframe(layer.rotZ.getKeyframeAt(time)!.copyWith(value: newRot));
                    } else {
                      layer.rotZ.defaultValue = newRot;
                    }
                    widget.project.notifyListeners();
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.refresh, size: 10, color: Colors.black),
                      ),
                      Container(width: 1.5, height: 12, color: const Color(0xFF00E5FF)),
                    ],
                  ),
                ),
              ),

              // 3D XYZ Gizmo Overlay (if layer is in 3D mode)
              if (layer.is3D)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _Axis3DPainter(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateScale(double dx, double dy, double curSx, double curSy, double time) {
    final layer = widget.layer;
    final factor = 1.0 + (dx + dy) * 0.01;
    final newScale = (curSx * factor).clamp(0.1, 10.0);

    if (layer.scaleX.hasKeyframeAt(time)) {
      layer.scaleX.addOrUpdateKeyframe(layer.scaleX.getKeyframeAt(time)!.copyWith(value: newScale));
      layer.scaleY.addOrUpdateKeyframe(layer.scaleY.getKeyframeAt(time)!.copyWith(value: newScale));
    } else {
      layer.scaleX.defaultValue = newScale;
      layer.scaleY.defaultValue = newScale;
    }
    widget.project.notifyListeners();
  }

  Widget _buildHandle(Color color, Function(Offset) onPan) {
    return GestureDetector(
      onPanUpdate: (d) => onPan(d.delta),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}

class _Axis3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // X Axis (Red)
    canvas.drawLine(
      center,
      center + const Offset(40, 0),
      Paint()..color = const Color(0xFFFF1744)..strokeWidth = 2.0,
    );

    // Y Axis (Green)
    canvas.drawLine(
      center,
      center + const Offset(0, -40),
      Paint()..color = const Color(0xFF00E676)..strokeWidth = 2.0,
    );

    // Z Axis (Blue Depth)
    canvas.drawLine(
      center,
      center + const Offset(-25, 25),
      Paint()..color = const Color(0xFF2979FF)..strokeWidth = 2.0,
    );

    // Center Anchor dot
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
