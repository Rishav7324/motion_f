import 'package:flutter_test/flutter_test.dart';
import 'package:motion_f/models/layer.dart';
import 'package:motion_f/models/project.dart';

void main() {
  group('Masks & Track Matte Tests', () {
    test('Default layer initializes with no mask and no track matte', () {
      final layer = LayerItem(
        id: "l1",
        name: "Test Layer",
        type: LayerType.video,
      );

      expect(layer.maskType, MaskType.none);
      expect(layer.trackMatte, TrackMatteType.none);
      expect(layer.targetMatteLayerId, isNull);
      expect(layer.isMaskInverted, isFalse);
    });

    test('Vector mask parameters can be configured and inverted', () {
      final layer = LayerItem(
        id: "l2",
        name: "Masked Layer",
        type: LayerType.video,
        maskType: MaskType.rectangle,
        maskSizeX: 0.8,
        maskSizeY: 0.6,
        maskFeather: 0.1,
        isMaskInverted: true,
      );

      expect(layer.maskType, MaskType.rectangle);
      expect(layer.maskSizeX, 0.8);
      expect(layer.maskSizeY, 0.6);
      expect(layer.maskFeather, 0.1);
      expect(layer.isMaskInverted, isTrue);
    });

    test('Track Matte can be bound to target layer', () {
      final matteSource = LayerItem(
        id: "matte_source",
        name: "Stencil Shape",
        type: LayerType.text,
      );

      final targetLayer = LayerItem(
        id: "content_layer",
        name: "Video Content",
        type: LayerType.video,
        trackMatte: TrackMatteType.alpha,
        targetMatteLayerId: matteSource.id,
      );

      expect(targetLayer.trackMatte, TrackMatteType.alpha);
      expect(targetLayer.targetMatteLayerId, "matte_source");
    });
  });

  group('Effects & Color Grading Tests', () {
    test('Motion blur, chromatic aberration, and color grading properties', () {
      final layer = LayerItem(
        id: "fx_layer",
        name: "Effects Layer",
        type: LayerType.video,
        motionBlurEnabled: true,
        motionBlurSamples: 16,
        chromaticAberration: 0.03,
        brightness: 0.2,
        contrast: 1.3,
        saturation: 1.5,
        temperature: 0.4,
        vignette: 0.5,
      );

      expect(layer.motionBlurEnabled, isTrue);
      expect(layer.motionBlurSamples, 16);
      expect(layer.chromaticAberration, 0.03);
      expect(layer.brightness, 0.2);
      expect(layer.contrast, 1.3);
      expect(layer.saturation, 1.5);
      expect(layer.temperature, 0.4);
      expect(layer.vignette, 0.5);
    });
  });

  group('Project Layer Management & Audio Track Tests', () {
    test('Audio track layer can be added to project', () {
      final project = ProjectModel();
      final initialCount = project.layers.length;

      final audioLayer = LayerItem(
        id: "audio_1",
        name: "Background Music",
        type: LayerType.audio,
        startTime: 0.0,
        duration: 10.0,
        trackIndex: 1,
      );

      project.addLayer(audioLayer);
      expect(project.layers.length, initialCount + 1);
      expect(project.layers.last.type, LayerType.audio);
    });
  });
}
