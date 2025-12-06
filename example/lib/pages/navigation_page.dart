import 'package:flutter/widgets.dart';

import 'page_section.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageSection(
      title: 'Navigation',
      subtitle: 'Tabs, MenuBar, ContextMenu, CommandPalette',
      child: Text('Coming in next commit.'),
    );
  }
}
