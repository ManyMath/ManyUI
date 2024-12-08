import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

// A 1x1 transparent PNG. Used as the image bytes for the
// "image resolves successfully" test case so we don't need a real network.
final Uint8List _onePxPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  group('MAvatar fallback', () {
    testWidgets('renders fallback Widget when image is null',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(
          child: MAvatar(fallback: Text('JD'), size: 40),
        ),
      );
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders nothing visible when image is null and fallback is null',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MAvatar(size: 40)),
      );
      expect(find.byType(MAvatar), findsOneWidget);
      // The surface still exists, just with no content text.
      expect(find.byType(Text), findsNothing);
    });
  });

  group('MAvatar image', () {
    testWidgets('shows the image when one is supplied',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        Center(
          child: MAvatar(
            image: MemoryImage(_onePxPng),
            fallback: const Text('JD'),
            size: 40,
          ),
        ),
      );
      await tester.pump();

      // While the image is decoding, fallback may still be visible — but the
      // Image widget itself should exist in the tree.
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('MAvatar shape and size', () {
    testWidgets('default size is 40x40 and circular',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MAvatar(fallback: Text('JD'))),
      );
      final Size size = tester.getSize(find.byType(MAvatar));
      expect(size, const Size(40, 40));
    });

    testWidgets('custom size flows through to the rendered surface',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MAvatar(fallback: Text('JD'), size: 64)),
      );
      expect(tester.getSize(find.byType(MAvatar)), const Size(64, 64));
    });

    testWidgets('square shape uses ClipRRect with theme radius',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(
          child: MAvatar(
            fallback: Text('JD'),
            shape: MAvatarShape.square,
          ),
        ),
      );
      // ClipRRect should be present and configured with a non-pill radius.
      final ClipRRect clip = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byType(MAvatar),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      final BorderRadius? br = clip.borderRadius as BorderRadius?;
      expect(br, isNotNull);
      // Theme default radius is 6 — far less than the half-size 20 a circle
      // would give at size=40.
      expect(br!.topLeft.x, lessThan(20));
    });
  });

  group('MAvatar style delta', () {
    testWidgets('overrides backgroundColor', (WidgetTester tester) async {
      const Color override = Color(0xFF00FF00);
      await pumpManyApp(
        tester,
        const Center(
          child: MAvatar(
            fallback: Text('JD'),
            style: MAvatarStyleDelta(backgroundColor: override),
          ),
        ),
      );

      final DecoratedBox deco = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(MAvatar),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((deco.decoration as BoxDecoration).color, override);
    });
  });

  group('MAvatar semantics', () {
    testWidgets('reports semanticLabel and isImage when image is set',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpManyApp(
        tester,
        Center(
          child: MAvatar(
            image: MemoryImage(_onePxPng),
            fallback: const Text('JD'),
            semanticLabel: 'Jane Doe',
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(MAvatar)),
        matchesSemantics(label: 'Jane Doe', isImage: true),
      );
      handle.dispose();
    });

    testWidgets('reports semanticLabel without isImage when image is null',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpManyApp(
        tester,
        const Center(
          child: MAvatar(
            fallback: Text('JD'),
            semanticLabel: 'Jane Doe',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(MAvatar)),
        matchesSemantics(label: 'Jane Doe'),
      );
      handle.dispose();
    });
  });
}
