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
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints = const <String>[],
    this.inputFormatters,
    this.error = false,
    this.helperText,
    this.errorText,
    this.leading,
    this.trailing,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  }) : assert(
         maxLines == null || maxLines >= 1,
         'maxLines must be null (unbounded) or >= 1',
       ),
       assert(
         maxLines == 1 || !obscureText,
         'obscureText only makes sense for a single-line field',
       );

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

  /// The maximum number of lines the field grows to before scrolling.
  ///
  /// Defaults to 1 (single-line). Pass null for an unbounded multiline field,
  /// or an integer for a multiline field capped at that many visual lines.
  /// Mutually exclusive with [obscureText] (asserted).
  final int? maxLines;

  /// The minimum number of lines the field occupies before it starts
  /// growing. Only meaningful when [maxLines] is null or greater than 1;
  /// defaults to 1 line's worth of height via [MTextFieldStyle.minHeight]
  /// when null.
  final int? minLines;

  /// The keyboard variant the OS should show on mobile. Maps to
  /// [TextInputType] — pass `TextInputType.emailAddress` for an email
  /// keyboard, etc.
  final TextInputType? keyboardType;

  /// The action button the OS should show on the keyboard's bottom-right
  /// (e.g. `TextInputAction.search`, `TextInputAction.done`).
  final TextInputAction? textInputAction;

  /// Semantic roles used by platform autofill services and password managers.
  ///
  /// Fields that belong together should be wrapped in an [AutofillGroup].
  /// An empty iterable, the default, supplies no semantic role. Passing null
  /// disables the field's autofill client entirely.
  final Iterable<String>? autofillHints;

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

  /// A helper line rendered below the field in its idle state.
  ///
  /// Replaced by [errorText] whenever [error] is true and [errorText] is
  /// non-null, so callers can supply both and let the field switch between
  /// them instead of swapping the child themselves.
  final String? helperText;

  /// An error line rendered below the field, shown in place of [helperText]
  /// while [error] is true.
  final String? errorText;

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
    final MInputModality resolvedModality = MInputModalityScope.resolve(
      context,
      widget.modality,
    );
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

    final Widget editable = Semantics(
      label: widget.semanticLabel,
      enabled: widget.enabled,
      child: EditableText(
        controller: _editing,
        focusNode: _focusNode,
        readOnly: widget.readOnly || !widget.enabled,
        obscureText: widget.obscureText,
        autocorrect: !widget.obscureText,
        enableSuggestions: !widget.obscureText,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        keyboardType:
            widget.keyboardType ??
            (widget.obscureText
                ? TextInputType.visiblePassword
                : TextInputType.text),
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
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
        // Toolbar omitted in v0.1 — the AdaptiveTextSelectionToolbar
        // lives in Flutter's Material/Cupertino layers, which manyui's core
        // does not depend on. Keyboard shortcuts still work.
        contextMenuBuilder: null,
        rendererIgnoresPointer: false,
        enableInteractiveSelection: widget.enabled,
        autofocus: widget.autofocus,
      ),
    );

    final bool multiline = widget.maxLines != 1;
    final AlignmentDirectional textAlignment = multiline
        ? AlignmentDirectional.topStart
        : AlignmentDirectional.centerStart;

    final Widget content = Stack(
      children: <Widget>[
        // Placeholder underneath. EditableText doesn't render anything when
        // empty, so this peeks through.
        if (showPlaceholder)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: textAlignment,
                child: ExcludeSemantics(
                  child: Text(
                    widget.placeholder!,
                    style: textStyle.copyWith(color: resolved.placeholderColor),
                    maxLines: multiline ? null : 1,
                    overflow: multiline ? null : TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        Align(alignment: textAlignment, child: editable),
      ],
    );

    // Single-line decorations use the field's full inner height. Keep the
    // vertical inset around the editable content itself so a practical icon
    // button does not add its height *plus* the text padding to the surface.
    // Multiline decorations retain the original top-aligned inset.
    final EdgeInsets editablePadding = multiline
        ? EdgeInsets.zero
        : EdgeInsets.only(
            top: resolved.padding.top,
            bottom: resolved.padding.bottom,
          );
    final EdgeInsets surfacePadding = multiline
        ? resolved.padding
        : EdgeInsets.only(
            left: resolved.padding.left,
            right: resolved.padding.right,
          );

    final List<Widget> row = <Widget>[
      if (widget.leading != null) ...<Widget>[
        IconTheme.merge(
          data: IconThemeData(color: resolved.iconColor),
          child: widget.leading!,
        ),
        SizedBox(width: resolved.decorationGap),
      ],
      Expanded(
        child: Padding(padding: editablePadding, child: content),
      ),
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
          padding: surfacePadding,
          // heightFactor: 1 collapses the surface to its row height so the
          // field doesn't stretch vertically when its parent is taller than
          // minHeight (e.g. inside an OverlayEntry's tall Stack slot).
          // Multiline fields align their row to the top instead of center so
          // leading/trailing decorations sit next to the first line rather
          // than stretching to the field's full grown height.
          child: Align(
            alignment: multiline
                ? AlignmentDirectional.topStart
                : AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: multiline ? null : 1,
            child: Row(
              crossAxisAlignment: multiline
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
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
              if (!_focusNode.hasFocus) _focusNode.requestFocus();
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

    final Widget field = MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.text
          : SystemMouseCursors.basic,
      child: ringed,
    );

    // errorText takes over from helperText whenever the field is flagged in
    // error and an errorText was supplied, so a caller can pass both
    // and let the field switch rather than swapping the child itself.
    final String? footer = (widget.error && widget.errorText != null)
        ? widget.errorText
        : widget.helperText;
    if (footer == null) {
      return field;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        field,
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            footer,
            style: theme.typography.caption.copyWith(
              color: widget.error
                  ? resolved.errorBorderColor
                  : theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
