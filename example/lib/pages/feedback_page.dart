import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

import 'page_section.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final MController<double> _progress = MController<double>(0.35);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageSection(
      title: 'Feedback',
      subtitle: 'Badge, Avatar, Progress, Accordion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Demo(
            label: 'MBadge — every variant',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                MBadge(child: Text('Primary')),
                MBadge(
                  variant: MBadgeVariant.secondary,
                  child: Text('Secondary'),
                ),
                MBadge(
                  variant: MBadgeVariant.destructive,
                  child: Text('Failed'),
                ),
                MBadge(
                  variant: MBadgeVariant.outline,
                  child: Text('Outline'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Demo(
            label: 'MAvatar — image, fallback initials, sizes, shapes',
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                MAvatar(fallback: Text('JD')),
                MAvatar(size: 56, fallback: Text('AB')),
                MAvatar(
                  shape: MAvatarShape.square,
                  fallback: Text('SQ'),
                ),
                MAvatar(
                  size: 72,
                  shape: MAvatarShape.square,
                  fallback: Text('XL'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Demo(
            label: 'MProgress — determinate',
            child: SizedBox(
              width: 280,
              child: MProgress(controller: _progress),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              MButton(
                size: MButtonSize.sm,
                variant: MButtonVariant.outline,
                onPressed: () => _progress.value =
                    (_progress.value - 0.1).clamp(0.0, 1.0),
                child: const Text('−10%'),
              ),
              const SizedBox(width: 8),
              MButton(
                size: MButtonSize.sm,
                variant: MButtonVariant.outline,
                onPressed: () => _progress.value =
                    (_progress.value + 0.1).clamp(0.0, 1.0),
                child: const Text('+10%'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Demo(
            label: 'MProgress.indeterminate',
            child: SizedBox(width: 280, child: MProgress.indeterminate()),
          ),
          const SizedBox(height: 24),
          const Demo(
            label: 'MCircularProgress — determinate + indeterminate',
            child: Row(
              children: <Widget>[
                MCircularProgress(initialValue: 0.65),
                SizedBox(width: 24),
                MCircularProgress.indeterminate(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Demo(
            label: 'MAccordion — single mode',
            child: SizedBox(
              width: 480,
              child: MAccordion(
                initialExpanded: const <String>{'one'},
                items: <MAccordionItem>[
                  MAccordionItem(
                    id: 'one',
                    title: const Text('What is manyui?'),
                    content: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'A Flutter UI library with no required MaterialApp, ≤4 runtime deps, and parity across web, mobile, and desktop.',
                      ),
                    ),
                  ),
                  MAccordionItem(
                    id: 'two',
                    title: const Text('Does it work on web?'),
                    content: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Yes — and this example app proves it. Run flutter run -d chrome.',
                      ),
                    ),
                  ),
                  MAccordionItem(
                    id: 'three',
                    title: const Text('How do I theme it?'),
                    content: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Pass MThemeData.light() or .dark() to MWidgetsApp.theme and .darkTheme, then drive themeMode.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Demo(
            label: 'MAccordion — multiple mode',
            child: SizedBox(
              width: 480,
              child: MAccordion(
                mode: MAccordionMode.multiple,
                initialExpanded: const <String>{'a', 'b'},
                items: <MAccordionItem>[
                  MAccordionItem(
                    id: 'a',
                    title: const Text('Section A'),
                    content: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text('Multiple items can stay expanded at once.'),
                    ),
                  ),
                  MAccordionItem(
                    id: 'b',
                    title: const Text('Section B'),
                    content: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text('Use this mode for FAQ-style content.'),
                    ),
                  ),
                  MAccordionItem(
                    id: 'c',
                    title: const Text('Section C (collapsed by default)'),
                    content: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text('Tap to expand.'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
