import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_testing/manyui_testing.dart';

void main() {
  testWidgets('renders title, subtitle, status, leading, and actions', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      MAppHeader(
        leading: const Text('Back'),
        title: 'ManyKee',
        headingLevel: 1,
        subtitle: 'Passwords.kdbx',
        status: const MBadge(child: Text('Open')),
        actions: <Widget>[MButton(onPressed: () {}, child: const Text('Lock'))],
      ),
    );

    expect(find.text('Back'), findsOneWidget);
    expect(find.text('ManyKee'), findsOneWidget);
    expect(find.text('Passwords.kdbx'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Lock'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('ManyKee')),
      matchesSemantics(label: 'ManyKee', isHeader: true),
    );
    expect(tester.getSemantics(find.text('ManyKee')).headingLevel, 1);
  });

  testWidgets('keeps actions on the title row when width is expanded', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      MAppHeader(
        title: 'ManyTier',
        actions: <Widget>[
          MButton(onPressed: () {}, child: const Text('Connections')),
          MButton(onPressed: () {}, child: const Text('Theme')),
        ],
      ),
      viewport: const Size(900, 220),
    );

    final titleTop = tester.getTopLeft(find.text('ManyTier')).dy;
    final actionTop = tester.getTopLeft(find.text('Connections')).dy;
    expect((actionTop - titleTop).abs(), lessThan(12));
  });

  testWidgets('expanded actions do not truncate the product title', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 220));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpManyApp(
      tester,
      MAppHeader(
        leading: const SizedBox(width: 32, height: 32),
        title: 'ManyTier Console',
        status: const MBadge(child: Text('Pairing required')),
        actions: <Widget>[
          MIconButton(
            icon: MIconData.network,
            label: 'Connections',
            onPressed: () {},
          ),
          MIconButton(
            icon: MIconData.lock,
            label: 'Disconnect',
            onPressed: () {},
          ),
          MIconButton(icon: MIconData.moon, label: 'Theme', onPressed: () {}),
        ],
      ),
      viewport: const Size(1280, 220),
    );

    final title = tester.widget<Text>(find.text('ManyTier Console'));
    final renderBox = tester.renderObject<RenderBox>(
      find.text('ManyTier Console'),
    );
    final naturalTitle = TextPainter(
      text: TextSpan(text: title.data, style: title.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    expect(renderBox.size.width, greaterThanOrEqualTo(naturalTitle.width));
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacks status and wrapping actions at compact widths', (
    WidgetTester tester,
  ) async {
    await pumpManyApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 260,
          child: MAppHeader(
            title: 'ManyMatrix',
            subtitle: '@averylongmatrixid:example.com',
            compactBreakpoint: 500,
            status: const MBadge(child: Text('Connected')),
            actions: <Widget>[
              MButton(onPressed: () {}, child: const Text('Join room')),
              MButton(onPressed: () {}, child: const Text('Create room')),
              MButton(onPressed: () {}, child: const Text('Accounts')),
            ],
          ),
        ),
      ),
      viewport: const Size(320, 600),
    );

    expect(tester.takeException(), isNull);
    final titleBottom = tester.getBottomLeft(find.text('ManyMatrix')).dy;
    final statusTop = tester.getTopLeft(find.text('Connected')).dy;
    final actionTop = tester.getTopLeft(find.text('Join room')).dy;
    expect(statusTop, greaterThan(titleBottom));
    expect(actionTop, greaterThan(statusTop));
  });
}
