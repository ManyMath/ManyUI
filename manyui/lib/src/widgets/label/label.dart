import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'label_style.dart';

/// A text label that can request focus on an associated control on tap.
///
/// Pairs a styled `Text` with a `for`-like association to a sibling form
/// control. When tapped, [MLabel] calls `focusNode.requestFocus()` on the
/// supplied [focusNode], which both routes keyboard focus to the control
/// and (because every controller-aware widget activates on Enter/Space)
/// gives the same semantics as clicking the control directly.
///
/// ```dart
/// final FocusNode node = FocusNode();
///
/// MLabel('Enable notifications', focusNode: node)
/// MCheckbox(focusNode: node, semanticLabel: 'Enable notifications')
/// ```
///
/// When [child] is supplied, the label and the child are laid out as a row
/// (label first, child second) separated by the theme's [MLabelStyle.gap].
/// This is a convenience for inline labeled controls; complex layouts
/// should pass `child: null` and arrange the label and the control
/// themselves.
class MLabel extends StatelessWidget {
  /// Builds a label.
  const MLabel(
    this.text, {
    this.focusNode,
    this.enabled = true,
    this.style,
    this.child,
    this.semanticLabel,
    super.key,
  });

  /// The label's text.
  final String text;

  /// The focus node of the control this label is associated with.
  ///
  /// When non-null and [enabled] is true, tapping the label calls
  /// `focusNode.requestFocus()`. When null, the label is purely
  /// presentational and taps fall through to the underlying layout.
  final FocusNode? focusNode;

  /// Whether the label is enabled.
  ///
  /// A disabled label paints with [MLabelStyle.disabledColor] and ignores
  /// taps. The associated control's own enabled state is independent —
  /// callers that want a label and a control to share a disabled state pass
  /// the same boolean to both.
  final bool enabled;

  /// Field-wise overrides for the theme-resolved [MLabelStyle].
  final MLabelStyleDelta? style;

  /// An optional control to lay out alongside the label.
  ///
  /// When non-null, the label and the child are placed in a `Row` with
  /// [MLabelStyle.gap] of space between them. Callers wanting a more
  /// elaborate arrangement should leave this null and compose the label
  /// and the control directly.
  final Widget? child;

  /// The screen-reader label for the text. Defaults to [text].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MLabelStyle resolved = theme.label
        .resolve(
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
        )
        .applyDelta(style);

    final TextStyle effectiveStyle = enabled
        ? resolved.textStyle
        : resolved.textStyle.copyWith(color: resolved.disabledColor);

    final Widget label = Semantics(
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: Text(text, style: effectiveStyle),
    );

    final bool tappable = enabled && focusNode != null;
    final Widget gesture = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tappable ? () => focusNode!.requestFocus() : null,
      child: label,
    );

    if (child == null) {
      return gesture;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        gesture,
        SizedBox(width: resolved.gap),
        Flexible(child: child!),
      ],
    );
  }
}
