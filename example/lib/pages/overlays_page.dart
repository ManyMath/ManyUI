import 'package:flutter/widgets.dart';

import 'page_section.dart';

class OverlaysPage extends StatelessWidget {
  const OverlaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageSection(
      title: 'Overlays',
      subtitle: 'Tooltip, Popover, Dialog, Sheet, Toast',
      child: Text('Coming in next commit.'),
    );
  }
}
