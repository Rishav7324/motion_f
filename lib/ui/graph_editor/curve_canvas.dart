import 'package:flutter/material.dart';
import '../../models/keyframe.dart';
import '../../engine/bezier_evaluator.dart';

class CurveCanvas extends StatefulWidget {
  final Keyframe keyframe;
  final Function(double x1, double y1, double x2, double y2) onCurveChanged;

  const CurveCanvas({
    super.key,
    required this.keyframe,
    required this.onCurveChanged,
  });

  @override
  State<CurveCanvas> createState() => _CurveCanvasState();
}

class _CurveCanvasState extends State<CurveCanvas> {
  int? _activeHandle; // 1 for P1, 2 for P2

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Coordinates in Canvas space
        // Start point: P0 = (0, h)
        // End point: P3 = (w, 0)
        final p0 = Offset(0, h);
        final p3 = Offset(w, 0);

        final p1 = Offset(widget.keyframe.cp1x * w, h - widget.keyframe.cp1y * h);
        final p2 = Offset(widget.keyframe.cp2x * w, h - widget.keyframe.cp2y * h);

        return GestureDetector(
          onPanDown: (details) {
            final touch = details.localPosition;
            if ((touch - p1).distance < 28) {
              _activeHandle = 1;
            } else if ((touch - p2).distance < 28) {
              _activeHandle = 2;
            } else {
              _activeHandle = null;
            }
          },
          onPanUpdate: (details) {
            if (_activeHandle == null) return;
            final local = details.localPosition;

            double nx = (local.dx / w).clamp(0.0, 1.0);
            double ny = (1.0 - (local.dy / h)).clamp(-0.5, 1.5);

            if (_activeHandle == 1) {
              widget.onCurveChanged(nx, ny, widget.keyframe.cp2x, widget.keyframe.cp2y);
            } else if (_activeHandle == 2) {
              widget.onCurveChanged(widget.keyframe.cp1x, widget.keyframe.cp1y, nx, ny);
            }
          },
          onPanEnd: (_) => _activeHandle = null,
          child: CustomPaint(
            size: Size(w, h),
            painter: _BezierGraphPainter(
              p0: p0,
              p1: p1,
              p2: p2,
              p3: p3,
              cp1x: widget.keyframe.cp1x,
              cp1y: widget.keyframe.cp1y,
              cp2x: widget.keyframe.cp2x,
              cp2y: widget.keyframe.cp2y,
            ),
          ),
        );
      },
    );
  }
}

class _BezierGraphPainter extends CustomPainter {
  final Offset p0, p1, p2, p3;
  final double cp1x, cp1y, cp2x, cp2y;

  _BezierGraphPainter({
    required this.p0,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.cp1x,
    required this.cp1y,
    required this.cp2x,
    required this.cp2y,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Grid lines
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      final x = size.width * (i / 4.0);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 2. Draw Tangent lines
    final tangentPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.5)
      ..strokeWidth = 1.5;

    canvas.drawLine(p0, p1, tangentPaint);
    canvas.drawLine(p3, p2, tangentPaint);

    // 3. Draw Bezier Curve (sampling 64 points)
    final curvePath = Path()..moveTo(p0.dx, p0.dy);
    for (int i = 1; i <= 64; i++) {
      final t = i / 64.0;
      final yNorm = BezierEvaluator.evaluate(cp1x, cp1y, cp2x, cp2y, t);
      final x = t * size.width;
      final y = size.height - yNorm * size.height;
      curvePath.lineTo(x, y);
    }

    final curvePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(curvePath, curvePaint);

    // 4. Draw Start & End keyframe dots
    final kfDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(p0, 4, kfDotPaint);
    canvas.drawCircle(p3, 4, kfDotPaint);

    // 5. Draw Tangent Control Handles (P1, P2)
    final handlePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    final handleBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(p1, 7, handlePaint);
    canvas.drawCircle(p1, 7, handleBorder);

    canvas.drawCircle(p2, 7, handlePaint);
    canvas.drawCircle(p2, 7, handleBorder);
  }

  @override
  bool shouldRepaint(covariant _BezierGraphPainter oldDelegate) {
    return oldDelegate.cp1x != cp1x ||
        oldDelegate.cp1y != cp1y ||
        oldDelegate.cp2x != cp2x ||
        oldDelegate.cp2y != cp2y;
  }
}
