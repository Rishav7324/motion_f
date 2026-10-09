import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/services.dart';

typedef MotionFEvaluateBezierC = ffi.Float Function(
    ffi.Float x1, ffi.Float y1, ffi.Float x2, ffi.Float y2, ffi.Float t);
typedef MotionFEvaluateBezierDart = double Function(
    double x1, double y1, double x2, double y2, double t);

typedef MotionFComputeTransformC = ffi.Void Function(
    ffi.Float px, ffi.Float py, ffi.Float pz,
    ffi.Float pitch, ffi.Float yaw, ffi.Float roll,
    ffi.Float sx, ffi.Float sy, ffi.Float sz,
    ffi.Float ax, ffi.Float ay, ffi.Float az,
    ffi.Pointer<ffi.Float> outMatrix16);
typedef MotionFComputeTransformDart = void Function(
    double px, double py, double pz,
    double pitch, double yaw, double roll,
    double sx, double sy, double sz,
    double ax, double ay, double az,
    ffi.Pointer<ffi.Float> outMatrix16);

class NativeEngineBridge {
  static const MethodChannel _channel = MethodChannel('com.motionf.app/engine');

  static late final ffi.DynamicLibrary _nativeLib;
  static MotionFEvaluateBezierDart? _evaluateBezierNative;
  static bool _nativeLibLoaded = false;

  static void init() {
    try {
      if (Platform.isAndroid) {
        _nativeLib = ffi.DynamicLibrary.open('libmotionf_engine.so');
        _evaluateBezierNative = _nativeLib
            .lookupFunction<MotionFEvaluateBezierC, MotionFEvaluateBezierDart>(
                'motionf_evaluate_bezier');
        _nativeLibLoaded = true;
      }
    } catch (_) {
      _nativeLibLoaded = false;
    }
  }

  static double evaluateBezier(
      double x1, double y1, double x2, double y2, double t) {
    if (_nativeLibLoaded && _evaluateBezierNative != null) {
      return _evaluateBezierNative!(x1, y1, x2, y2, t);
    }
    // Fallback to Dart implementation if native library is not yet loaded
    return _evaluateBezierDartFallback(x1, y1, x2, y2, t);
  }

  static Future<int?> initPreviewTexture(int width, int height) async {
    return await _channel.invokeMethod<int>('initPreviewTexture', {
      'width': width,
      'height': height,
    });
  }

  static Future<void> setParent(String childId, String parentId) async {
    await _channel.invokeMethod('setParent', {
      'childId': childId,
      'parentId': parentId,
    });
  }

  static Future<void> updateCamera({
    required double px,
    required double py,
    required double pz,
    required double tx,
    required double ty,
    required double tz,
    required double fov,
    required double zoom,
  }) async {
    await _channel.invokeMethod('updateCamera', {
      'px': px,
      'py': py,
      'pz': pz,
      'tx': tx,
      'ty': ty,
      'tz': tz,
      'fov': fov,
      'zoom': zoom,
    });
  }

  static Future<void> renderFrame() async {
    await _channel.invokeMethod('renderFrame');
  }

  static double _evaluateBezierDartFallback(
      double x1, double y1, double x2, double y2, double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    double u = t;
    for (int i = 0; i < 8; i++) {
      double curX = 3 * (1 - u) * (1 - u) * u * x1 + 3 * (1 - u) * u * u * x2 + u * u * u - t;
      if (curX.abs() < 1e-6) break;
      double dX = 3 * (1 - 3 * u + 3 * u * u) * x1 + 3 * (2 * u - 3 * u * u) * x2 + 3 * u * u;
      if (dX.abs() < 1e-6) break;
      u -= curX / dX;
    }
    return 3 * (1 - u) * (1 - u) * u * y1 + 3 * (1 - u) * u * u * y2 + u * u * u;
  }
}
