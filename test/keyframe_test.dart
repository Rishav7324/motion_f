import 'package:flutter_test/flutter_test.dart';
import 'package:motion_f/models/keyframe.dart';
import 'package:motion_f/models/curve_preset.dart';

void main() {
  group('Keyframe & AnimatableProperty Tests', () {
    test('Default value when no keyframes exist', () {
      final prop = AnimatableProperty(name: "Opacity", defaultValue: 1.0);
      expect(prop.evaluate(0.0), equals(1.0));
      expect(prop.evaluate(5.0), equals(1.0));
    });

    test('Single keyframe clamps value across time', () {
      final prop = AnimatableProperty(name: "Scale", defaultValue: 1.0);
      prop.addOrUpdateKeyframe(Keyframe(time: 2.0, value: 2.5));

      expect(prop.evaluate(0.0), equals(2.5));
      expect(prop.evaluate(5.0), equals(2.5));
    });

    test('Two keyframes with linear interpolation', () {
      final prop = AnimatableProperty(name: "Position X", defaultValue: 0.0);
      final kf1 = Keyframe(time: 0.0, value: 0.0)..applyPreset(CurvePreset.linear);
      final kf2 = Keyframe(time: 2.0, value: 100.0)..applyPreset(CurvePreset.linear);

      prop.addOrUpdateKeyframe(kf1);
      prop.addOrUpdateKeyframe(kf2);

      expect(prop.evaluate(0.0), equals(0.0));
      expect(prop.evaluate(1.0), closeTo(50.0, 0.5));
      expect(prop.evaluate(2.0), equals(100.0));
    });

    test('Keyframe removal works accurately', () {
      final prop = AnimatableProperty(name: "Rotation Z", defaultValue: 0.0);
      prop.addOrUpdateKeyframe(Keyframe(time: 1.0, value: 45.0));
      expect(prop.hasKeyframeAt(1.0), isTrue);

      prop.removeKeyframeAt(1.0);
      expect(prop.hasKeyframeAt(1.0), isFalse);
    });
  });
}
