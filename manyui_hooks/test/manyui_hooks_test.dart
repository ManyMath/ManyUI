import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';

void main() {
  testWidgets('useMController owns a stable controller until keys change', (
    WidgetTester tester,
  ) async {
    final List<MController<String>> seen = <MController<String>>[];

    Widget harness(String seed) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: HookBuilder(
          builder: (BuildContext context) {
            final MController<String> controller = useMController<String>(
              seed,
              <Object?>[seed],
            );
            final String value = useMControllerValue(controller);
            seen.add(controller);
            return Text(value);
          },
        ),
      );
    }

    await tester.pumpWidget(harness('first'));
    final MController<String> first = seen.single;
    expect(find.text('first'), findsOneWidget);

    first.value = 'changed';
    await tester.pump();
    expect(find.text('changed'), findsOneWidget);

    await tester.pumpWidget(harness('first'));
    expect(identical(first, seen.last), isTrue);
    expect(find.text('changed'), findsOneWidget);

    await tester.pumpWidget(harness('second'));
    expect(identical(first, seen.last), isFalse);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('useMControllerFromValueListenable follows the source', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<int> source = ValueNotifier<int>(1);
    addTearDown(source.dispose);
    late MController<int> controller;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HookBuilder(
          builder: (BuildContext context) {
            controller = useMControllerFromValueListenable<int>(source);
            final int value = useMControllerValue(controller);
            return Text('$value');
          },
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);

    source.value = 2;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    controller.value = 3;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(source.value, 2);
  });

  testWidgets('useMThemeModeController seeds a theme-mode controller', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HookBuilder(
          builder: (BuildContext context) {
            final MController<MThemeMode> controller = useMThemeModeController(
              MThemeMode.dark,
            );
            final MThemeMode value = useMControllerValue(controller);
            return Text(value.name);
          },
        ),
      ),
    );

    expect(find.text('dark'), findsOneWidget);
  });
}
