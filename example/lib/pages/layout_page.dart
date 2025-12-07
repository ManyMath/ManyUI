import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

import 'page_section.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageSection(
      title: 'Layout',
      subtitle: 'Divider, Scaffold, Card, Resizable',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DemoGrid(
            children: <Widget>[
              Demo(
                label: 'MCard',
                child: SizedBox(
                  width: 280,
                  child: MCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            'Project status',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Cards paint background, border, and radius from the theme.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Demo(
                label: 'MDivider — horizontal',
                child: SizedBox(width: 280, child: MDivider()),
              ),
              const Demo(
                label: 'MDivider — vertical',
                child: SizedBox(
                  height: 60,
                  child: MDivider(orientation: MDividerOrientation.vertical),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Demo(
            label: 'MResizable — drag the handle',
            child: SizedBox(height: 160, child: _ResizableDemo()),
          ),
          const SizedBox(height: 32),
          const Demo(
            label: 'MScaffold',
            child: Text(
              'You are looking at one. This example app is a single MScaffold '
              'with a header, body, and footer slot. See main.dart.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResizableDemo extends StatelessWidget {
  const _ResizableDemo();

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return MResizable(
      initialSizes: const <double>[0.35, 0.65],
      children: <MResizableChild>[
        MResizableChild(
          minSize: 0.15,
          child: ColoredBox(
            color: theme.colors.muted,
            child: const Center(child: Text('Left')),
          ),
        ),
        MResizableChild(
          minSize: 0.15,
          child: ColoredBox(
            color: theme.colors.accent,
            child: Center(
              child: Text(
                'Right',
                style: TextStyle(color: theme.colors.accentForeground),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
