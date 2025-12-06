import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

import 'pages/feedback_page.dart';
import 'pages/forms_page.dart';
import 'pages/layout_page.dart';
import 'pages/navigation_page.dart';
import 'pages/overlays_page.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  MThemeMode _mode = MThemeMode.light;

  void _toggle() {
    setState(() {
      _mode = _mode == MThemeMode.light ? MThemeMode.dark : MThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MWidgetsApp(
      title: 'manyui example',
      theme: MThemeData.light(),
      darkTheme: MThemeData.dark(),
      themeMode: _mode,
      home: _Shell(mode: _mode, onToggle: _toggle),
    );
  }
}

class _Page {
  const _Page(this.id, this.label, this.builder);
  final String id;
  final String label;
  final WidgetBuilder builder;
}

final List<_Page> _pages = <_Page>[
  _Page('layout', 'Layout', (_) => const LayoutPage()),
  _Page('forms', 'Forms', (_) => const FormsPage()),
  _Page('overlays', 'Overlays', (_) => const OverlaysPage()),
  _Page('navigation', 'Navigation', (_) => const NavigationPage()),
  _Page('feedback', 'Feedback', (_) => const FeedbackPage()),
];

class _Shell extends StatefulWidget {
  const _Shell({required this.mode, required this.onToggle});

  final MThemeMode mode;
  final VoidCallback onToggle;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  String _selectedId = _pages.first.id;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final active = _pages.firstWhere((p) => p.id == _selectedId);

    return MScaffold(
      header: _Header(mode: widget.mode, onToggle: widget.onToggle),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: ColoredBox(
              color: theme.colors.muted,
              child: _Sidebar(
                selectedId: _selectedId,
                onSelect: (id) => setState(() => _selectedId = id),
              ),
            ),
          ),
          const MDivider(orientation: MDividerOrientation.vertical),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: active.builder(context),
            ),
          ),
        ],
      ),
      footer: const _Footer(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mode, required this.onToggle});

  final MThemeMode mode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text(
          'manyui',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        const MBadge(child: Text('v0.1.1')),
        const Spacer(),
        MButton(
          variant: MButtonVariant.outline,
          size: MButtonSize.sm,
          onPressed: onToggle,
          child: Text(mode == MThemeMode.light ? 'Dark' : 'Light'),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Text(
      '17 widget shapes · MIT · no MaterialApp',
      style: TextStyle(color: theme.colors.mutedForeground, fontSize: 12),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedId, required this.onSelect});

  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Families',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colors.mutedForeground,
              letterSpacing: 0.6,
            ),
          ),
        ),
        for (final page in _pages)
          _SidebarItem(
            label: page.label,
            selected: page.id == selectedId,
            onTap: () => onSelect(page.id),
          ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final Color? bg = widget.selected
        ? theme.colors.accent
        : (_hover ? theme.colors.accent.withValues(alpha: 0.5) : null);
    final Color fg = widget.selected
        ? theme.colors.accentForeground
        : theme.colors.foreground;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: bg,
          child: Text(
            widget.label,
            style: TextStyle(
              color: fg,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
