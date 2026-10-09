import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:motion_f/models/project.dart';
import 'package:motion_f/models/layer.dart';

void main() {
  group('Cinematic 3D LUT & Color Grading Tests', () {
    test('LUT presets and master adjust parameters on layer', () {
      final layer = LayerItem(
        id: "lut_test",
        name: "Cinematic Shot",
        type: LayerType.video,
        lutPreset: "Teal & Orange",
        lutIntensity: 0.85,
        exposure: 0.3,
        highlights: -0.2,
        shadows: 0.15,
        vibrance: 0.4,
        tint: -0.1,
        sharpen: 0.25,
      );

      expect(layer.lutPreset, "Teal & Orange");
      expect(layer.lutIntensity, 0.85);
      expect(layer.exposure, 0.3);
      expect(layer.highlights, -0.2);
      expect(layer.shadows, 0.15);
      expect(layer.vibrance, 0.4);
      expect(layer.tint, -0.1);
      expect(layer.sharpen, 0.25);
    });

    test('Blend modes and opacity configuration', () {
      final layer = LayerItem(
        id: "blend_test",
        name: "Light Leak Overlay",
        type: LayerType.video,
        blendMode: LayerBlendMode.screen,
      );

      expect(layer.blendMode, LayerBlendMode.screen);
      layer.blendMode = LayerBlendMode.overlay;
      expect(layer.blendMode, LayerBlendMode.overlay);
    });
  });

  group('Procedural Dynamics & Camera Shake Tests', () {
    test('Camera shake configuration on layer', () {
      final layer = LayerItem(
        id: "shake_test",
        name: "Explosion Impact",
        type: LayerType.video,
        shakeEnabled: true,
        shakeFrequency: 8.5,
        shakeAmplitude: 45.0,
        shakeRotation: 5.0,
        shakePreset: "Action Impact",
      );

      expect(layer.shakeEnabled, isTrue);
      expect(layer.shakeFrequency, 8.5);
      expect(layer.shakeAmplitude, 45.0);
      expect(layer.shakeRotation, 5.0);
      expect(layer.shakePreset, "Action Impact");
    });
  });

  group('Beat Detection & Audio Sync Tests', () {
    test('Manual beat marker addition and clear', () {
      final project = ProjectModel();
      final audioLayer = LayerItem(
        id: "bgm_track",
        name: "BGM Track",
        type: LayerType.audio,
        startTime: 0.0,
        duration: 10.0,
      );
      project.addLayer(audioLayer);

      expect(audioLayer.beatMarkers, isEmpty);

      // Add beats at 1.5s, 3.0s, 4.5s
      project.addBeatMarker(1.5);
      project.addBeatMarker(3.0);
      project.addBeatMarker(4.5);

      expect(audioLayer.beatMarkers.length, 3);
      expect(audioLayer.beatMarkers[0], 1.5);
      expect(audioLayer.beatMarkers[1], 3.0);
      expect(audioLayer.beatMarkers[2], 4.5);

      // Clear beats
      project.clearBeatMarkers();
      expect(audioLayer.beatMarkers, isEmpty);
    });

    test('Auto beats generation', () {
      final project = ProjectModel();
      final audioLayer = LayerItem(
        id: "bgm_track",
        name: "BGM Track",
        type: LayerType.audio,
        startTime: 0.0,
        duration: 5.0,
      );
      project.addLayer(audioLayer);

      // Standard beats (~0.9s interval)
      project.generateAutoBeats(fastBeats: false);
      expect(audioLayer.beatMarkers.isNotEmpty, isTrue);
      final countSlow = audioLayer.beatMarkers.length;

      // Fast beats (~0.45s interval)
      project.generateAutoBeats(fastBeats: true);
      expect(audioLayer.beatMarkers.length, greaterThan(countSlow));
    });

    test('Audio ducking and voice equalizer settings', () {
      final audioLayer = LayerItem(
        id: "bgm_duck",
        name: "Background Music",
        type: LayerType.audio,
        audioDuckingEnabled: true,
        audioDuckingAmount: 0.65,
        voiceEffectPreset: "Studio Mic",
      );

      expect(audioLayer.audioDuckingEnabled, isTrue);
      expect(audioLayer.audioDuckingAmount, 0.65);
      expect(audioLayer.voiceEffectPreset, "Studio Mic");
    });
  });

  group('Timeline Magnetic Snapping Tests', () {
    test('snapTime snaps to clip boundaries and beat markers within threshold', () {
      final project = ProjectModel(duration: 20.0);
      final videoLayer = LayerItem(
        id: "vid_1",
        name: "Clip 1",
        type: LayerType.video,
        startTime: 2.0,
        duration: 4.0, // Ends at 6.0
      );
      final audioLayer = LayerItem(
        id: "aud_1",
        name: "Beat Track",
        type: LayerType.audio,
        startTime: 0.0,
        duration: 10.0,
        beatMarkers: [3.5, 7.0],
      );
      project.addLayer(videoLayer);
      project.addLayer(audioLayer);

      // Near clip start (2.0s): at 2.05s, snaps to 2.0s
      expect(project.snapTime(2.05), 2.0);

      // Near clip end (6.0s): at 5.95s, snaps to 6.0s
      expect(project.snapTime(5.95), 6.0);

      // Near beat marker (3.5s): at 3.52s, snaps to 3.5s
      expect(project.snapTime(3.52), 3.5);

      // Far away from boundaries (e.g. 4.2s), does not snap
      expect(project.snapTime(4.2), 4.2);

      // When snapping is disabled, targetTime is unaltered
      project.toggleSnapping();
      expect(project.snapTime(2.05), 2.05);
    });

    test('Step frame updates playhead by frame increment', () {
      final project = ProjectModel(fps: 30, playheadTime: 1.0);
      project.stepFrame(1);
      expect(project.playheadTime, closeTo(1.0 + (1.0 / 30.0), 0.001));

      project.stepFrame(-2);
      expect(project.playheadTime, closeTo(1.0 - (1.0 / 30.0), 0.001));
    });
  });

  group('Quick Actions (Freeze, Extract Audio, Reverse) Tests', () {
    test('freezeFrame creates a 2.0s freeze layer from video', () {
      final project = ProjectModel();
      final video = LayerItem(
        id: "freeze_source",
        name: "Skate Jump",
        type: LayerType.video,
        startTime: 0.0,
        duration: 6.0,
      );
      project.addLayer(video);
      project.selectLayer(video.id);

      // Place playhead at 2.5s
      project.setPlayheadTime(2.5);
      project.freezeFrame();

      // Original video duration truncated to 2.5s
      expect(video.duration, 2.5);

      // Freeze layer added
      final freezeLayer = project.layers.firstWhere((l) => l.name.contains("[Freeze]"));
      expect(freezeLayer.startTime, 2.5);
      expect(freezeLayer.duration, 2.0);
      expect(freezeLayer.speed, 0.0);

      // Part 2 continuation shifted to 4.5s
      final part2 = project.layers.firstWhere((l) => l.name.contains("(Part 2)"));
      expect(part2.startTime, 4.5);
      expect(part2.duration, 3.5);
    });

    test('extractAudio creates independent audio layer from video', () {
      final project = ProjectModel();
      final video = LayerItem(
        id: "vid_source",
        name: "Interview Clip",
        type: LayerType.video,
        startTime: 1.0,
        duration: 8.0,
      );
      project.addLayer(video);
      project.selectLayer(video.id);

      project.extractAudio();

      final audioLayer = project.layers.firstWhere((l) => l.name == "Interview Clip (Audio)");
      expect(audioLayer.type, LayerType.audio);
      expect(audioLayer.startTime, 1.0);
      expect(audioLayer.duration, 8.0);
    });

    test('reverseSelectedLayer toggles isReversed flag', () {
      final project = ProjectModel();
      final video = LayerItem(
        id: "rev_source",
        name: "Rewind Clip",
        type: LayerType.video,
      );
      project.addLayer(video);
      project.selectLayer(video.id);

      expect(video.isReversed, isFalse);
      project.reverseSelectedLayer();
      expect(video.isReversed, isTrue);
      project.reverseSelectedLayer();
      expect(video.isReversed, isFalse);
    });
  });
}
