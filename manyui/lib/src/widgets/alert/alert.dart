import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';

/// Visual variants for [MAlert].
enum MAlertVariant {
  /// Low-emphasis informational status.
  neutral,

  /// Error or destructive-operation status.
  destructive,
}

/// A compact inline status or error message.
///
/// `MAlert` is a lightweight banner, not a card. It is intended for form
/// errors, async failure states, and operational status messages that need
/// more shape than plain text while still fitting inside existing layouts.
class MAlert extends StatelessWidget {
  /// Builds an alert.
  const MAlert({
    required this.message,
    this.title,
    this.variant = MAlertVariant.neutral,
    this.leading,
    this.actions = const <Widget>[],
    this.liveRegion,
    this.maxWidth = double.infinity,
    super.key,
  });

  /// Optional title rendered above [message].
  final String? title;

  /// Main alert text.
  final String message;

  /// Visual treatment.
  final MAlertVariant variant;

  /// Optional icon, progress, or status widget.
  final Widget? leading;

  /// Optional trailing actions. They wrap below the message at compact widths.
  final List<Widget> actions;

  /// Whether assistive technologies should announce updates to this alert.
  ///
  /// Defaults to true for destructive alerts and false for neutral alerts.
  final bool? liveRegion;

  /// Maximum width for the alert body.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final colors = _AlertColors.resolve(theme, variant);

    return Semantics(
      container: true,
      liveRegion: liveRegion ?? variant == MAlertVariant.destructive,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(theme.radius),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: IconTheme.merge(
                          data: IconThemeData(color: colors.accent),
                          child: leading!,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: _AlertText(
                        title: title,
                        message: message,
                        foreground: colors.foreground,
                        accent: colors.accent,
                      ),
                    ),
                  ],
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertText extends StatelessWidget {
  const _AlertText({
    required this.title,
    required this.message,
    required this.foreground,
    required this.accent,
  });

  final String? title;
  final String message;
  final Color foreground;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null && title!.isNotEmpty) ...<Widget>[
          Text(title!, style: theme.typography.label.copyWith(color: accent)),
          const SizedBox(height: 4),
        ],
        Text(
          message,
          style: theme.typography.bodySmall.copyWith(color: foreground),
        ),
      ],
    );
  }
}

class _AlertColors {
  const _AlertColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.accent,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color accent;

  static _AlertColors resolve(MThemeData theme, MAlertVariant variant) {
    final colors = theme.colors;
    return switch (variant) {
      MAlertVariant.neutral => _AlertColors(
        background: colors.muted,
        border: colors.border,
        foreground: colors.mutedForeground,
        accent: colors.foreground,
      ),
      MAlertVariant.destructive => _AlertColors(
        background: colors.destructive.withValues(alpha: 0.08),
        border: colors.destructive.withValues(alpha: 0.35),
        foreground: colors.destructive,
        accent: colors.destructive,
      ),
    };
  }
}
