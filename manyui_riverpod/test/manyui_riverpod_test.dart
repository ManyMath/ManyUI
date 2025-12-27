import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_riverpod/manyui_riverpod.dart';

final StateProvider<int> _counterProvider = StateProvider<int>((Ref ref) => 0);

void main() {
  testWidgets('MProviderController syncs provider and controller changes', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    late MController<int> controller;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MProviderController<int>(
            provider: _counterProvider,
            onChanged: (WidgetRef ref, int value) {
              ref.read(_counterProvider.notifier).state = value;
            },
            builder:
                (BuildContext context, MController<int> current, int value) {
                  controller = current;
                  return Text('$value/${current.value}');
                },
          ),
        ),
      ),
    );

    expect(find.text('0/0'), findsOneWidget);

    controller.value = 5;
    await tester.pump();
    expect(container.read(_counterProvider), 5);
    expect(find.text('5/5'), findsOneWidget);

    container.read(_counterProvider.notifier).state = 8;
    await tester.pump();
    expect(controller.value, 8);
    expect(find.text('8/8'), findsOneWidget);
  });

  testWidgets('theme-mode WidgetRef helpers read, set, and toggle mode', (
    WidgetTester tester,
  ) async {
    late WidgetRef capturedRef;

    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              capturedRef = ref;
              return Text(ref.watchMThemeMode().name);
            },
          ),
        ),
      ),
    );

    expect(find.text('system'), findsOneWidget);
    expect(capturedRef.readMThemeMode(), MThemeMode.system);

    capturedRef.setMThemeMode(MThemeMode.dark);
    await tester.pump();
    expect(find.text('dark'), findsOneWidget);

    capturedRef.toggleMThemeMode();
    await tester.pump();
    expect(find.text('light'), findsOneWidget);
  });
}
