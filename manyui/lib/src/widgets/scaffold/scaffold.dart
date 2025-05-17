import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'scaffold_style.dart';

/// An app-shell surface: header pinned to the top, footer pinned to the
/// bottom, body filling the remaining space, with safe-area insets applied.
///
/// Does not depend on `MaterialApp`, `Scaffold`, or `CupertinoApp`.
///
/// ```dart
/// MScaffold(
///   header: MMenuBar(items: ...),
///   body: Center(child: Text('Hello, manyui')),
///   footer: Text('Status bar'),
/// )
/// ```
class MScaffold extends StatelessWidget {
  /// Builds a scaffold.
  const MScaffold({
    required this.body,
    this.header,
    this.footer,
    this.style,
    super.key,
  });

  /// The main content area. Fills the space between [header] and [footer]
  /// inside the safe area.
  final Widget body;

  /// Optional content pinned to the top of the scaffold. Renders above
  /// [body] with [MScaffoldStyle.headerPadding] applied.
  final Widget? header;

  /// Optional content pinned to the bottom of the scaffold. Renders below
  /// [body] with [MScaffoldStyle.footerPadding] applied.
  final Widget? footer;

  /// Field-wise overrides for the theme-resolved [MScaffoldStyle].
  final MScaffoldStyleDelta? style;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MScaffoldStyle resolved =
        theme.scaffold.resolve(colors: theme.colors).applyDelta(style);

    final Widget paddedBody = Padding(
      padding: resolved.bodyPadding,
      child: body,
    );

    final Widget column = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (header != null)
          Padding(padding: resolved.headerPadding, child: header),
        Expanded(child: paddedBody),
        if (footer != null)
          Padding(padding: resolved.footerPadding, child: footer),
      ],
    );

    return ColoredBox(
      color: resolved.backgroundColor,
      child: SafeArea(
        child: DefaultTextStyle.merge(
          style: TextStyle(color: resolved.foregroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: resolved.foregroundColor),
            child: column,
          ),
        ),
      ),
    );
  }
}
