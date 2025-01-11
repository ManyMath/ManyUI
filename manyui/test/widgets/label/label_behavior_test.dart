import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  group('MLabel text rendering', () {
    testWidgets('renders the provided text', (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MLabel('Enable notifications')),
      );

      expect(find.text('Enable notifications'), findsOneWidget);
    });

    testWidgets('uses typography.label color = colors.foreground when enabled',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(child: MLabel('hello')),
        theme: theme,
      );

      final Text text = tester.widget<Text>(
        find.descendant(of: find.byType(MLabel), matching: find.byType(Text)),
      );
      expect(text.style?.color, theme.colors.foreground);
      expect(text.style?.fontSize, theme.typography.label.fontSize);
    });

    testWidgets('uses disabledColor when enabled is false',
        (WidgetTester tester) async {
      final MThemeData theme = MThemeData.light();
      await pumpManyApp(
        tester,
        const Center(child: MLabel('hello', enabled: false)),
        theme: theme,
      );

      final Text text = tester.widget<Text>(
        find.descendant(of: find.byType(MLabel), matching: find.byType(Text)),
      );
      expect(text.style?.color, theme.colors.mutedForeground);
    });
  });

  group('MLabel focus routing', () {
    testWidgets('tapping the label requests focus on the associated FocusNode',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MLabel('Accept terms', focusNode: node),
              Focus(focusNode: node, child: const SizedBox(width: 20, height: 20)),
            ],
          ),
        ),
      );

      expect(node.hasFocus, isFalse);
      await tester.tap(find.text('Accept terms'));
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('a disabled label does not route taps',
        (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MLabel('Accept terms', focusNode: node, enabled: false),
              Focus(focusNode: node, child: const SizedBox(width: 20, height: 20)),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Accept terms'));
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('a label without a focusNode is purely presentational',
        (WidgetTester tester) async {
      // Pumping with no FocusNode and tapping should not throw — the
      // GestureDetector has a null onTap so the tap is a no-op.
      await pumpManyApp(
        tester,
        const Center(child: MLabel('Static caption')),
      );

      await tester.tap(find.text('Static caption'));
      await tester.pump();
      // No assertion needed — reaching this point without an exception is
      // the success condition.
    });

    testWidgets('tapping the label routes focus to a sibling MCheckbox',
        (WidgetTester tester) async {
      // End-to-end check that MLabel composes with an existing controller-
      // aware widget exactly the way the docstring claims.
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await pumpManyApp(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MLabel('Enable', focusNode: node),
              const SizedBox(width: 8),
              MCheckbox(focusNode: node, onChanged: (_) {}),
            ],
          ),
        ),
      );

      expect(node.hasFocus, isFalse);
      await tester.tap(find.text('Enable'));
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });
  });

  group('MLabel inline child layout', () {
    testWidgets('inline child renders to the right of the label with gap',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(
          child: MLabel(
            'Inline',
            child: SizedBox(key: ValueKey<String>('side'), width: 10, height: 10),
          ),
        ),
      );

      final double labelRight =
          tester.getTopRight(find.text('Inline')).dx;
      final double sideLeft =
          tester.getTopLeft(find.byKey(const ValueKey<String>('side'))).dx;
      // Default gap is 8 logical pixels.
      expect(sideLeft - labelRight, closeTo(8, 0.5));
    });

    testWidgets('style.gap delta overrides the inline gap',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(
          child: MLabel(
            'Inline',
            style: MLabelStyleDelta(gap: 24),
            child: SizedBox(key: ValueKey<String>('side'), width: 10, height: 10),
          ),
        ),
      );

      final double labelRight =
          tester.getTopRight(find.text('Inline')).dx;
      final double sideLeft =
          tester.getTopLeft(find.byKey(const ValueKey<String>('side'))).dx;
      expect(sideLeft - labelRight, closeTo(24, 0.5));
    });

    testWidgets('without a child the label is a single Text-sized box',
        (WidgetTester tester) async {
      await pumpManyApp(
        tester,
        const Center(child: MLabel('compact')),
      );

      // No Row should be created when child is null.
      expect(
        find.descendant(of: find.byType(MLabel), matching: find.byType(Row)),
        findsNothing,
      );
    });
  });

  group('MLabel style delta', () {
    testWidgets('textStyle delta overlays on the resolved style',
        (WidgetTester tester) async {
      const TextStyle override = TextStyle(fontSize: 22, color: Color(0xFF00FF00));
      await pumpManyApp(
        tester,
        const Center(
          child: MLabel('big', style: MLabelStyleDelta(textStyle: override)),
        ),
      );

      final Text text = tester.widget<Text>(
        find.descendant(of: find.byType(MLabel), matching: find.byType(Text)),
      );
      expect(text.style?.fontSize, 22);
      expect(text.style?.color, const Color(0xFF00FF00));
    });

    testWidgets('disabledColor delta wins over the theme default',
        (WidgetTester tester) async {
      const Color override = Color(0xFFFF00FF);
      await pumpManyApp(
        tester,
        const Center(
          child: MLabel(
            'dim',
            enabled: false,
            style: MLabelStyleDelta(disabledColor: override),
          ),
        ),
      );

      final Text text = tester.widget<Text>(
        find.descendant(of: find.byType(MLabel), matching: find.byType(Text)),
      );
      expect(text.style?.color, override);
    });
  });

  group('MLabel semantics', () {
    testWidgets('uses text as the semantic label by default',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpManyApp(
        tester,
        const Center(child: MLabel('Default semantic')),
      );

      // MLabel uses excludeSemantics inside, so the wrapping Semantics is the
      // only one that surfaces the label. Locate the Semantics widget rooted
      // inside MLabel and read its properties directly.
      final Semantics semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(MLabel),
          matching: find.byType(Semantics),
        ),
      );
      expect(semantics.properties.label, 'Default semantic');
      handle.dispose();
    });

    testWidgets('semanticLabel overrides the visible text for screen readers',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpManyApp(
        tester,
        const Center(
          child: MLabel('Visible', semanticLabel: 'Screen-reader text'),
        ),
      );

      final Semantics semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(MLabel),
          matching: find.byType(Semantics),
        ),
      );
      expect(semantics.properties.label, 'Screen-reader text');
      // Excluded so the inner Text's content doesn't leak through.
      expect(semantics.excludeSemantics, isTrue);
      handle.dispose();
    });
  });

  group('MLabel theme integration', () {
    testWidgets('MThemeData.label is non-null on light and dark defaults',
        (WidgetTester tester) async {
      expect(MThemeData.light().label, isNotNull);
      expect(MThemeData.dark().label, isNotNull);
    });

    testWidgets('copyWith(label: ...) replaces only the label table',
        (WidgetTester tester) async {
      final MThemeData base = MThemeData.light();
      const MLabelStyles replacement = MLabelStyles();
      final MThemeData updated = base.copyWith(label: replacement);
      expect(identical(updated.label, replacement), isTrue);
      // Other tables unchanged.
      expect(identical(updated.checkbox, base.checkbox), isTrue);
      expect(identical(updated.slider, base.slider), isTrue);
    });
  });
}
