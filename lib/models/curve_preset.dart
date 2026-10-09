class CurvePreset {
  final String name;
  final String description;
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const CurvePreset({
    required this.name,
    required this.description,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  static const linear = CurvePreset(
    name: "Linear",
    description: "Constant velocity",
    x1: 0.0,
    y1: 0.0,
    x2: 1.0,
    y2: 1.0,
  );

  static const easeIn = CurvePreset(
    name: "Ease In",
    description: "Slow start, fast finish",
    x1: 0.42,
    y1: 0.0,
    x2: 1.0,
    y2: 1.0,
  );

  static const easeOut = CurvePreset(
    name: "Ease Out",
    description: "Fast start, smooth stop",
    x1: 0.0,
    y1: 0.0,
    x2: 0.58,
    y2: 1.0,
  );

  static const easyEase = CurvePreset(
    name: "Easy Ease",
    description: "Smooth start and finish",
    x1: 0.42,
    y1: 0.0,
    x2: 0.58,
    y2: 1.0,
  );

  static const bullet = CurvePreset(
    name: "Bullet",
    description: "High speed punch",
    x1: 0.8,
    y1: 0.0,
    x2: 0.2,
    y2: 1.0,
  );

  static const flashIn = CurvePreset(
    name: "Flash In",
    description: "Instant snap acceleration",
    x1: 0.9,
    y1: 0.1,
    x2: 0.1,
    y2: 0.9,
  );

  static const jumpCut = CurvePreset(
    name: "Jump Cut",
    description: "Immediate step change",
    x1: 0.0,
    y1: 1.0,
    x2: 0.0,
    y2: 1.0,
  );

  static const List<CurvePreset> allPresets = [
    linear,
    easeIn,
    easeOut,
    easyEase,
    bullet,
    flashIn,
    jumpCut,
  ];
}
