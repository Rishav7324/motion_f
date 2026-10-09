import 'package:flutter/material.dart';
import 'keyframe.dart';

enum LayerType {
  video,
  audio,
  text,
  nullObject,
  camera,
  adjustment,
}

enum LayerBlendMode {
  normal,
  screen,
  multiply,
  overlay,
  add,
  softLight,
}

enum TrackMatteType {
  none,
  alpha,
  alphaInverted,
  luma,
  lumaInverted,
}

enum MaskType {
  none,
  rectangle,
  ellipse,
  linear,
}

enum TransitionType {
  none,
  fade,
  dissolve,
  crossZoom,
  glitch,
  flashWhite,
  flashBlack,
  wipeLeft,
  wipeRight,
  whipPan,
}

class LayerItem {
  final String id;
  String name;
  final LayerType type;
  String? parentId; // ID of Null Object or parent layer

  double startTime; // in seconds
  double duration;  // in seconds
  int trackIndex;

  bool is3D;
  bool isVisible;
  bool isLocked;
  LayerBlendMode blendMode;

  // Track Matte (After Effects TrkMat)
  TrackMatteType trackMatte;
  String? targetMatteLayerId;

  // Vector Masks
  MaskType maskType;
  double maskCenterX;
  double maskCenterY;
  double maskSizeX;
  double maskSizeY;
  double maskFeather;
  bool isMaskInverted;

  // Effects & Color Grading
  bool motionBlurEnabled;
  int motionBlurSamples;
  double chromaticAberration; // 0.0 to 0.05
  double brightness;          // -1.0 to 1.0 (default 0.0)
  double contrast;            // 0.0 to 2.0 (default 1.0)
  double saturation;          // 0.0 to 2.0 (default 1.0)
  double temperature;         // -1.0 to 1.0 (default 0.0)
  double vignette;            // 0.0 to 1.0 (default 0.0)

  // 3D LUT & Professional Color Grading Studio
  String lutPreset;           // "None", "Teal & Orange", "Cyberpunk", "Kodachrome", etc.
  double lutIntensity;        // 0.0 to 1.0 (default 1.0)
  double exposure;            // -2.0 to 2.0 (default 0.0)
  double highlights;          // -1.0 to 1.0 (default 0.0)
  double shadows;             // -1.0 to 1.0 (default 0.0)
  double vibrance;            // -1.0 to 1.0 (default 0.0)
  double tint;                // -1.0 to 1.0 (default 0.0)
  double sharpen;             // 0.0 to 1.0 (default 0.0)

  // Motion Dynamics / AE Wiggle & Camera Shake
  bool shakeEnabled;
  double shakeFrequency;      // Hz (default 3.0)
  double shakeAmplitude;      // px (default 15.0)
  double shakeRotation;       // deg (default 2.0)
  String shakePreset;         // "Handheld", "Impact", "Earthquake", "Jitter", "Pulse"

  // Beat Detection Markers & Reverse Playback
  List<double> beatMarkers;   // Timestamps of rhythmic beats
  bool isReversed;            // Reverse video/audio playback

  // Chroma Key / Green Screen Removal
  bool chromaKeyEnabled;
  Color chromaKeyColor;
  double chromaSimilarity;  // 0.0 to 1.0 (threshold)
  double chromaSmoothness;  // 0.0 to 1.0 (feather)
  double chromaSpill;       // 0.0 to 1.0 (spill reduction)

  // CapCut Speed Ramping & Time Remapping
  double speed;
  bool isCurveSpeed;
  String curveSpeedPreset; // "Standard", "Montage", "Hero", "Bullet", "Jump Cut"

  // Audio Envelope & Ducking
  double volume; // 0.0 to 2.0 (1.0 = 100%)
  double fadeInDuration;
  double fadeOutDuration;
  bool audioDuckingEnabled;
  double audioDuckingAmount; // 0.0 to 1.0 (default 0.5)
  String voiceEffectPreset;  // "None", "Studio Mic", "Deep Voice", "Bass Boost", etc.

  // CapCut Transitions (In / Out)
  TransitionType transitionIn;
  double transitionInDuration;
  TransitionType transitionOut;
  double transitionOutDuration;

  // Typography & Text Styling (CapCut / After Effects style)
  double fontSize;
  Color textColor;
  bool hasTextStroke;
  Color textStrokeColor;
  double textStrokeWidth;
  bool hasTextShadow;
  Color textShadowColor;
  double textShadowBlur;
  bool hasTextBackground;
  Color textBackgroundColor;
  double textLetterSpacing;
  String textFontFamily;

  // Animatable Transform Properties
  final AnimatableProperty posX;
  final AnimatableProperty posY;
  final AnimatableProperty posZ;

  final AnimatableProperty scaleX;
  final AnimatableProperty scaleY;
  final AnimatableProperty scaleZ;

  final AnimatableProperty rotX; // Pitch (deg)
  final AnimatableProperty rotY; // Yaw (deg)
  final AnimatableProperty rotZ; // Roll (deg)

  final AnimatableProperty opacity;

  // Camera specific
  final AnimatableProperty cameraFov;
  final AnimatableProperty cameraZoom;
  final AnimatableProperty targetX;
  final AnimatableProperty targetY;
  final AnimatableProperty targetZ;

  // Media & Style
  String? mediaPath;
  String textContent;
  Color layerColor;

  LayerItem({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.startTime = 0.0,
    this.duration = 5.0,
    this.trackIndex = 0,
    this.is3D = false,
    this.isVisible = true,
    this.isLocked = false,
    this.blendMode = LayerBlendMode.normal,
    this.trackMatte = TrackMatteType.none,
    this.targetMatteLayerId,
    this.maskType = MaskType.none,
    this.maskCenterX = 0.5,
    this.maskCenterY = 0.5,
    this.maskSizeX = 0.35,
    this.maskSizeY = 0.35,
    this.maskFeather = 0.05,
    this.isMaskInverted = false,
    this.motionBlurEnabled = false,
    this.motionBlurSamples = 8,
    this.chromaticAberration = 0.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.temperature = 0.0,
    this.vignette = 0.0,
    this.lutPreset = "None",
    this.lutIntensity = 1.0,
    this.exposure = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.vibrance = 0.0,
    this.tint = 0.0,
    this.sharpen = 0.0,
    this.shakeEnabled = false,
    this.shakeFrequency = 3.0,
    this.shakeAmplitude = 15.0,
    this.shakeRotation = 2.0,
    this.shakePreset = "Handheld",
    List<double>? beatMarkers,
    this.isReversed = false,
    this.chromaKeyEnabled = false,
    this.chromaKeyColor = const Color(0xFF00FF00), // Default green screen
    this.chromaSimilarity = 0.4,
    this.chromaSmoothness = 0.1,
    this.chromaSpill = 0.5,
    this.speed = 1.0,
    this.isCurveSpeed = false,
    this.curveSpeedPreset = "Standard",
    this.volume = 1.0,
    this.fadeInDuration = 0.0,
    this.fadeOutDuration = 0.0,
    this.audioDuckingEnabled = false,
    this.audioDuckingAmount = 0.5,
    this.voiceEffectPreset = "None",
    this.transitionIn = TransitionType.none,
    this.transitionInDuration = 0.5,
    this.transitionOut = TransitionType.none,
    this.transitionOutDuration = 0.5,
    this.fontSize = 28.0,
    this.textColor = Colors.white,
    this.hasTextStroke = false,
    this.textStrokeColor = Colors.black,
    this.textStrokeWidth = 2.0,
    this.hasTextShadow = true,
    this.textShadowColor = const Color(0xFF00E5FF),
    this.textShadowBlur = 15.0,
    this.hasTextBackground = false,
    this.textBackgroundColor = const Color(0x88000000),
    this.textLetterSpacing = 2.0,
    this.textFontFamily = "sans-serif",
    this.mediaPath,
    this.textContent = "MotionF Text",
    Color? layerColor,
    double initialX = 0.0,
    double initialY = 0.0,
    double initialZ = 0.0,
    double initialScale = 1.0,
    double initialRotZ = 0.0,
  })  : layerColor = layerColor ?? _getDefaultColor(type),
        beatMarkers = beatMarkers ?? [],
        posX = AnimatableProperty(name: "Position X", defaultValue: initialX),
        posY = AnimatableProperty(name: "Position Y", defaultValue: initialY),
        posZ = AnimatableProperty(name: "Position Z", defaultValue: initialZ),
        scaleX = AnimatableProperty(name: "Scale X", defaultValue: initialScale),
        scaleY = AnimatableProperty(name: "Scale Y", defaultValue: initialScale),
        scaleZ = AnimatableProperty(name: "Scale Z", defaultValue: 1.0),
        rotX = AnimatableProperty(name: "Rotation X", defaultValue: 0.0),
        rotY = AnimatableProperty(name: "Rotation Y", defaultValue: 0.0),
        rotZ = AnimatableProperty(name: "Rotation Z", defaultValue: initialRotZ),
        opacity = AnimatableProperty(name: "Opacity", defaultValue: 1.0),
        cameraFov = AnimatableProperty(name: "Camera FOV", defaultValue: 45.0),
        cameraZoom = AnimatableProperty(name: "Camera Zoom", defaultValue: 1.0),
        targetX = AnimatableProperty(name: "Target X", defaultValue: 0.0),
        targetY = AnimatableProperty(name: "Target Y", defaultValue: 0.0),
        targetZ = AnimatableProperty(name: "Target Z", defaultValue: 0.0);

  static Color _getDefaultColor(LayerType type) {
    switch (type) {
      case LayerType.video:
        return const Color(0xFF2979FF); // Bright Blue
      case LayerType.audio:
        return const Color(0xFF00E676); // Bright Green
      case LayerType.text:
        return const Color(0xFFFF9100); // Amber Orange
      case LayerType.nullObject:
        return const Color(0xFFFF1744); // Red indicator
      case LayerType.camera:
        return const Color(0xFFD500F9); // Electric Purple
      case LayerType.adjustment:
        return const Color(0xFF00E5FF); // Cyan
    }
  }

  void trimStart(double newStart) {
    if (newStart < 0) newStart = 0;
    final currentEnd = startTime + duration;
    if (newStart < currentEnd - 0.2) {
      final delta = newStart - startTime;
      startTime = newStart;
      duration -= delta;
    }
  }

  void trimEnd(double newEnd) {
    if (newEnd > startTime + 0.2) {
      duration = newEnd - startTime;
    }
  }

  bool hasKeyframeAt(double time) {
    return posX.hasKeyframeAt(time) ||
        posY.hasKeyframeAt(time) ||
        posZ.hasKeyframeAt(time) ||
        scaleX.hasKeyframeAt(time) ||
        scaleY.hasKeyframeAt(time) ||
        rotZ.hasKeyframeAt(time) ||
        opacity.hasKeyframeAt(time);
  }

  List<double> getAllKeyframeTimes() {
    final Set<double> times = {};
    for (final p in [posX, posY, posZ, scaleX, scaleY, rotZ, opacity]) {
      for (final k in p.keyframes) {
        times.add(double.parse(k.time.toStringAsFixed(2)));
      }
    }
    final sorted = times.toList()..sort();
    return sorted;
  }
}
