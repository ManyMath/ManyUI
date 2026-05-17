import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/input_modality.dart';
import '../button/button_style.dart';
import '../icon/icon_data.dart';
import '../icon_button/icon_button.dart';
import 'text_field.dart';
import 'text_field_style.dart';

/// A single-line [MTextField] preset for secrets (passwords, recovery
/// phrases, tokens): starts obscured with a trailing eye toggle that flips
/// [MTextField.obscureText] on tap.
///
/// Owns only the reveal/hide boolean -- everything else (controller, value,
/// validation, helper/error text) passes straight through to the underlying
/// [MTextField], so this is a thin preset rather than a parallel widget with
/// its own state-sync logic.
///
/// ```dart
/// MSecretField(
///   placeholder: 'Password',
///   onChanged: (String v) => debugPrint(v),
/// )
/// ```
class MSecretField extends StatefulWidget {
  /// Builds a secret field, obscured by default.
  const MSecretField({
    this.controller,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.enabled = true,
    this.maxLength,
    this.autofillHints = const <String>[],
    this.error = false,
    this.helperText,
    this.errorText,
    this.leading,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// The state source for this field. See [MTextField.controller].
  final MController<String>? controller;

  /// The seed value for the internal controller. See
  /// [MTextField.initialValue].
  final String initialValue;

  /// Called whenever the field's text changes. See [MTextField.onChanged].
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field. See [MTextField.onSubmitted].
  final ValueChanged<String>? onSubmitted;

  /// The text shown faintly when the field is empty.
  final String? placeholder;

  /// Whether the field responds to user input.
  final bool enabled;

  /// A hard cap on the number of characters accepted.
  final int? maxLength;

  /// Semantic roles used by platform autofill services and password managers.
  ///
  /// See [MTextField.autofillHints].
  final Iterable<String>? autofillHints;

  /// Whether the field is in an error state.
  final bool error;

  /// A helper line rendered below the field. See [MTextField.helperText].
  final String? helperText;

  /// An error line rendered below the field. See [MTextField.errorText].
  final String? errorText;

  /// Optional leading decoration (typically an icon).
  final Widget? leading;

  /// The input modality this field should size itself for.
  final MInputModality? modality;

  /// Field-wise style overrides.
  final MTextFieldStyleDelta? style;

  /// An optional accessibility label for the text field itself. The reveal
  /// toggle button carries its own label ("Show password" / "Hide
  /// password") regardless of this value.
  final String? semanticLabel;

  /// Whether the field should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  final FocusNode? focusNode;

  @override
  State<MSecretField> createState() => _MSecretFieldState();
}

class _MSecretFieldState extends State<MSecretField> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return MTextField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      placeholder: widget.placeholder,
      enabled: widget.enabled,
      obscureText: !_revealed,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      error: widget.error,
      helperText: widget.helperText,
      errorText: widget.errorText,
      leading: widget.leading,
      modality: widget.modality,
      style: widget.style,
      semanticLabel: widget.semanticLabel,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      trailing: MIconButton(
        icon: _revealed ? MIconData.eyeOff : MIconData.eye,
        label: _revealed ? 'Hide password' : 'Show password',
        size: MButtonSize.sm,
        modality: widget.modality,
        onPressed: widget.enabled
            ? () => setState(() => _revealed = !_revealed)
            : null,
      ),
    );
  }
}
