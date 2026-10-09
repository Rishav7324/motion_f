import 'package:flutter_test/flutter_test.dart';
import 'package:motion_f/models/project.dart';
import 'package:motion_f/models/layer.dart';

void main() {
  group('ProjectManager & Multi-Project Tests', () {
    test('ProjectManager initializes with clean empty project state', () {
      final manager = ProjectManager();
      expect(manager.projects, isEmpty);
      expect(manager.activeProject, isNotNull);
    });

    test('Create, duplicate, rename, and delete project', () {
      final manager = ProjectManager();
      final initialCount = manager.projects.length;

      // 1. Create project
      final created = manager.createNewProject(
        name: "Test Reel",
        aspectRatio: CanvasAspectRatio.vertical9_16,
        fps: 60,
      );
      expect(manager.projects.length, initialCount + 1);
      expect(manager.activeProject.name, "Test Reel");

      // 2. Duplicate project
      manager.duplicateProject(created.id);
      expect(manager.projects.length, initialCount + 2);
      expect(manager.projects.first.name, "Test Reel (Copy)");

      // 3. Rename project
      manager.renameProject(created.id, "Renamed Reel");
      expect(created.name, "Renamed Reel");

      // 4. Delete project
      manager.deleteProject(created.id);
      expect(manager.projects.any((p) => p.id == created.id), isFalse);
    });

    test('Aspect Ratio resolution checks', () {
      final p1 = ProjectModel(aspectRatio: CanvasAspectRatio.vertical9_16);
      expect(p1.canvasWidth, 1080);
      expect(p1.canvasHeight, 1920);

      final p2 = ProjectModel(aspectRatio: CanvasAspectRatio.landscape16_9);
      expect(p2.canvasWidth, 1920);
      expect(p2.canvasHeight, 1080);

      final p3 = ProjectModel(aspectRatio: CanvasAspectRatio.ratio21_9);
      expect(p3.canvasWidth, 2560);
      expect(p3.canvasHeight, 1080);
    });

    test('setParent sets and clears parentId on layer', () {
      final project = ProjectModel();
      final l1 = LayerItem(id: "parent_1", name: "Null Parent", type: LayerType.nullObject);
      final l2 = LayerItem(id: "child_1", name: "Text Child", type: LayerType.text);
      project.addLayer(l1);
      project.addLayer(l2);

      project.setParent("child_1", "parent_1");
      expect(l2.parentId, "parent_1");

      project.setParent("child_1", null);
      expect(l2.parentId, isNull);
    });
  });

  group('Chroma Key, Speed Ramping, and Trimming Tests', () {
    test('Chroma key configuration on layer', () {
      final layer = LayerItem(
        id: "l_chroma",
        name: "Green Screen Actor",
        type: LayerType.video,
        chromaKeyEnabled: true,
        chromaSimilarity: 0.45,
        chromaSmoothness: 0.15,
        chromaSpill: 0.6,
      );

      expect(layer.chromaKeyEnabled, isTrue);
      expect(layer.chromaSimilarity, 0.45);
      expect(layer.chromaSmoothness, 0.15);
      expect(layer.chromaSpill, 0.6);
    });

    test('Speed ramping configuration on layer', () {
      final layer = LayerItem(
        id: "l_speed",
        name: "Montage Clip",
        type: LayerType.video,
        speed: 2.5,
        isCurveSpeed: true,
        curveSpeedPreset: "Bullet Time",
      );

      expect(layer.speed, 2.5);
      expect(layer.isCurveSpeed, isTrue);
      expect(layer.curveSpeedPreset, "Bullet Time");
    });

    test('Interactive trimming methods', () {
      final layer = LayerItem(
        id: "l_trim",
        name: "Trimmable Clip",
        type: LayerType.video,
        startTime: 2.0,
        duration: 8.0,
      );

      // Trim start from 2.0 to 4.0
      layer.trimStart(4.0);
      expect(layer.startTime, 4.0);
      expect(layer.duration, 6.0); // original end 10.0, so duration is now 6.0

      // Trim end from 10.0 to 8.0
      layer.trimEnd(8.0);
      expect(layer.duration, 4.0); // 8.0 - 4.0 = 4.0
    });
  });
}
