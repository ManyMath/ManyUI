import 'package:flutter/widgets.dart';

import 'page_section.dart';

class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageSection(
      title: 'Forms',
      subtitle:
          'Button, Checkbox, Switch, Radio, Slider, TextField, DateField, OTPField, Select, Label',
      child: Text('Coming in next commit.'),
    );
  }
}
