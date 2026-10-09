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
    this.mediaPath,
    this.textContent = "MotionF Text",
    Color? layerColor,
    double initialX = 0.0,
    double initialY = 0.0,
    double initialZ = 0.0,
    double initialScale = 1.0,
    double initialRotZ = 0.0,
  })  : layerColor = layerColor ?? _getDefaultColor(type),
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
