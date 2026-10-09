import 'curve_preset.dart';
import '../bridge/native_engine_bridge.dart';

enum KeyframeEase {
  linear,
  easeIn,
  easeOut,
  easeInOut,
}

class Keyframe {
  double time; // in seconds
  double value;
  double cp1x;
  double cp1y;
  double cp2x;
  double cp2y;

  Keyframe({
    required this.time,
    required this.value,
    this.cp1x = 0.42,
    this.cp1y = 0.0,
    this.cp2x = 0.58,
    this.cp2y = 1.0,
    KeyframeEase? easeType,
  }) {
    if (easeType != null) {
      switch (easeType) {
        case KeyframeEase.linear:
          cp1x = 0.0;
          cp1y = 0.0;
          cp2x = 1.0;
          cp2y = 1.0;
          break;
        case KeyframeEase.easeIn:
          cp1x = 0.42;
          cp1y = 0.0;
          cp2x = 1.0;
          cp2y = 1.0;
          break;
        case KeyframeEase.easeOut:
          cp1x = 0.0;
          cp1y = 0.0;
          cp2x = 0.58;
          cp2y = 1.0;
          break;
        case KeyframeEase.easeInOut:
          cp1x = 0.42;
          cp1y = 0.0;
          cp2x = 0.58;
          cp2y = 1.0;
          break;
      }
    }
  }

  void applyPreset(CurvePreset preset) {
    cp1x = preset.x1;
    cp1y = preset.y1;
    cp2x = preset.x2;
    cp2y = preset.y2;
  }

  Keyframe copyWith({
    double? time,
    double? value,
    double? cp1x,
    double? cp1y,
    double? cp2x,
    double? cp2y,
  }) {
    return Keyframe(
      time: time ?? this.time,
      value: value ?? this.value,
      cp1x: cp1x ?? this.cp1x,
      cp1y: cp1y ?? this.cp1y,
      cp2x: cp2x ?? this.cp2x,
      cp2y: cp2y ?? this.cp2y,
    );
  }
}

class AnimatableProperty {
  final String name;
  double defaultValue;
  final List<Keyframe> keyframes;

  AnimatableProperty({
    required this.name,
    required this.defaultValue,
    List<Keyframe>? keyframes,
  }) : keyframes = keyframes ?? [];

  bool get hasKeyframes => keyframes.isNotEmpty;

  void addOrUpdateKeyframe(Keyframe kf) {
    int index = keyframes.indexWhere((k) => (k.time - kf.time).abs() < 0.02);
    if (index >= 0) {
      keyframes[index] = kf;
    } else {
      keyframes.add(kf);
      keyframes.sort((a, b) => a.time.compareTo(b.time));
    }
  }

  void addKeyframe(Keyframe kf) => addOrUpdateKeyframe(kf);

  void removeKeyframeAt(double time) {
    keyframes.removeWhere((k) => (k.time - time).abs() < 0.05);
  }

  bool hasKeyframeAt(double time) {
    return keyframes.any((k) => (k.time - time).abs() < 0.05);
  }

  Keyframe? getKeyframeAt(double time) {
    try {
      return keyframes.firstWhere((k) => (k.time - time).abs() < 0.05);
    } catch (_) {
      return null;
    }
  }

  double evaluate(double time) {
    if (keyframes.isEmpty) return defaultValue;
    if (keyframes.length == 1 || time <= keyframes.first.time) {
      return keyframes.first.value;
    }
    if (time >= keyframes.last.time) {
      return keyframes.last.value;
    }

    // Find surrounding keyframes
    for (int i = 0; i < keyframes.length - 1; i++) {
      final k1 = keyframes[i];
      final k2 = keyframes[i + 1];
      if (time >= k1.time && time <= k2.time) {
        final duration = k2.time - k1.time;
        if (duration < 1e-5) return k1.value;
        final normalizedT = (time - k1.time) / duration;
        final progress = NativeEngineBridge.evaluateBezier(
          k1.cp1x, k1.cp1y, k1.cp2x, k1.cp2y, normalizedT,
        );
        return k1.value + progress * (k2.value - k1.value);
      }
    }
    return keyframes.last.value;
  }
}
