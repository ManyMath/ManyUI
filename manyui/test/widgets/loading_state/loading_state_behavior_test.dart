import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders a default circular indicator and message', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(tester, const MLoadingState(message: 'Loading rooms'));

    expect(find.byType(MCircularProgress), findsOneWidget);
    expect(find.text('Loading rooms'), findsOneWidget);

    final progress = tester.widget<MCircularProgress>(
      find.byType(MCircularProgress),
    );
    expect(progress.semanticLabel, 'Loading rooms');
  });

  testWidgets('uses custom semantic label for the default indicator', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const MLoadingState(
        message: 'Opening database',
        semanticLabel: 'Opening selected database',
      ),
    );

    final progress = tester.widget<MCircularProgress>(
      find.byType(MCircularProgress),
    );
    expect(progress.semanticLabel, 'Opening selected database');
  });

  testWidgets('renders a caller-provided indicator', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const MLoadingState(
        message: 'Merging',
        indicator: MProgress.indeterminate(semanticLabel: 'Merging database'),
      ),
    );

    expect(find.byType(MCircularProgress), findsNothing);
    expect(find.byType(MProgress), findsOneWidget);
    expect(find.text('Merging'), findsOneWidget);
  });

  testWidgets('uses muted body-small typography for the message', (
    WidgetTester tester,
  ) async {
    final theme = MThemeData.light();
    await pumpManyApp(
      tester,
      const MLoadingState(message: 'Loading objects'),
      theme: theme,
    );

    final text = tester.widget<Text>(find.text('Loading objects'));
    expect(text.style?.fontSize, theme.typography.bodySmall.fontSize);
    expect(text.style?.color, theme.colors.mutedForeground);
  });

  testWidgets('can align content to the start edge', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 320,
          child: MLoadingState(
            message: 'Loading controller networks',
            alignment: MLoadingStateAlignment.start,
          ),
        ),
      ),
    );

    final progressLeft = tester.getTopLeft(find.byType(MCircularProgress)).dx;
    final textLeft = tester
        .getTopLeft(find.text('Loading controller networks'))
        .dx;
    expect((textLeft - progressLeft).abs(), lessThan(1));
  });
}
