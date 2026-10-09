import 'package:flutter/material.dart';
import 'layer.dart';
import 'keyframe.dart';

enum CanvasAspectRatio {
  vertical9_16,
  landscape16_9,
  square1_1,
}

class ProjectModel extends ChangeNotifier {
  String name;
  CanvasAspectRatio aspectRatio;
  int fps;
  double duration; // total composition duration in seconds
  double playheadTime; // current time in seconds
  bool isPlaying;
  String? selectedLayerId;

  final List<LayerItem> layers = [];

  ProjectModel({
    this.name = "MotionF Project",
    this.aspectRatio = CanvasAspectRatio.vertical9_16,
    this.fps = 30,
    this.duration = 15.0,
    this.playheadTime = 0.0,
    this.isPlaying = false,
  }) {
    _initDemoLayers();
  }

  int get canvasWidth {
    switch (aspectRatio) {
      case CanvasAspectRatio.vertical9_16:
        return 1080;
      case CanvasAspectRatio.landscape16_9:
        return 1920;
      case CanvasAspectRatio.square1_1:
        return 1080;
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
    }
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
    notifyListeners();
  }

  void removeLayer(String id) {
    layers.removeWhere((l) => l.id == id);
    // Clear parenting references
    for (final l in layers) {
      if (l.parentId == id) l.parentId = null;
    }
    if (selectedLayerId == id) selectedLayerId = null;
    notifyListeners();
  }

  void setParent(String childId, String? parentId) {
    final child = layers.firstWhere((l) => l.id == childId);
    child.parentId = parentId;
    notifyListeners();
  }

  void toggleKeyframeAtCurrentTime(AnimatableProperty property, double value) {
    if (property.hasKeyframeAt(playheadTime)) {
      property.removeKeyframeAt(playheadTime);
    } else {
      property.addOrUpdateKeyframe(Keyframe(time: playheadTime, value: value));
    }
    notifyListeners();
  }

  void splitSelectedLayer() {
    final layer = selectedLayer;
    if (layer == null) return;
    if (playheadTime <= layer.startTime || playheadTime >= layer.startTime + layer.duration) return;

    final originalDuration = layer.duration;
    final splitOffset = playheadTime - layer.startTime;

    layer.duration = splitOffset;

    final newLayer = LayerItem(
      id: "layer_${DateTime.now().millisecondsSinceEpoch}",
      name: "${layer.name} (Split)",
      type: layer.type,
      startTime: playheadTime,
      duration: originalDuration - splitOffset,
      trackIndex: layer.trackIndex,
      is3D: layer.is3D,
      parentId: layer.parentId,
      mediaPath: layer.mediaPath,
      textContent: layer.textContent,
      layerColor: layer.layerColor,
      initialX: layer.posX.evaluate(playheadTime),
      initialY: layer.posY.evaluate(playheadTime),
      initialScale: layer.scaleX.evaluate(playheadTime),
      initialRotZ: layer.rotZ.evaluate(playheadTime),
    );

    layers.add(newLayer);
    selectedLayerId = newLayer.id;
    notifyListeners();
  }

  void _initDemoLayers() {
    // 1. Background Video Clip
    layers.add(LayerItem(
      id: "clip_video_1",
      name: "Main Clip (Video)",
      type: LayerType.video,
      startTime: 0.0,
      duration: 10.0,
      trackIndex: 0,
    ));

    // 2. Null Object Controller Layer (After Effects signature tool)
    final nullLayer = LayerItem(
      id: "null_ctrl_1",
      name: "Null 1 (3D Controller)",
      type: LayerType.nullObject,
      startTime: 0.0,
      duration: 12.0,
      trackIndex: 1,
      is3D: true,
    );
    nullLayer.posX.addOrUpdateKeyframe(Keyframe(time: 0.0, value: 0.0));
    nullLayer.posX.addOrUpdateKeyframe(Keyframe(time: 3.0, value: 150.0, cp1x: 0.8, cp1y: 0.0, cp2x: 0.2, cp2y: 1.0));
    nullLayer.rotZ.addOrUpdateKeyframe(Keyframe(time: 0.0, value: 0.0));
    nullLayer.rotZ.addOrUpdateKeyframe(Keyframe(time: 3.0, value: 45.0));
    layers.add(nullLayer);

    // 3. Motion Title Text parented to Null 1
    final textLayer = LayerItem(
      id: "title_text_1",
      name: "MotionF Title",
      type: LayerType.text,
      parentId: "null_ctrl_1", // PARENTED TO NULL OBJECT!
      startTime: 1.0,
      duration: 8.0,
      trackIndex: 2,
      is3D: true,
      textContent: "MOTION CRAFT",
      initialScale: 1.2,
    );
    textLayer.scaleX.addOrUpdateKeyframe(Keyframe(time: 1.0, value: 0.2));
    textLayer.scaleX.addOrUpdateKeyframe(Keyframe(time: 2.2, value: 1.2, cp1x: 0.42, cp1y: 0.0, cp2x: 0.1, cp2y: 1.2)); // bounce curve!
    textLayer.scaleY.addOrUpdateKeyframe(Keyframe(time: 1.0, value: 0.2));
    textLayer.scaleY.addOrUpdateKeyframe(Keyframe(time: 2.2, value: 1.2, cp1x: 0.42, cp1y: 0.0, cp2x: 0.1, cp2y: 1.2));
    layers.add(textLayer);

    // 4. 3D Camera Layer
    layers.add(LayerItem(
      id: "camera_main",
      name: "3D Camera 1",
      type: LayerType.camera,
      startTime: 0.0,
      duration: 15.0,
      trackIndex: 3,
      is3D: true,
    ));

    selectedLayerId = "title_text_1";
  }
}
