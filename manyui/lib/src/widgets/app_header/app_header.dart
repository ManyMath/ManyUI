import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';

/// A responsive app-shell header for [MScaffold.header].
///
/// The header gives fleet apps one shared pattern for brand/title text,
/// optional context/status, and a wrapping action group. At compact widths
/// status and actions stack below the title so narrow windows do not depend
/// on every app hand-tuning its own `Row`/`Flexible` behavior.
class MAppHeader extends StatelessWidget {
  /// Builds an app header.
  const MAppHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.status,
    this.actions = const <Widget>[],
    this.compactBreakpoint = 640,
    this.spacing = 12,
    this.actionSpacing = 8,
    this.runSpacing = 8,
    super.key,
  });

  /// Product/app name shown as the primary header label.
  final String title;

  /// Secondary context shown next to [title], usually an account, file, or id.
  final String? subtitle;

  /// Optional leading control, such as a back button.
  final Widget? leading;

  /// Optional status chip/badge shown between identity and actions.
  final Widget? status;

  /// Header actions. They wrap as needed and align to the trailing edge.
  final List<Widget> actions;

  /// Width below which status/actions stack under the identity row.
  final double compactBreakpoint;

  /// Spacing between identity/status/action regions.
  final double spacing;

  /// Horizontal spacing between [actions].
  final double actionSpacing;

  /// Vertical spacing when status/actions wrap or stack.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final compact = constraints.maxWidth < compactBreakpoint;
        final constrained = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : compactBreakpoint;
        return compact
            ? _buildCompact(constrained)
            : _buildExpanded(constrained);
      },
    );
  }

  Widget _buildExpanded(double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: _Identity(title: title, subtitle: subtitle, leading: leading),
        ),
        if (status != null) ...<Widget>[
          SizedBox(width: spacing),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: math.min(320, width * 0.35)),
            child: Align(alignment: Alignment.centerLeft, child: status),
          ),
        ],
        if (actions.isNotEmpty) ...<Widget>[
          SizedBox(width: spacing),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _Actions(
                spacing: actionSpacing,
                runSpacing: runSpacing,
                actions: actions,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompact(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Identity(title: title, subtitle: subtitle, leading: leading),
        if (status != null) ...<Widget>[
          SizedBox(height: runSpacing),
          Align(alignment: Alignment.centerLeft, child: status),
        ],
        if (actions.isNotEmpty) ...<Widget>[
          SizedBox(height: runSpacing),
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: _Actions(
                spacing: actionSpacing,
                runSpacing: runSpacing,
                actions: actions,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.title, this.subtitle, this.leading});

  final String title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, const SizedBox(width: 8)],
        Flexible(
          fit: FlexFit.loose,
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.typography.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtitle!,
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.spacing,
    required this.runSpacing,
    required this.actions,
  });

  final double spacing;
  final double runSpacing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: runSpacing,
      children: actions,
    );
  }
}
