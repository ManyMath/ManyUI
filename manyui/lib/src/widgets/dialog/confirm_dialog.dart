import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../button/button.dart';
import '../button/button_style.dart';
import 'dialog.dart';
import 'dialog_content.dart';
import 'dialog_style.dart';

/// A standard confirmation dialog body.
///
/// `MConfirmDialog` supplies the common title, optional explanatory message,
/// and cancel/confirm action layout used by destructive and committing flows.
/// It is only the dialog body; use [showMConfirmDialog] for the common boolean
/// route behavior.
class MConfirmDialog extends StatelessWidget {
  /// Builds a confirmation dialog body.
  const MConfirmDialog({
    required this.title,
    this.message,
    this.content,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.confirmVariant = MButtonVariant.primary,
    this.onCancel,
    this.onConfirm,
    this.autofocusConfirm = false,
    this.maxWidth = 380,
    super.key,
  });

  /// Primary prompt text.
  final String title;

  /// Optional secondary explanation.
  final String? message;

  /// Optional custom content inserted between [message] and the actions.
  final Widget? content;

  /// Label for the cancel action.
  final String cancelLabel;

  /// Label for the confirm action.
  final String confirmLabel;

  /// Visual treatment for the confirm action.
  final MButtonVariant confirmVariant;

  /// Called when the cancel action is pressed.
  final VoidCallback? onCancel;

  /// Called when the confirm action is pressed.
  final VoidCallback? onConfirm;

  /// Whether the confirm button requests focus on first build.
  final bool autofocusConfirm;

  /// Maximum width for the dialog body.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final hasMessage = message != null && message!.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: theme.typography.title.copyWith(
              color: theme.colors.foreground,
            ),
          ),
          if (hasMessage) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              message!,
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          if (content != null) ...<Widget>[
            SizedBox(height: hasMessage ? 12 : 8),
            DefaultTextStyle.merge(
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.mutedForeground,
              ),
              child: content!,
            ),
          ],
          const SizedBox(height: 20),
          MDialogActions(
            children: <Widget>[
              MButton(
                variant: MButtonVariant.ghost,
                onPressed: onCancel,
                child: Text(cancelLabel),
              ),
              MButton(
                variant: confirmVariant,
                autofocus: autofocusConfirm,
                onPressed: onConfirm,
                child: Text(confirmLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows a boolean confirmation dialog.
///
/// Returns true only when the confirm action is pressed. Cancel, Escape, and
/// scrim dismissal return false.
Future<bool> showMConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  MButtonVariant confirmVariant = MButtonVariant.primary,
  bool autofocusConfirm = false,
  double maxWidth = 380,
  MDialogStyleDelta? style,
  String? semanticLabel,
  bool dismissible = true,
}) async {
  final confirmed = await showMDialog<bool>(
    context,
    style: style,
    semanticLabel: semanticLabel ?? title,
    dismissible: dismissible,
    builder: (BuildContext ctx) {
      return MConfirmDialog(
        title: title,
        message: message,
        content: content,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        confirmVariant: confirmVariant,
        autofocusConfirm: autofocusConfirm,
        maxWidth: maxWidth,
        onCancel: () => Navigator.of(ctx).pop(false),
        onConfirm: () => Navigator.of(ctx).pop(true),
      );
    },
  );
  return confirmed ?? false;
}
