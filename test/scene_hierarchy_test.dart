import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:motion_f/models/layer.dart';
import 'package:motion_f/engine/scene_hierarchy.dart';

void main() {
  group('SceneHierarchySolver & Parenting Tests', () {
    test('Local Matrix translation check', () {
      final layer = LayerItem(
        id: "l1",
        name: "Test Layer",
        type: LayerType.video,
        initialX: 100.0,
        initialY: 50.0,
      );

      final m = SceneHierarchySolver.computeLocalMatrix(layer, 0.0);
      final point = Vector3(0, 0, 0);
      final transformed = m.transform3(point);

      expect(transformed.x, closeTo(100.0, 0.001));
      expect(transformed.y, closeTo(50.0, 0.001));
    });

    test('Null Object Parenting translates child layer', () {
      // 1. Create Null parent at (200, 300)
      final nullParent = LayerItem(
        id: "null_1",
        name: "Null Parent",
        type: LayerType.nullObject,
        initialX: 200.0,
        initialY: 300.0,
      );

      // 2. Create child layer at (50, 20) parented to null_1
      final child = LayerItem(
        id: "child_1",
        name: "Child Layer",
        type: LayerType.text,
        parentId: "null_1",
        initialX: 50.0,
        initialY: 20.0,
      );

      final allLayers = [nullParent, child];

      final worldM = SceneHierarchySolver.computeWorldMatrix(child, allLayers, 0.0);
      final origin = Vector3(0, 0, 0);
      final worldPoint = worldM.transform3(origin);

      // Child World = Parent (200, 300) + Child (50, 20) = (250, 320)
      expect(worldPoint.x, closeTo(250.0, 0.001));
      expect(worldPoint.y, closeTo(320.0, 0.001));
    });

    test('3D Camera View Matrix generation', () {
      final camera = LayerItem(
        id: "cam_1",
        name: "Camera 1",
        type: LayerType.camera,
        initialX: 0.0,
        initialY: 0.0,
        initialZ: 1000.0,
      );

      final viewM = SceneHierarchySolver.computeCameraViewMatrix(camera, 0.0);
      expect(viewM, isNotNull);
      // Origin (0,0,0) in world space should be at Z = -1000 in camera view space
      final testP = Vector3(0, 0, 0);
      final inView = viewM.transform3(testP);
      expect(inView.z, closeTo(-1000.0, 1.0));
    });
  });
}
