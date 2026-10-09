import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import '../models/layer.dart';

class SceneHierarchySolver {
  static Matrix4 computeLocalMatrix(LayerItem layer, double time) {
    final px = layer.posX.evaluate(time);
    final py = layer.posY.evaluate(time);
    final pz = layer.posZ.evaluate(time);

    final sx = layer.scaleX.evaluate(time);
    final sy = layer.scaleY.evaluate(time);
    final sz = layer.scaleZ.evaluate(time);

    final rx = layer.rotX.evaluate(time) * math.pi / 180.0;
    final ry = layer.rotY.evaluate(time) * math.pi / 180.0;
    final rz = layer.rotZ.evaluate(time) * math.pi / 180.0;

    final m = Matrix4.identity();
    m.translate(px, py, pz);
    if (rz != 0.0) m.rotateZ(rz);
    if (ry != 0.0) m.rotateY(ry);
    if (rx != 0.0) m.rotateX(rx);
    m.scale(sx, sy, sz);

    return m;
  }

  static Matrix4 computeWorldMatrix(
      LayerItem layer, List<LayerItem> allLayers, double time,
      [int depth = 0]) {
    final localM = computeLocalMatrix(layer, time);

    if (layer.parentId == null || layer.parentId!.isEmpty || depth > 32) {
      return localM;
    }

    try {
      final parent = allLayers.firstWhere((l) => l.id == layer.parentId);
      final parentWorld = computeWorldMatrix(parent, allLayers, time, depth + 1);
      // World = Parent_World * Child_Local
      return parentWorld * localM;
    } catch (_) {
      return localM;
    }
  }

  static Matrix4 computeCameraViewMatrix(LayerItem camera, double time) {
    final cx = camera.posX.evaluate(time);
    final cy = camera.posY.evaluate(time);
    final cz = camera.posZ.evaluate(time) == 0.0 ? 1000.0 : camera.posZ.evaluate(time);

    final tx = camera.targetX.evaluate(time);
    final ty = camera.targetY.evaluate(time);
    final tz = camera.targetZ.evaluate(time);

    return makeViewMatrix(
      Vector3(cx, cy, cz),
      Vector3(tx, ty, tz),
      Vector3(0, 1, 0),
    );
  }

  static Matrix4 computeCameraProjectionMatrix(
      LayerItem camera, double time, double aspect) {
    final fovDeg = camera.cameraFov.evaluate(time);
    final zoom = camera.cameraZoom.evaluate(time);
    final effectiveFov = (fovDeg / (zoom <= 0 ? 1.0 : zoom)) * math.pi / 180.0;

    return makePerspectiveMatrix(
      effectiveFov.clamp(0.1, math.pi * 0.95),
      aspect,
      1.0,
      5000.0,
    );
  }

  static Matrix4 computeFinalRenderMatrix({
    required LayerItem layer,
    required List<LayerItem> allLayers,
    required LayerItem? camera,
    required double time,
    required double canvasAspect,
  }) {
    final worldM = computeWorldMatrix(layer, allLayers, time);

    if (layer.is3D && camera != null && camera.isVisible) {
      final viewM = computeCameraViewMatrix(camera, time);
      final projM = computeCameraProjectionMatrix(camera, time, canvasAspect);
      return projM * viewM * worldM;
    }

    return worldM;
  }
}
