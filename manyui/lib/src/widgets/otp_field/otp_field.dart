import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'otp_field_style.dart';

/// A one-time-password / PIN field rendered as a row of single-character
/// cells.
///
/// Each cell owns its own [FocusNode] and 1-char [TextEditingController];
/// the assembled string is held in an `MController<String>`. Typing
/// auto-advances focus; Backspace on an empty cell steps back and clears;
/// Arrow keys move between cells; pasting distributes characters left-to-right.
///
/// Cells reject input outside [inputFilter] (default: `[0-9]`); the same
/// filter applies to typed input and paste characters.
///
/// ```dart
/// MOTPField(
///   length: 6,
///   onCompleted: (String code) => verify(code),
/// )
/// ```
class MOTPField extends StatefulWidget {
  /// Builds an OTP field.
  const MOTPField({
    this.controller,
    this.initialValue = '',
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.readOnly = false,
    this.error = false,
    this.obscureText = false,
    this.obscureCharacter = '•',
    this.inputFilter,
    this.keyboardType,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    super.key,
  }) : assert(length > 0, 'length must be at least 1');

  /// The state source for this field, holding the assembled string.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the field creates and owns one seeded with
  /// [initialValue].
  ///
  /// Mutating the controller from outside the widget rewrites the cell
  /// contents on the next frame. If the new value is longer than [length]
  /// it's truncated; shorter values pad the remaining cells with empty.
  final MController<String>? controller;

  /// The seed value for the internal controller. Trimmed to [length].
  ///
  /// Ignored when [controller] is non-null.
  final String initialValue;

  /// How many cells (and therefore how many characters) the field accepts.
  final int length;

  /// Called whenever the assembled value changes — through typing, paste,
  /// or programmatic mutation of the underlying controller.
  final ValueChanged<String>? onChanged;

  /// Called when the last cell is filled — i.e. the assembled value has
  /// exactly [length] characters. Fires once per transition into the
  /// completed state.
  final ValueChanged<String>? onCompleted;

  /// Whether the field responds to user input.
  final bool enabled;

  /// Whether the field shows its current contents but rejects edits.
  final bool readOnly;

  /// Whether the field is in an error state.
  ///
  /// Error rendering is purely visual (every cell's border swaps to
  /// [MOTPFieldStyle.cellErrorBorderColor]); validation is the caller's
  /// responsibility.
  final bool error;

  /// Whether each character is rendered as [obscureCharacter] (for secret
  /// PINs).
  final bool obscureText;

  /// The single character to render in each cell when [obscureText] is
  /// true. Defaults to a bullet.
  final String obscureCharacter;

  /// The character class accepted by every cell. Anything outside this
  /// pattern is rejected by the per-cell input formatter. Defaults to
  /// digits 0–9.
  final RegExp? inputFilter;

  /// The keyboard variant the OS should show on mobile.
  ///
  /// When null, the default is [TextInputType.number] for digit-only
  /// filters and [TextInputType.text] for everything else.
  final TextInputType? keyboardType;

  /// The input modality this field should size itself for.
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MOTPFieldStyle].
  final MOTPFieldStyleDelta? style;

  /// An optional accessibility label for the field.
  ///
  /// Pair with an `MLabel` for visible labels.
  final String? semanticLabel;

  /// Whether the first cell should request focus on first build.
  final bool autofocus;

  @override
  State<MOTPField> createState() => _MOTPFieldState();
}

class _MOTPFieldState extends State<MOTPField> {
  late MController<String> _controller;
  bool _ownsController = false;

  // One Flutter-primitive TextEditingController per cell. Always owned by
  // the widget — the parent MController<String> holds the assembled value
  // and we re-derive cell text from it whenever it changes externally.
  late List<TextEditingController> _cellEditing;
  late List<FocusNode> _cellFocus;
  late List<VoidCallback> _editingListeners;
  late List<VoidCallback> _focusListeners;
  late UndoHistoryController _undo;

  int _focusedCell = -1;
  bool _completed = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    _buildCells(_controller.value);
  }

  @override
  void didUpdateWidget(covariant MOTPField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
      _syncCellsFromValue(_controller.value);
    }
    if (old.length != widget.length) {
      _disposeCells();
      _buildCells(_normalizeValue(_controller.value));
    }
  }

  void _bindController(MController<String>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<String>(_normalizeValue(widget.initialValue));
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  String _normalizeValue(String raw) {
    if (raw.length > widget.length) return raw.substring(0, widget.length);
    return raw;
  }

  void _buildCells(String seed) {
    final String normalized = _normalizeValue(seed);
    _cellEditing = <TextEditingController>[];
    _cellFocus = <FocusNode>[];
    _editingListeners = <VoidCallback>[];
    _focusListeners = <VoidCallback>[];
    for (int i = 0; i < widget.length; i++) {
      final String ch = i < normalized.length ? normalized[i] : '';
      final TextEditingController c = TextEditingController(text: ch);
      final int index = i;
      void editingListener() => _onCellEditingChanged(index);
      c.addListener(editingListener);
      _cellEditing.add(c);
      _editingListeners.add(editingListener);

      final FocusNode n = FocusNode(debugLabel: 'MOTPField cell $i');
      void focusListener() => _onCellFocusChanged(index);
      n.addListener(focusListener);
      _cellFocus.add(n);
      _focusListeners.add(focusListener);
    }
    _undo = UndoHistoryController();
    _completed = normalized.length == widget.length;
  }

  void _disposeCells() {
    for (int i = 0; i < _cellEditing.length; i++) {
      _cellEditing[i].removeListener(_editingListeners[i]);
      _cellEditing[i].dispose();
    }
    for (int i = 0; i < _cellFocus.length; i++) {
      _cellFocus[i].removeListener(_focusListeners[i]);
      _cellFocus[i].dispose();
    }
    _undo.dispose();
  }

  @override
  void dispose() {
    _disposeCells();
    _unbindController();
    super.dispose();
  }

  String _assembled() {
    final StringBuffer b = StringBuffer();
    for (final TextEditingController c in _cellEditing) {
      final String t = c.text;
      if (t.isEmpty) {
        break;
      }
      // Defensive: cells normally hold exactly one character after the
      // formatter+listener run, but mid-paste they can briefly hold more.
      b.write(t.characters.first);
    }
    return b.toString();
  }

  void _syncCellsFromValue(String value) {
    final String normalized = _normalizeValue(value);
    _syncing = true;
    for (int i = 0; i < widget.length; i++) {
      final String ch = i < normalized.length ? normalized[i] : '';
      if (_cellEditing[i].text != ch) {
        _cellEditing[i].text = ch;
      }
    }
    _syncing = false;
  }

  void _onControllerChanged() {
    if (_syncing) {
      if (mounted) setState(() {});
      return;
    }
    final String next = _normalizeValue(_controller.value);
    if (_someCellDiffersFrom(next)) {
      _syncCellsFromValue(next);
    }
    if (mounted) setState(() {});
  }

  bool _someCellDiffersFrom(String value) {
    for (int i = 0; i < widget.length; i++) {
      final String want = i < value.length ? value[i] : '';
      if (_cellEditing[i].text != want) return true;
    }
    return false;
  }

  void _onCellEditingChanged(int index) {
    if (_syncing) {
      if (mounted) setState(() {});
      return;
    }
    final String raw = _cellEditing[index].text;
    if (raw.characters.length > 1) {
      // Pasted (or otherwise multi-char). Distribute across cells starting
      // at this index. The originating cell keeps the first character;
      // overflow goes into the rest.
      _distributePaste(index, raw);
      return;
    }
    final String assembled = _assembled();
    if (_controller.value != assembled) {
      _syncing = true;
      _controller.value = assembled;
      _syncing = false;
      widget.onChanged?.call(assembled);
    }
    // Auto-advance when a cell goes from empty to one character.
    if (raw.isNotEmpty && index < widget.length - 1) {
      _cellFocus[index + 1].requestFocus();
    }
    _maybeFireCompleted(assembled);
    if (mounted) setState(() {});
  }

  void _onCellFocusChanged(int index) {
    final bool gained = _cellFocus[index].hasFocus;
    if (gained && _focusedCell != index) {
      setState(() => _focusedCell = index);
    } else if (!gained && _focusedCell == index && !_anyCellFocused()) {
      setState(() => _focusedCell = -1);
    }
  }

  bool _anyCellFocused() {
    for (final FocusNode n in _cellFocus) {
      if (n.hasFocus) return true;
    }
    return false;
  }

  void _distributePaste(int startIndex, String raw) {
    // Filter the pasted text through the same rule per-cell formatters use,
    // so an alphanumeric paste into a digits-only field gets stripped to
    // digits before distribution. Iterating .characters preserves grapheme
    // clusters, matching what a single typed character would be.
    final RegExp filter = widget.inputFilter ?? _defaultFilter;
    final List<String> chars = <String>[];
    for (final String g in raw.characters) {
      if (filter.hasMatch(g)) chars.add(g);
    }

    _syncing = true;
    // Clamp the originating cell to its single char before we start
    // distributing, in case nothing matched the filter.
    if (chars.isEmpty) {
      _cellEditing[startIndex].text = '';
    }
    for (int offset = 0; offset < chars.length; offset++) {
      final int target = startIndex + offset;
      if (target >= widget.length) break;
      _cellEditing[target].text = chars[offset];
    }
    _syncing = false;

    if (chars.isEmpty) {
      final String assembled = _assembled();
      if (_controller.value != assembled) {
        _syncing = true;
        _controller.value = assembled;
        _syncing = false;
        widget.onChanged?.call(assembled);
      }
      if (mounted) setState(() {});
      return;
    }

    // Focus moves to the cell after the last one we filled, or stays on
    // the final cell if we filled to the end.
    final int landed = startIndex + chars.length - 1;
    final int focusTarget =
        landed >= widget.length - 1 ? widget.length - 1 : landed + 1;
    _cellFocus[focusTarget].requestFocus();

    final String assembled = _assembled();
    if (_controller.value != assembled) {
      _syncing = true;
      _controller.value = assembled;
      _syncing = false;
      widget.onChanged?.call(assembled);
    }
    _maybeFireCompleted(assembled);
    if (mounted) setState(() {});
  }

  void _maybeFireCompleted(String assembled) {
    final bool nowComplete = assembled.length == widget.length;
    if (nowComplete && !_completed) {
      _completed = true;
      widget.onCompleted?.call(assembled);
    } else if (!nowComplete && _completed) {
      _completed = false;
    }
  }

  KeyEventResult _onCellKey(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowLeft) {
      if (index > 0) _cellFocus[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      if (index < widget.length - 1) _cellFocus[index + 1].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _cellFocus[0].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _cellFocus[widget.length - 1].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      // Backspace on an empty cell jumps to the previous cell and clears
      // it (matches the §5 contract). When the cell holds a character,
      // let EditableText handle the deletion itself.
      if (_cellEditing[index].text.isEmpty && index > 0) {
        final int prev = index - 1;
        _cellFocus[prev].requestFocus();
        if (_cellEditing[prev].text.isNotEmpty) {
          _cellEditing[prev].text = '';
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MOTPFieldStyle resolved = theme.otpField
        .resolve(
          modality: resolvedModality,
          colors: theme.colors,
          typography: theme.typography.inheritFromContext(context),
          radius: theme.radius,
        )
        .applyDelta(widget.style);

    final RegExp filter = widget.inputFilter ?? _defaultFilter;
    final TextInputType keyboard = widget.keyboardType ??
        (filter == _defaultFilter
            ? TextInputType.number
            : TextInputType.text);

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < widget.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: resolved.cellGap));
      }
      children.add(_OTPCell(
        index: i,
        length: widget.length,
        editing: _cellEditing[i],
        focus: _cellFocus[i],
        undo: _undo,
        style: resolved,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        error: widget.error,
        focused: _focusedCell == i,
        obscureText: widget.obscureText,
        obscureCharacter: widget.obscureCharacter,
        filter: filter,
        keyboardType: keyboard,
        autofocus: widget.autofocus && i == 0,
        onKey: (FocusNode node, KeyEvent event) => _onCellKey(i, node, event),
      ));
    }

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );

    if (!widget.enabled) {
      row = Opacity(opacity: resolved.disabledOpacity, child: row);
    }

    final String semanticValue = widget.obscureText ? '' : _assembled();

    return Semantics(
      textField: true,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      label: widget.semanticLabel,
      value: semanticValue,
      container: true,
      child: FocusTraversalGroup(child: row),
    );
  }
}

/// One cell in an [MOTPField]. Wraps an [EditableText] in a [Focus] node
/// that intercepts arrow / Home / End / Backspace keys (routed up to the
/// parent's [_onCellKey]) before they reach the editor. Typing characters
/// passes straight through to [EditableText].
class _OTPCell extends StatelessWidget {
  const _OTPCell({
    required this.index,
    required this.length,
    required this.editing,
    required this.focus,
    required this.undo,
    required this.style,
    required this.enabled,
    required this.readOnly,
    required this.error,
    required this.focused,
    required this.obscureText,
    required this.obscureCharacter,
    required this.filter,
    required this.keyboardType,
    required this.autofocus,
    required this.onKey,
  });

  final int index;
  final int length;
  final TextEditingController editing;
  final FocusNode focus;
  final UndoHistoryController undo;
  final MOTPFieldStyle style;
  final bool enabled;
  final bool readOnly;
  final bool error;
  final bool focused;
  final bool obscureText;
  final String obscureCharacter;
  final RegExp filter;
  final TextInputType keyboardType;
  final bool autofocus;
  final FocusOnKeyEventCallback onKey;

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final bool filled = editing.text.isNotEmpty;
    final Color border = error
        ? style.cellErrorBorderColor
        : focused
            ? style.cellFocusedBorderColor
            : filled
                ? style.cellFilledBorderColor
                : style.cellBorderColor;

    final TextStyle textStyle = style.textStyle.copyWith(
      color: theme.colors.foreground,
    );

    final Widget editable = EditableText(
      controller: editing,
      focusNode: focus,
      readOnly: readOnly || !enabled,
      obscureText: obscureText,
      obscuringCharacter: obscureCharacter.isEmpty ? '•' : obscureCharacter,
      autocorrect: false,
      enableSuggestions: false,
      maxLines: 1,
      keyboardType: keyboardType,
      textInputAction: index == length - 1
          ? TextInputAction.done
          : TextInputAction.next,
      textAlign: TextAlign.center,
      inputFormatters: <TextInputFormatter>[
        _OTPCellFormatter(filter),
      ],
      style: textStyle,
      cursorColor: style.cursorColor,
      backgroundCursorColor: style.cursorColor,
      selectionColor: style.selectionColor,
      undoController: undo,
      contextMenuBuilder: null,
      rendererIgnoresPointer: false,
      enableInteractiveSelection: enabled,
      autofocus: autofocus,
    );

    // The Focus(parentNode: focus, ...) wrapper inserts a navigation-focus
    // node above EditableText's own focusNode. The cell's `focus` parameter
    // is still the EditableText's focusNode, so EditableText keeps its
    // keyboard connection; the wrapping Focus only gets called for keys
    // that would otherwise route up the focus chain. We intercept arrows /
    // Home / End / Backspace here before they reach EditableText.
    final Widget keyTrap = Focus(
      onKeyEvent: onKey,
      // Don't take focus or change traversal — this Focus is purely a
      // key-event hook.
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: true,
      child: editable,
    );

    final Widget cell = SizedBox(
      width: style.cellSize,
      height: style.cellSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.cellBackgroundColor,
          borderRadius: style.cellRadius,
          border: Border.all(color: border, width: style.cellBorderWidth),
        ),
        child: Padding(
          padding: style.cellPadding,
          child: Align(
            alignment: Alignment.center,
            widthFactor: 1,
            heightFactor: 1,
            child: keyTrap,
          ),
        ),
      ),
    );

    Widget tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              if (!focus.hasFocus) focus.requestFocus();
              // Select the cell's contents so the next typed character
              // replaces what's already there instead of producing a
              // 2-char value the formatter has to clamp every keystroke.
              editing.selection = TextSelection(
                baseOffset: 0,
                extentOffset: editing.text.length,
              );
            }
          : null,
      child: cell,
    );

    if (!enabled) {
      tappable = IgnorePointer(child: tappable);
    }

    final Widget ringed = MFocusRing(focused: focused, child: tappable);

    return Semantics(
      textField: true,
      enabled: enabled,
      readOnly: readOnly,
      label: 'OTP digit ${index + 1} of $length',
      value: obscureText ? '' : editing.text,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.text : SystemMouseCursors.basic,
        child: ringed,
      ),
    );
  }
}

/// Per-cell formatter: rejects characters not matching [filter]. Pastes
/// that contain a mix of valid and invalid characters get filtered down to
/// the valid ones; the resulting (possibly multi-character) value is then
/// distributed across the row by the parent's editing-listener.
class _OTPCellFormatter extends TextInputFormatter {
  _OTPCellFormatter(this.filter);
  final RegExp filter;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final StringBuffer b = StringBuffer();
    for (final String g in newValue.text.characters) {
      if (filter.hasMatch(g)) b.write(g);
    }
    final String filtered = b.toString();
    if (filtered.isEmpty) return oldValue;
    if (filtered == newValue.text) return newValue;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

/// Default character class: ASCII digits 0–9.
final RegExp _defaultFilter = RegExp(r'[0-9]');
