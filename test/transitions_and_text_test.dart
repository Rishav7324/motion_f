import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motion_f/models/layer.dart';

void main() {
  group('Transitions Tests', () {
    test('Default layer initializes with no transition', () {
      final layer = LayerItem(
        id: "l_trans_1",
        name: "Video 1",
        type: LayerType.video,
      );

      expect(layer.transitionIn, TransitionType.none);
      expect(layer.transitionOut, TransitionType.none);
      expect(layer.transitionInDuration, 0.5);
      expect(layer.transitionOutDuration, 0.5);
    });

    test('Transitions can be assigned with custom durations', () {
      final layer = LayerItem(
        id: "l_trans_2",
        name: "Video 2",
        type: LayerType.video,
        transitionIn: TransitionType.crossZoom,
        transitionInDuration: 1.2,
        transitionOut: TransitionType.glitch,
        transitionOutDuration: 0.8,
      );

      expect(layer.transitionIn, TransitionType.crossZoom);
      expect(layer.transitionInDuration, 1.2);
      expect(layer.transitionOut, TransitionType.glitch);
      expect(layer.transitionOutDuration, 0.8);
    });
  });

  group('Typography & Text Styling Tests', () {
    test('Default text layer typography attributes', () {
      final layer = LayerItem(
        id: "l_text_1",
        name: "Title Text",
        type: LayerType.text,
        textContent: "Hello MotionF",
      );

      expect(layer.textContent, "Hello MotionF");
      expect(layer.fontSize, 28.0);
      expect(layer.textColor, Colors.white);
      expect(layer.hasTextStroke, isFalse);
      expect(layer.hasTextShadow, isTrue);
      expect(layer.hasTextBackground, isFalse);
    });

    test('Custom typography styling parameters are stored', () {
      final layer = LayerItem(
        id: "l_text_2",
        name: "Styled Title",
        type: LayerType.text,
        textContent: "Motion Graphics",
        fontSize: 48.0,
        textColor: const Color(0xFFFFD600),
        hasTextStroke: true,
        textStrokeWidth: 4.0,
        textStrokeColor: Colors.black,
        hasTextBackground: true,
        textBackgroundColor: const Color(0xAA000000),
        textLetterSpacing: 4.0,
        textFontFamily: "monospace",
      );

      expect(layer.fontSize, 48.0);
      expect(layer.textColor, const Color(0xFFFFD600));
      expect(layer.hasTextStroke, isTrue);
      expect(layer.textStrokeWidth, 4.0);
      expect(layer.hasTextBackground, isTrue);
      expect(layer.textLetterSpacing, 4.0);
      expect(layer.textFontFamily, "monospace");
    });
  });
}
