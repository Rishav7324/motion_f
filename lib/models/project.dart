import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'layer.dart';
import 'keyframe.dart';

enum CanvasAspectRatio {
  vertical9_16,  // 9:16 (TikTok, Shorts, Reels)
  landscape16_9, // 16:9 (YouTube)
  square1_1,     // 1:1 (Instagram Post)
  ratio4_5,      // 4:5 (Instagram Portrait)
  ratio21_9,     // 21:9 (Cinematic Ultrawide)
}

class ProjectModel extends ChangeNotifier {
  final String id;
  String name;
  CanvasAspectRatio aspectRatio;
  int fps;
  double duration; // total composition duration in seconds
  double playheadTime; // current time in seconds
  bool isPlaying;
  String? selectedLayerId;
  DateTime lastModified;

  final List<LayerItem> layers = [];

  ProjectModel({
    String? id,
    this.name = "MotionF Project",
    this.aspectRatio = CanvasAspectRatio.vertical9_16,
    this.fps = 30,
    this.duration = 15.0,
    this.playheadTime = 0.0,
    this.isPlaying = false,
    DateTime? lastModified,
  })  : id = id ?? "proj_${DateTime.now().millisecondsSinceEpoch}",
        lastModified = lastModified ?? DateTime.now();

  int get canvasWidth {
    switch (aspectRatio) {
      case CanvasAspectRatio.vertical9_16:
        return 1080;
      case CanvasAspectRatio.landscape16_9:
        return 1920;
      case CanvasAspectRatio.square1_1:
        return 1080;
      case CanvasAspectRatio.ratio4_5:
        return 1080;
      case CanvasAspectRatio.ratio21_9:
        return 2560;
    }
  }

  int get canvasHeight {
    switch (aspectRatio) {
      case CanvasAspectRatio.vertical9_16:
        return 1920;
      case CanvasAspectRatio.landscape16_9:
        return 1080;
      case CanvasAspectRatio.square1_1:
        return 1080;
      case CanvasAspectRatio.ratio4_5:
        return 1350;
      case CanvasAspectRatio.ratio21_9:
        return 1080;
    }
  }

  double get aspectRatioValue {
    return canvasWidth / canvasHeight;
  }

  LayerItem? get selectedLayer {
    if (selectedLayerId == null) return null;
    try {
      return layers.firstWhere((l) => l.id == selectedLayerId);
    } catch (_) {
      return null;
    }
  }

  LayerItem? get activeCameraLayer {
    try {
      return layers.firstWhere((l) => l.type == LayerType.camera && l.isVisible);
    } catch (_) {
      return null;
    }
  }

  void selectLayer(String? id) {
    selectedLayerId = id;
    notifyListeners();
  }

  void setPlayheadTime(double time) {
    playheadTime = time.clamp(0.0, duration);
    notifyListeners();
  }

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void addLayer(LayerItem layer) {
    layers.add(layer);
    selectedLayerId = layer.id;
    lastModified = DateTime.now();
    notifyListeners();
  }

  void removeLayer(String id) {
    layers.removeWhere((l) => l.id == id);
    if (selectedLayerId == id) selectedLayerId = null;
    lastModified = DateTime.now();
    notifyListeners();
  }

  void setParent(String layerId, String? parentId) {
    try {
      final layer = layers.firstWhere((l) => l.id == layerId);
      layer.parentId = parentId;
      lastModified = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }

  void splitSelectedLayer() {
    final layer = selectedLayer;
    if (layer == null) return;

    if (playheadTime <= layer.startTime || playheadTime >= layer.startTime + layer.duration) {
      return;
    }

    final originalDuration = layer.duration;
    final splitOffset = playheadTime - layer.startTime;

    layer.duration = splitOffset;

    final rightPart = LayerItem(
      id: "layer_${DateTime.now().millisecondsSinceEpoch}",
      name: "${layer.name} (Part 2)",
      type: layer.type,
      startTime: playheadTime,
      duration: originalDuration - splitOffset,
      trackIndex: layer.trackIndex,
      is3D: layer.is3D,
      parentId: layer.parentId,
      textContent: layer.textContent,
      layerColor: layer.layerColor,
      maskType: layer.maskType,
      trackMatte: layer.trackMatte,
      targetMatteLayerId: layer.targetMatteLayerId,
      motionBlurEnabled: layer.motionBlurEnabled,
      chromaticAberration: layer.chromaticAberration,
      brightness: layer.brightness,
      contrast: layer.contrast,
      saturation: layer.saturation,
      temperature: layer.temperature,
      vignette: layer.vignette,
      chromaKeyEnabled: layer.chromaKeyEnabled,
      chromaKeyColor: layer.chromaKeyColor,
      speed: layer.speed,
    );

    layers.add(rightPart);
    selectedLayerId = rightPart.id;
    lastModified = DateTime.now();
    notifyListeners();
  }

  void trimSelectedStart(double newStart) {
    final layer = selectedLayer;
    if (layer == null) return;
    layer.trimStart(newStart);
    lastModified = DateTime.now();
    notifyListeners();
  }

  void trimSelectedEnd(double newEnd) {
    final layer = selectedLayer;
    if (layer == null) return;
    layer.trimEnd(newEnd);
    lastModified = DateTime.now();
    notifyListeners();
  }

  Future<void> importMediaFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'mkv', 'avi', 'mp3', 'wav', 'aac', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        final ext = name.split('.').last.toLowerCase();

        LayerType lType = LayerType.video;
        int track = 0;
        if (['mp3', 'wav', 'aac', 'm4a'].contains(ext)) {
          lType = LayerType.audio;
          track = 1;
        }

        final newLayer = LayerItem(
          id: "media_${DateTime.now().millisecondsSinceEpoch}",
          name: name,
          type: lType,
          mediaPath: path,
          startTime: playheadTime,
          duration: 8.0,
          trackIndex: track,
        );

        addLayer(newLayer);
      }
    } catch (e) {
      debugPrint("File picking cancelled or error: $e");
    }
  }

  void populateDemoLayers() {
    layers.clear();

    // 1. Background Video Clip
    layers.add(LayerItem(
      id: "bg_video_1",
      name: "Cyberpunk City.mp4",
      type: LayerType.video,
      startTime: 0.0,
      duration: 10.0,
      trackIndex: 0,
    ));

    // 2. Audio BGM Track
    layers.add(LayerItem(
      id: "bgm_audio_1",
      name: "Synthwave Beat.mp3",
      type: LayerType.audio,
      startTime: 0.0,
      duration: 12.0,
      trackIndex: 1,
      layerColor: const Color(0xFF00E676),
    ));

    // 3. Null Controller (3D parent for title)
    final nullLayer = LayerItem(
      id: "null_ctrl_1",
      name: "Null 1 [Controller]",
      type: LayerType.nullObject,
      startTime: 0.0,
      duration: 10.0,
      trackIndex: 2,
      is3D: true,
      initialX: 0.0,
      initialY: 0.0,
    );
    nullLayer.posX.addKeyframe(Keyframe(time: 0.0, value: -120.0, easeType: KeyframeEase.easeOut));
    nullLayer.posX.addKeyframe(Keyframe(time: 2.5, value: 0.0, easeType: KeyframeEase.easeInOut));
    nullLayer.rotZ.addKeyframe(Keyframe(time: 0.0, value: -15.0, easeType: KeyframeEase.easeOut));
    nullLayer.rotZ.addKeyframe(Keyframe(time: 2.0, value: 0.0, easeType: KeyframeEase.easeInOut));
    layers.add(nullLayer);

    // 4. Kinetic Typography Title parented to Null
    final textLayer = LayerItem(
      id: "title_text_1",
      name: "MotionF Neon Title",
      type: LayerType.text,
      startTime: 0.5,
      duration: 8.0,
      trackIndex: 3,
      is3D: true,
      parentId: nullLayer.id,
      textContent: "MOTION F",
      fontSize: 34.0,
      textColor: const Color(0xFF00E5FF),
      hasTextShadow: true,
      textShadowColor: const Color(0xFF00E5FF),
      textShadowBlur: 20.0,
    );
    textLayer.scaleX.addKeyframe(Keyframe(time: 0.5, value: 0.2, easeType: KeyframeEase.easeOut));
    textLayer.scaleX.addKeyframe(Keyframe(time: 1.8, value: 1.0, easeType: KeyframeEase.easeInOut));
    textLayer.scaleY.addKeyframe(Keyframe(time: 0.5, value: 0.2, easeType: KeyframeEase.easeOut));
    textLayer.scaleY.addKeyframe(Keyframe(time: 1.8, value: 1.0, easeType: KeyframeEase.easeInOut));
    textLayer.opacity.addKeyframe(Keyframe(time: 0.5, value: 0.0, easeType: KeyframeEase.linear));
    textLayer.opacity.addKeyframe(Keyframe(time: 1.2, value: 1.0, easeType: KeyframeEase.linear));
    layers.add(textLayer);

    // 5. 3D Camera Layer
    final camera = LayerItem(
      id: "cam_main",
      name: "3D Camera 1 (50mm)",
      type: LayerType.camera,
      startTime: 0.0,
      duration: 15.0,
      trackIndex: 4,
      is3D: true,
      initialZ: -800.0,
    );
    camera.posZ.addKeyframe(Keyframe(time: 0.0, value: -1200.0, easeType: KeyframeEase.easeOut));
    camera.posZ.addKeyframe(Keyframe(time: 3.5, value: -700.0, easeType: KeyframeEase.easeInOut));
    layers.add(camera);

    selectedLayerId = textLayer.id;
  }
}

/// Project Manager singleton / provider storing all user projects
class ProjectManager extends ChangeNotifier {
  final List<ProjectModel> projects = [];
  late ProjectModel activeProject;

  ProjectManager() {
    _initDefaultProjects();
  }

  void _initDefaultProjects() {
    // Project 1: Cyberpunk 3D Camera Intro
    final p1 = ProjectModel(
      name: "Cyberpunk 3D Camera",
      aspectRatio: CanvasAspectRatio.vertical9_16,
      fps: 60,
      duration: 15.0,
      lastModified: DateTime.now().subtract(const Duration(minutes: 15)),
    );
    p1.populateDemoLayers();
    projects.add(p1);

    // Project 2: Cinematic Vlog Montage
    final p2 = ProjectModel(
      name: "Cinematic Travel Vlog",
      aspectRatio: CanvasAspectRatio.landscape16_9,
      fps: 30,
      duration: 30.0,
      lastModified: DateTime.now().subtract(const Duration(hours: 3)),
    );
    p2.layers.add(LayerItem(
      id: "vlog_video",
      name: "Golden Hour Ocean.mp4",
      type: LayerType.video,
      startTime: 0.0,
      duration: 15.0,
      trackIndex: 0,
      vignette: 0.4,
      temperature: 0.3,
    ));
    p2.layers.add(LayerItem(
      id: "vlog_bgm",
      name: "Acoustic Melody.mp3",
      type: LayerType.audio,
      startTime: 0.0,
      duration: 20.0,
      trackIndex: 1,
      layerColor: const Color(0xFF00E676),
    ));
    projects.add(p2);

    // Project 3: Reels Kinetic Typography
    final p3 = ProjectModel(
      name: "Reels Kinetic Promo",
      aspectRatio: CanvasAspectRatio.vertical9_16,
      fps: 60,
      duration: 10.0,
      lastModified: DateTime.now().subtract(const Duration(days: 1)),
    );
    p3.layers.add(LayerItem(
      id: "promo_text",
      name: "Big Hook Text",
      type: LayerType.text,
      startTime: 0.0,
      duration: 5.0,
      trackIndex: 0,
      textContent: "CREATE MAGIC",
      fontSize: 32.0,
      textColor: const Color(0xFFFFD600),
      hasTextStroke: true,
      textStrokeWidth: 3.0,
    ));
    projects.add(p3);

    activeProject = p1;
  }

  void openProject(ProjectModel project) {
    activeProject = project;
    notifyListeners();
  }

  ProjectModel createNewProject({
    required String name,
    required CanvasAspectRatio aspectRatio,
    required int fps,
    double duration = 15.0,
  }) {
    final newProj = ProjectModel(
      name: name,
      aspectRatio: aspectRatio,
      fps: fps,
      duration: duration,
      lastModified: DateTime.now(),
    );
    newProj.populateDemoLayers();
    projects.insert(0, newProj);
    activeProject = newProj;
    notifyListeners();
    return newProj;
  }

  void duplicateProject(String id) {
    try {
      final original = projects.firstWhere((p) => p.id == id);
      final clone = ProjectModel(
        name: "${original.name} (Copy)",
        aspectRatio: original.aspectRatio,
        fps: original.fps,
        duration: original.duration,
        lastModified: DateTime.now(),
      );
      for (final l in original.layers) {
        clone.addLayer(LayerItem(
          id: "layer_${DateTime.now().millisecondsSinceEpoch}_${clone.layers.length}",
          name: l.name,
          type: l.type,
          startTime: l.startTime,
          duration: l.duration,
          trackIndex: l.trackIndex,
          is3D: l.is3D,
          textContent: l.textContent,
          layerColor: l.layerColor,
          maskType: l.maskType,
          trackMatte: l.trackMatte,
          chromaKeyEnabled: l.chromaKeyEnabled,
          speed: l.speed,
        ));
      }
      projects.insert(0, clone);
      notifyListeners();
    } catch (_) {}
  }

  void deleteProject(String id) {
    if (projects.length <= 1) return; // Keep at least one project
    projects.removeWhere((p) => p.id == id);
    if (activeProject.id == id) {
      activeProject = projects.first;
    }
    notifyListeners();
  }

  void renameProject(String id, String newName) {
    try {
      final p = projects.firstWhere((p) => p.id == id);
      p.name = newName;
      p.lastModified = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }
}
