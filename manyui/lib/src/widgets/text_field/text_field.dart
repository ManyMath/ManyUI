import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'text_field_style.dart';

/// A single-line styled text input wrapping Flutter's [EditableText].
///
/// Accepts an `MController<String>?`; when null, owns one internally seeded
/// with [initialValue]. A [TextEditingController] bridges between the manyui
/// controller and [EditableText], synced in both directions.
///
/// Visual states: idle (input border), focused (ring border + focus ring),
/// error (destructive border), disabled (dimmed, rejects input).
///
/// ```dart
/// MTextField(
///   placeholder: 'name@example.com',
///   onChanged: (String v) => debugPrint(v),
/// )
/// ```
///
/// Selection toolbars are not included -- the core avoids Material.
/// Keyboard shortcuts (Cmd/Ctrl-C/V/X/A/Z/Y) work via [EditableText].
class MTextField extends StatefulWidget {
  /// Builds a text field.
  const MTextField({
    this.controller,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.error = false,
    this.leading,
    this.trailing,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  /// The state source for this field.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the field creates and owns one seeded with
  /// [initialValue].
  ///
  /// Mutating the controller from outside the widget (e.g. to clear the field
  /// programmatically) updates the displayed text on the next frame.
  final MController<String>? controller;

  /// The seed value for the internal controller.
  ///
  /// Ignored when [controller] is non-null.
  final String initialValue;

  /// Called whenever the field's text changes — either through user editing
  /// or programmatic mutation of the underlying controller.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (typically by pressing Enter
  /// with the field focused).
  final ValueChanged<String>? onSubmitted;

  /// The text shown faintly inside the field when its content is empty.
  final String? placeholder;

  /// Whether the field responds to user input.
  final bool enabled;

  /// Whether the field shows its current text but rejects edits.
  ///
  /// Distinct from [enabled]: a read-only field is still focusable and
  /// supports text selection / copy.
  final bool readOnly;

  /// Whether each character is rendered as a placeholder glyph (for
  /// passwords or other secrets).
  final bool obscureText;

  /// A hard cap on the number of characters the field accepts. When null,
  /// length is unbounded.
  final int? maxLength;

  /// The keyboard variant the OS should show on mobile. Maps to
  /// [TextInputType] — pass `TextInputType.emailAddress` for an email
  /// keyboard, etc.
  final TextInputType? keyboardType;

  /// The action button the OS should show on the keyboard's bottom-right
  /// (e.g. `TextInputAction.search`, `TextInputAction.done`).
  final TextInputAction? textInputAction;

  /// Per-keystroke filters applied before the text reaches the controller.
  ///
  /// See [FilteringTextInputFormatter] and friends.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field is in an error state.
  ///
  /// Error rendering is purely visual (border swaps to
  /// [MTextFieldStyle.errorBorderColor]); validation is the caller's
  /// responsibility.
  final bool error;

  /// Optional widget rendered at the leading (start) edge of the field —
  /// typically an icon. Its color follows [MTextFieldStyle.iconColor]
  /// unless it installs its own [IconTheme].
  final Widget? leading;

  /// Optional widget rendered at the trailing (end) edge of the field —
  /// typically a clear-button or a unit-label.
  final Widget? trailing;

  /// The input modality this field should size itself for.
  ///
  /// When null, the field resolves modality from
  /// [MInputModalityScope.resolve].
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MTextFieldStyle].
  final MTextFieldStyleDelta? style;

  /// An optional accessibility label.
  ///
  /// Pair with an `MLabel` for visible labels.
  final String? semanticLabel;

  /// Whether the field should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  ///
  /// When null, the field creates and disposes its own node.
  final FocusNode? focusNode;

  /// The minimum number of lines to occupy. When null, the field starts at one
  /// line and grows toward [maxLines]. Forwarded to [EditableText.minLines].
  final int? minLines;

  /// The maximum number of lines the field can grow to.
  ///
  /// Defaults to `1` (single-line). Pass `null` for unbounded growth, or an
  /// integer to cap it. Any value other than `1` makes the field multiline:
  /// Flutter then stops stripping `\n` from input before [inputFormatters]
  /// run, and the field sizes to its content instead of collapsing to one row.
  /// Forwarded to [EditableText.maxLines].
  final int? maxLines;

  @override
  State<MTextField> createState() => _MTextFieldState();
}

class _MTextFieldState extends State<MTextField> {
  late MController<String> _controller;
  bool _ownsController = false;

  // The Flutter-primitive controller EditableText needs. Always owned by the
  // widget — even when the caller supplies an MController<String>, we
  // maintain our own TextEditingController and keep them in sync.
  late TextEditingController _editing;

  // Lets the tap handler call EditableText.requestKeyboard(). Focusing the
  // node alone doesn't open the input connection (EditableText only opens it
  // on focus-gain when a keyboard token is consumed), leaving the field
  // focused but inert: no caret, typing, or paste.
  final GlobalKey<EditableTextState> _editableKey =
      GlobalKey<EditableTextState>();

  late UndoHistoryController _undo;

  FocusNode? _ownedFocusNode;
  bool _focused = false;

  // Re-entrancy guard for the sync between the MController and the
  // TextEditingController. Without it, "set MController.value → notify →
  // _editing.text = next → notify → _onEditingChanged → controller.value =
  // next" loops back into the listener.
  bool _syncing = false;

  FocusNode get _focusNode {
    if (widget.focusNode != null) return widget.focusNode!;
    return _ownedFocusNode ??= FocusNode(debugLabel: 'MTextField');
  }

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _editing = TextEditingController(text: _controller.value);
    _editing.addListener(_onEditingChanged);
    _undo = UndoHistoryController();
    _focusNode.addListener(_onFocusNodeChanged);
  }

  @override
  void didUpdateWidget(covariant MTextField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
      // Re-sync the editing controller to the new source.
      _syncing = true;
      _editing.text = _controller.value;
      _syncing = false;
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusNodeChanged);
      _focusNode.addListener(_onFocusNodeChanged);
    }
  }

  void _bindController(MController<String>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<String>(widget.initialValue);
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onControllerChanged() {
    if (_syncing) {
      // Still rebuild — the visible text changed via the editing controller
      // and the placeholder visibility may need to flip.
      if (mounted) setState(() {});
      return;
    }
    if (_editing.text != _controller.value) {
      _syncing = true;
      _editing.text = _controller.value;
      _syncing = false;
    }
    if (mounted) setState(() {});
  }

  void _onEditingChanged() {
    if (_syncing) {
      if (mounted) setState(() {});
      return;
    }
    final String next = _editing.text;
    if (_controller.value != next) {
      _syncing = true;
      _controller.value = next;
      _syncing = false;
      widget.onChanged?.call(next);
    }
    if (mounted) setState(() {});
  }

  void _onFocusNodeChanged() {
    final bool next = _focusNode.hasFocus;
    if (_focused != next) setState(() => _focused = next);
  }

  @override
  void dispose() {
    _editing.removeListener(_onEditingChanged);
    _editing.dispose();
    _undo.dispose();
    _unbindController();
    _focusNode.removeListener(_onFocusNodeChanged);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MTextFieldStyle resolved = theme.textField
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final Color border = widget.error
        ? resolved.errorBorderColor
        : (_focused ? resolved.focusedBorderColor : resolved.borderColor);

    final TextStyle textStyle = resolved.textStyle.copyWith(
      color: theme.colors.foreground,
    );

    final bool empty = _editing.text.isEmpty;
    final bool showPlaceholder =
        empty && (widget.placeholder?.isNotEmpty ?? false);

    // maxLines == 1 is Flutter's single-line mode: it strips '\n' before
    // formatters run and the surface collapses to one row. Any other value
    // (including null = unbounded) makes the field multiline.
    final bool multiline = widget.maxLines != 1;

    final Widget editable = EditableText(
      key: _editableKey,
      controller: _editing,
      focusNode: _focusNode,
      readOnly: widget.readOnly || !widget.enabled,
      obscureText: widget.obscureText,
      autocorrect: !widget.obscureText,
      enableSuggestions: !widget.obscureText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType ??
          (widget.obscureText
              ? TextInputType.visiblePassword
              : (multiline ? TextInputType.multiline : TextInputType.text)),
      textInputAction: widget.textInputAction,
      inputFormatters: <TextInputFormatter>[
        if (widget.maxLength != null)
          LengthLimitingTextInputFormatter(widget.maxLength),
        ...?widget.inputFormatters,
      ],
      style: textStyle,
      cursorColor: resolved.cursorColor,
      backgroundCursorColor: resolved.cursorColor,
      selectionColor: resolved.selectionColor,
      undoController: _undo,
      onSubmitted: widget.onSubmitted,
      // Toolbar deliberately omitted in v0.1 — the AdaptiveTextSelectionToolbar
      // lives in Flutter's Material/Cupertino layers, which manyui's core
      // does not depend on. Keyboard shortcuts still work.
      contextMenuBuilder: null,
      rendererIgnoresPointer: false,
      enableInteractiveSelection: widget.enabled,
      autofocus: widget.autofocus,
    );

    final Widget content = Stack(
      children: <Widget>[
        // Placeholder underneath. EditableText doesn't render anything when
        // empty, so this peeks through.
        if (showPlaceholder)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                // Single-line centers vertically; multiline pins to the top so
                // the placeholder sits on the first line, matching the caret.
                alignment: multiline
                    ? AlignmentDirectional.topStart
                    : AlignmentDirectional.centerStart,
                child: Text(
                  widget.placeholder!,
                  style: textStyle.copyWith(color: resolved.placeholderColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          // Multiline: heightFactor 1 sizes this Align (and so the surrounding
          // Stack) to the editable's content height instead of filling the
          // incoming constraint, so the field grows with its line count.
          // Single-line keeps the original null (fill) so its layout is
          // byte-identical to before multiline support.
          heightFactor: multiline ? 1 : null,
          child: editable,
        ),
      ],
    );

    final List<Widget> row = <Widget>[
      if (widget.leading != null) ...<Widget>[
        IconTheme.merge(
          data: IconThemeData(color: resolved.iconColor),
          child: widget.leading!,
        ),
        SizedBox(width: resolved.decorationGap),
      ],
      Expanded(child: content),
      if (widget.trailing != null) ...<Widget>[
        SizedBox(width: resolved.decorationGap),
        IconTheme.merge(
          data: IconThemeData(color: resolved.iconColor),
          child: widget.trailing!,
        ),
      ],
    ];

    Widget surface = ConstrainedBox(
      constraints: BoxConstraints(minHeight: resolved.minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolved.backgroundColor,
          borderRadius: resolved.radius,
          border: Border.all(color: border, width: resolved.borderWidth),
        ),
        child: Padding(
          padding: resolved.padding,
          // heightFactor 1 sizes the surface to its child's height: one row for
          // single-line, the current line count for multiline. Either way the
          // field doesn't stretch to fill a taller parent (e.g. inside an
          // OverlayEntry's tall Stack slot).
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: Row(
              crossAxisAlignment:
                  multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: row,
            ),
          ),
        ),
      ),
    );

    if (!widget.enabled) {
      surface = Opacity(opacity: resolved.disabledOpacity, child: surface);
    }

    // Tapping anywhere inside the surface should route focus into the
    // EditableText. EditableText itself only catches taps inside the rendered
    // text bounds; without this, tapping the padding would do nothing.
    Widget tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled
          ? () {
              // Focuses and opens the input connection; a bare
              // requestFocus() focuses without opening it.
              _editableKey.currentState?.requestKeyboard();
            }
          : null,
      child: surface,
    );

    // Disabled fields must reject pointer events outright — otherwise
    // EditableText's own gesture detector still routes focus into the editor.
    if (!widget.enabled) {
      tappable = IgnorePointer(child: tappable);
    }

    final Widget ringed = MFocusRing(focused: _focused, child: tappable);

    return Semantics(
      textField: true,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscured: widget.obscureText,
      label: widget.semanticLabel,
      value: _editing.text,
      container: true,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.text
            : SystemMouseCursors.basic,
        child: ringed,
      ),
    );
  }
}
