import 'package:flutter/widgets.dart';

import 'page_section.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageSection(
      title: 'Feedback',
      subtitle: 'Badge, Avatar, Progress, Accordion',
      child: Text('Coming in next commit.'),
    );
  }
}
