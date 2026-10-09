import 'package:flutter_test/flutter_test.dart';
import 'package:motion_f/engine/bezier_evaluator.dart';
import 'package:motion_f/models/curve_preset.dart';

void main() {
  group('BezierEvaluator Math Tests', () {
    test('Boundary conditions at t=0 and t=1', () {
      expect(BezierEvaluator.evaluate(0.42, 0.0, 0.58, 1.0, 0.0), equals(0.0));
      expect(BezierEvaluator.evaluate(0.42, 0.0, 0.58, 1.0, 1.0), equals(1.0));
    });

    test('Linear curve progress', () {
      final preset = CurvePreset.linear;
      final val = BezierEvaluator.evaluate(preset.x1, preset.y1, preset.x2, preset.y2, 0.5);
      expect(val, closeTo(0.5, 0.01));
    });

    test('Ease In starts slower than linear', () {
      final preset = CurvePreset.easeIn;
      final val = BezierEvaluator.evaluate(preset.x1, preset.y1, preset.x2, preset.y2, 0.5);
      expect(val, lessThan(0.5));
    });

    test('Ease Out reaches higher progress earlier', () {
      final preset = CurvePreset.easeOut;
      final val = BezierEvaluator.evaluate(preset.x1, preset.y1, preset.x2, preset.y2, 0.5);
      expect(val, greaterThan(0.5));
    });

    test('Bullet curve produces aggressive acceleration', () {
      final preset = CurvePreset.bullet;
      final val = BezierEvaluator.evaluate(preset.x1, preset.y1, preset.x2, preset.y2, 0.3);
      expect(val, greaterThan(0.0));
      expect(val, lessThan(1.0));
    });
  });
}
