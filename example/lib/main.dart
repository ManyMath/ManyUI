import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MWidgetsApp(
      title: 'manyui example',
      theme: MThemeData.light(),
      darkTheme: MThemeData.dark(),
      home: const MScaffold(
        body: Center(
          child: Text('manyui example — wiring in next commit'),
        ),
      ),
    );
  }
}
