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
  bool isSnappingEnabled;
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
    this.isSnappingEnabled = true,
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

  void toggleSnapping() {
    isSnappingEnabled = !isSnappingEnabled;
    notifyListeners();
  }

  void stepFrame(int frames) {
    final frameDuration = 1.0 / (fps > 0 ? fps : 30);
    setPlayheadTime(playheadTime + frames * frameDuration);
  }

  double snapTime(double targetTime, {double threshold = 0.12}) {
    if (!isSnappingEnabled) return targetTime;

    double closest = targetTime;
    double minDiff = threshold;

    // 1. Snap to start/end of project
    if ((targetTime - 0.0).abs() < minDiff) {
      closest = 0.0;
      minDiff = (targetTime - 0.0).abs();
    }
    if ((targetTime - duration).abs() < minDiff) {
      closest = duration;
      minDiff = (targetTime - duration).abs();
    }

    // 2. Snap to all layer boundaries
    for (final l in layers) {
      final startDiff = (targetTime - l.startTime).abs();
      if (startDiff < minDiff) {
        minDiff = startDiff;
        closest = l.startTime;
      }
      final endDiff = (targetTime - (l.startTime + l.duration)).abs();
      if (endDiff < minDiff) {
        minDiff = endDiff;
        closest = l.startTime + l.duration;
      }
      // Snap to beat markers on audio tracks
      for (final bm in l.beatMarkers) {
        final bDiff = (targetTime - (l.startTime + bm)).abs();
        if (bDiff < minDiff) {
          minDiff = bDiff;
          closest = l.startTime + bm;
        }
      }
    }

    return closest;
  }

  void freezeFrame() {
    final layer = selectedLayer;
    if (layer == null || layer.type != LayerType.video) return;

    if (playheadTime <= layer.startTime || playheadTime >= layer.startTime + layer.duration) {
      return;
    }

    final splitOffset = playheadTime - layer.startTime;
    final remainingDuration = layer.duration - splitOffset;
    const freezeDuration = 2.0;

    // Truncate left part
    layer.duration = splitOffset;

    // Create 2.0s freeze segment (speed = 0.0)
    final freezeLayer = LayerItem(
      id: "freeze_${DateTime.now().millisecondsSinceEpoch}",
      name: "${layer.name} [Freeze]",
      type: LayerType.video,
      startTime: playheadTime,
      duration: freezeDuration,
      trackIndex: layer.trackIndex,
      is3D: layer.is3D,
      speed: 0.0,
      layerColor: const Color(0xFF00E5FF),
      mediaPath: layer.mediaPath,
    );

    // Create right continuation shifted by freezeDuration
    final rightPart = LayerItem(
      id: "layer_${DateTime.now().millisecondsSinceEpoch + 1}",
      name: "${layer.name} (Part 2)",
      type: LayerType.video,
      startTime: playheadTime + freezeDuration,
      duration: remainingDuration,
      trackIndex: layer.trackIndex,
      is3D: layer.is3D,
      speed: layer.speed,
      layerColor: layer.layerColor,
      mediaPath: layer.mediaPath,
    );

    layers.add(freezeLayer);
    layers.add(rightPart);
    selectedLayerId = freezeLayer.id;
    duration += freezeDuration;
    lastModified = DateTime.now();
    notifyListeners();
  }

  void extractAudio() {
    final layer = selectedLayer;
    if (layer == null || layer.type != LayerType.video) return;

    final audioLayer = LayerItem(
      id: "audio_extracted_${DateTime.now().millisecondsSinceEpoch}",
      name: "${layer.name} (Audio)",
      type: LayerType.audio,
      startTime: layer.startTime,
      duration: layer.duration,
      trackIndex: (layer.trackIndex + 1) % 4,
      layerColor: const Color(0xFF00E676),
      mediaPath: layer.mediaPath,
    );

    layers.add(audioLayer);
    selectedLayerId = audioLayer.id;
    lastModified = DateTime.now();
    notifyListeners();
  }

  void reverseSelectedLayer() {
    final layer = selectedLayer;
    if (layer == null) return;
    layer.isReversed = !layer.isReversed;
    lastModified = DateTime.now();
    notifyListeners();
  }

  void addBeatMarker(double time) {
    // Add to selected layer if audio, or first audio layer
    LayerItem? audioTarget = selectedLayer?.type == LayerType.audio ? selectedLayer : null;
    audioTarget ??= layers.where((l) => l.type == LayerType.audio).firstOrNull;

    if (audioTarget != null) {
      final localTime = (time - audioTarget.startTime).clamp(0.0, audioTarget.duration);
      if (!audioTarget.beatMarkers.any((b) => (b - localTime).abs() < 0.05)) {
        audioTarget.beatMarkers.add(localTime);
        audioTarget.beatMarkers.sort();
        lastModified = DateTime.now();
        notifyListeners();
      }
    }
  }

  void generateAutoBeats({bool fastBeats = false}) {
    LayerItem? audioTarget = selectedLayer?.type == LayerType.audio ? selectedLayer : null;
    audioTarget ??= layers.where((l) => l.type == LayerType.audio).firstOrNull;

    if (audioTarget != null) {
      audioTarget.beatMarkers.clear();
      final interval = fastBeats ? 0.45 : 0.90; // Standard rhythm intervals
      for (double t = interval; t < audioTarget.duration; t += interval) {
        audioTarget.beatMarkers.add(t);
      }
      lastModified = DateTime.now();
      notifyListeners();
    }
  }

  void clearBeatMarkers() {
    LayerItem? audioTarget = selectedLayer?.type == LayerType.audio ? selectedLayer : null;
    audioTarget ??= layers.where((l) => l.type == LayerType.audio).firstOrNull;

    if (audioTarget != null) {
      audioTarget.beatMarkers.clear();
      lastModified = DateTime.now();
      notifyListeners();
    }
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

  Future<bool> importMediaFile({bool allowMultiple = true}) async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: allowMultiple,
        );
      } catch (e) {
        debugPrint("FilePicker.any failed: $e, falling back to FileType.media");
        result = await FilePicker.platform.pickFiles(
          type: FileType.media,
          allowMultiple: allowMultiple,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        double currentInsertTime = playheadTime;

        for (final file in result.files) {
          if (file.path == null) continue;
          final path = file.path!;
          final name = file.name;
          final ext = name.split('.').last.toLowerCase();

          final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'wma'].contains(ext);
          final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);

          final lType = isAudio ? LayerType.audio : LayerType.video;
          final track = isAudio ? 1 : 0;
          final durationSeconds = isImage ? 4.0 : 8.0;

          final newLayer = LayerItem(
            id: "media_${DateTime.now().millisecondsSinceEpoch}_${layers.length}",
            name: name,
            type: lType,
            mediaPath: path,
            startTime: currentInsertTime,
            duration: durationSeconds,
            trackIndex: track,
            layerColor: isAudio
                ? const Color(0xFF00E676)
                : (isImage ? const Color(0xFFFF9100) : const Color(0xFF2979FF)),
          );

          addLayer(newLayer);
          selectedLayerId = newLayer.id;

          if (!isAudio) {
            currentInsertTime += durationSeconds;
          }

          if (newLayer.startTime + newLayer.duration > duration) {
            duration = newLayer.startTime + newLayer.duration + 2.0;
          }
        }

        lastModified = DateTime.now();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("File picking cancelled or error: $e");
    }
    return false;
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
    // Start with empty project list so user has full control (no fake demo projects)
    activeProject = ProjectModel(
      name: "New Project",
      aspectRatio: CanvasAspectRatio.vertical9_16,
      fps: 30,
      duration: 15.0,
      lastModified: DateTime.now(),
    );
  }

  Future<ProjectModel?> createProjectFromMedia() async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: true,
        );
      } catch (e) {
        debugPrint("FilePicker.any error: $e, falling back to FileType.media");
        result = await FilePicker.platform.pickFiles(
          type: FileType.media,
          allowMultiple: true,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final now = DateTime.now();
        final name = "Motion_${now.month}${now.day}_${now.hour}${now.minute}";
        final newProj = createNewProject(
          name: name,
          aspectRatio: CanvasAspectRatio.vertical9_16,
          fps: 30,
          duration: 15.0,
        );

        double currentInsertTime = 0.0;
        for (final file in result.files) {
          if (file.path == null) continue;
          final path = file.path!;
          final fname = file.name;
          final ext = fname.split('.').last.toLowerCase();

          final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'wma'].contains(ext);
          final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);

          final lType = isAudio ? LayerType.audio : LayerType.video;
          final track = isAudio ? 1 : 0;
          final durationSeconds = isImage ? 4.0 : 8.0;

          final layer = LayerItem(
            id: "media_${DateTime.now().millisecondsSinceEpoch}_${newProj.layers.length}",
            name: fname,
            type: lType,
            mediaPath: path,
            startTime: currentInsertTime,
            duration: durationSeconds,
            trackIndex: track,
            layerColor: isAudio
                ? const Color(0xFF00E676)
                : (isImage ? const Color(0xFFFF9100) : const Color(0xFF2979FF)),
          );

          newProj.addLayer(layer);
          newProj.selectedLayerId = layer.id;

          if (!isAudio) {
            currentInsertTime += durationSeconds;
          }
        }

        if (currentInsertTime + 2.0 > newProj.duration) {
          newProj.duration = currentInsertTime + 2.0;
        }

        newProj.notifyListeners();
        notifyListeners();
        return newProj;
      }
    } catch (e) {
      debugPrint("createProjectFromMedia error: $e");
    }
    return null;
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
          lutPreset: l.lutPreset,
          lutIntensity: l.lutIntensity,
          exposure: l.exposure,
          highlights: l.highlights,
          shadows: l.shadows,
          vibrance: l.vibrance,
          tint: l.tint,
          sharpen: l.sharpen,
          shakeEnabled: l.shakeEnabled,
          shakeFrequency: l.shakeFrequency,
          shakeAmplitude: l.shakeAmplitude,
          shakeRotation: l.shakeRotation,
          shakePreset: l.shakePreset,
          beatMarkers: List.from(l.beatMarkers),
          isReversed: l.isReversed,
          audioDuckingEnabled: l.audioDuckingEnabled,
          audioDuckingAmount: l.audioDuckingAmount,
          voiceEffectPreset: l.voiceEffectPreset,
        ));
      }
      projects.insert(0, clone);
      notifyListeners();
    } catch (_) {}
  }

  void deleteProject(String id) {
    projects.removeWhere((p) => p.id == id);
    if (activeProject.id == id) {
      if (projects.isNotEmpty) {
        activeProject = projects.first;
      } else {
        activeProject = ProjectModel(
          name: "New Project",
          aspectRatio: CanvasAspectRatio.vertical9_16,
          fps: 30,
          duration: 15.0,
          lastModified: DateTime.now(),
        );
      }
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
