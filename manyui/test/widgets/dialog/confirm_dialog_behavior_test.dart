import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

Widget _app({required Widget child}) {
  return MWidgetsApp(
    theme: MThemeData.light(),
    themeMode: MThemeMode.light,
    home: child,
  );
}

void main() {
  testWidgets('renders title, message, content, and action labels', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      MConfirmDialog(
        title: 'Delete object?',
        message: 'This cannot be undone.',
        content: const Text('Object name'),
        confirmLabel: 'Delete',
        confirmVariant: MButtonVariant.destructive,
        onCancel: () {},
        onConfirm: () {},
      ),
    );

    expect(find.text('Delete object?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.text('Object name'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('showMConfirmDialog returns true when confirmed', (
    WidgetTester tester,
  ) async {
    late BuildContext rootContext;
    await tester.pumpWidget(
      _app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final future = showMConfirmDialog(
      rootContext,
      title: 'Delete message?',
      message: 'This removes the message for everyone.',
      confirmLabel: 'Delete',
      confirmVariant: MButtonVariant.destructive,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(await future, isTrue);
    expect(find.text('Delete message?'), findsNothing);
  });

  testWidgets('showMConfirmDialog returns false when cancelled', (
    WidgetTester tester,
  ) async {
    late BuildContext rootContext;
    await tester.pumpWidget(
      _app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final future = showMConfirmDialog(
      rootContext,
      title: 'Leave network?',
      confirmLabel: 'Leave',
      confirmVariant: MButtonVariant.destructive,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await future, isFalse);
    expect(find.text('Leave network?'), findsNothing);
  });

  testWidgets('showMConfirmDialog returns false when dismissed', (
    WidgetTester tester,
  ) async {
    late BuildContext rootContext;
    await tester.pumpWidget(
      _app(
        child: Builder(
          builder: (BuildContext context) {
            rootContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final future = showMConfirmDialog(
      rootContext,
      title: 'Forget account?',
      confirmLabel: 'Forget',
    );
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(await future, isFalse);
    expect(find.text('Forget account?'), findsNothing);
  });

  testWidgets('actions wrap at compact widths without overflow', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 128,
          child: MConfirmDialog(
            title: 'Delete?',
            cancelLabel: 'Keep it',
            confirmLabel: 'Delete now',
            onCancel: () {},
            onConfirm: () {},
          ),
        ),
      ),
      viewport: const Size(180, 240),
    );

    expect(tester.takeException(), isNull);
    final cancelTop = tester.getTopLeft(find.text('Keep it')).dy;
    final confirmTop = tester.getTopLeft(find.text('Delete now')).dy;
    expect(confirmTop, greaterThan(cancelTop));
  });
}
