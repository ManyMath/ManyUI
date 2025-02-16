import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/controller.dart';
import '../../foundation/focus_ring.dart';
import '../../foundation/input_modality.dart';
import '../../foundation/overlay_anchor.dart';
import '../../theme/theme.dart';
import '../../theme/theme_data.dart';
import 'date_field_style.dart';
import 'parse.dart';

/// A text-input date field with an optional popover calendar.
///
/// Bridges manyui's `MController<DateTime?>` to a primitive
/// [TextEditingController]; the trailing calendar-icon button opens a
/// popover calendar via [MOverlayAnchor].
///
/// Accepted typed input (no `intl` dependency):
/// ISO (`2026-05-13`), US slash (`5/13/2026`), and English month names
/// (`May 13 2026`, `13 May 2026`).
///
/// On commit (Enter or focus-loss), a successful parse normalizes the text
/// to `YYYY-MM-DD` and updates the controller.
///
/// ```dart
/// MDateField(
///   placeholder: 'YYYY-MM-DD',
///   onChanged: (DateTime? d) => debugPrint('$d'),
/// )
/// ```
class MDateField extends StatefulWidget {
  /// Builds a date field.
  const MDateField({
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
    this.error = false,
    this.modality,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  /// The state source for this field.
  ///
  /// When non-null, the caller owns the controller and is responsible for
  /// disposing it. When null, the field creates and owns one seeded with
  /// [initialValue].
  final MController<DateTime?>? controller;

  /// The seed value for the internal controller. Pass `null` to start
  /// empty.
  ///
  /// Ignored when [controller] is non-null.
  final DateTime? initialValue;

  /// Called whenever the field's parsed date changes — either through user
  /// editing, a calendar pick, or programmatic mutation of the underlying
  /// controller.
  final ValueChanged<DateTime?>? onChanged;

  /// Called when the user submits the field (typically by pressing Enter
  /// while focused).
  final ValueChanged<DateTime?>? onSubmitted;

  /// The text shown faintly inside the field when its content is empty.
  final String? placeholder;

  /// Whether the field responds to user input.
  final bool enabled;

  /// Whether the field shows its current text but rejects edits and hides
  /// the calendar.
  final bool readOnly;

  /// Whether the field is in an error state.
  ///
  /// Error rendering is purely visual (border swaps to
  /// [MDateFieldStyle.errorBorderColor]); validation is the caller's job.
  final bool error;

  /// The input modality this field should size itself for.
  final MInputModality? modality;

  /// Field-wise overrides for the theme-resolved [MDateFieldStyle].
  final MDateFieldStyleDelta? style;

  /// An optional accessibility label for the field.
  final String? semanticLabel;

  /// Whether the field should request focus on first build.
  final bool autofocus;

  /// An optional [FocusNode] the caller owns.
  final FocusNode? focusNode;

  /// Optional lower bound on selectable dates in the calendar.
  ///
  /// Days before [firstDate] still render in the grid for visual continuity
  /// but cannot be focused or selected via the popover. The text input
  /// itself does not enforce this — the caller validates after parsing.
  final DateTime? firstDate;

  /// Optional upper bound on selectable dates in the calendar.
  final DateTime? lastDate;

  @override
  State<MDateField> createState() => _MDateFieldState();
}

class _MDateFieldState extends State<MDateField> {
  late MController<DateTime?> _controller;
  bool _ownsController = false;

  late TextEditingController _editing;
  late UndoHistoryController _undo;

  FocusNode? _ownedFocusNode;
  bool _focused = false;
  bool _syncing = false;

  final MOverlayAnchorController _anchor =
      MOverlayAnchorController(debugLabel: 'MDateField popover');

  bool _open = false;
  // Year/month currently shown in the calendar header.
  late int _viewYear;
  late int _viewMonth;
  // The day the calendar's focus is on, expressed as a DateTime (UTC).
  DateTime? _focusedDay;

  FocusNode get _focusNode {
    if (widget.focusNode != null) return widget.focusNode!;
    return _ownedFocusNode ??= FocusNode(debugLabel: 'MDateField');
  }

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
    final DateTime? seed = _controller.value;
    _editing = TextEditingController(text: seed == null ? '' : formatMDate(seed));
    _editing.addListener(_onEditingChanged);
    _undo = UndoHistoryController();
    _focusNode.addListener(_onFocusNodeChanged);
    final DateTime initialView = seed ?? DateTime.utc(_today().year, _today().month, 1);
    _viewYear = initialView.year;
    _viewMonth = initialView.month;
  }

  @override
  void didUpdateWidget(covariant MDateField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
      _syncing = true;
      final DateTime? v = _controller.value;
      _editing.text = v == null ? '' : formatMDate(v);
      _syncing = false;
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusNodeChanged);
      _focusNode.addListener(_onFocusNodeChanged);
    }
  }

  void _bindController(MController<DateTime?>? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = MController<DateTime?>(widget.initialValue);
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  void _unbindController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  // Bridge: external mutation → reformat displayed text.
  void _onControllerChanged() {
    if (_syncing) {
      if (mounted) setState(() {});
      return;
    }
    final DateTime? v = _controller.value;
    final String formatted = v == null ? '' : formatMDate(v);
    if (_editing.text != formatted) {
      _syncing = true;
      _editing.text = formatted;
      _syncing = false;
    }
    if (mounted) setState(() {});
  }

  // Bridge: typing → reparse → update controller (only when typed text
  // produces a different parsed date).
  void _onEditingChanged() {
    if (_syncing) {
      if (mounted) setState(() {});
      return;
    }
    final DateTime? parsed = parseMDate(_editing.text);
    if (!_sameDay(_controller.value, parsed)) {
      _syncing = true;
      _controller.value = parsed;
      _syncing = false;
      widget.onChanged?.call(parsed);
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
    _anchor.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _withinBounds(DateTime day) {
    final DateTime? lo = widget.firstDate;
    final DateTime? hi = widget.lastDate;
    if (lo != null && day.isBefore(DateTime.utc(lo.year, lo.month, lo.day))) {
      return false;
    }
    if (hi != null && day.isAfter(DateTime.utc(hi.year, hi.month, hi.day))) {
      return false;
    }
    return true;
  }

  DateTime _today() {
    final DateTime n = DateTime.now();
    return DateTime.utc(n.year, n.month, n.day);
  }

  void _onSubmitted(String _) {
    // Re-parse against the latest text, then either normalize to canonical
    // form (parse succeeded) or leave it alone (parse failed).
    final DateTime? parsed = parseMDate(_editing.text);
    if (parsed != null) {
      final String canonical = formatMDate(parsed);
      if (_editing.text != canonical) {
        _syncing = true;
        _editing.text = canonical;
        _syncing = false;
      }
      if (!_sameDay(_controller.value, parsed)) {
        _syncing = true;
        _controller.value = parsed;
        _syncing = false;
        widget.onChanged?.call(parsed);
      }
    }
    widget.onSubmitted?.call(_controller.value);
  }

  void _openPopover() {
    if (!widget.enabled || widget.readOnly || _open) return;
    final DateTime? selected = _controller.value;
    final DateTime focused = selected ?? _today();
    setState(() {
      _open = true;
      _viewYear = focused.year;
      _viewMonth = focused.month;
      _focusedDay = DateTime.utc(focused.year, focused.month, focused.day);
    });
    _anchor.open(anchorFocusNode: _focusNode);
  }

  void _closePopover({DateTime? committedValue}) {
    if (!_open) return;
    if (committedValue != null && !_sameDay(_controller.value, committedValue)) {
      _syncing = true;
      _controller.value = committedValue;
      _editing.text = formatMDate(committedValue);
      _syncing = false;
      widget.onChanged?.call(committedValue);
    }
    setState(() {
      _open = false;
      _focusedDay = null;
    });
    _anchor.close();
  }

  void _shiftMonth(int delta) {
    int y = _viewYear;
    int m = _viewMonth + delta;
    while (m < 1) {
      m += 12;
      y -= 1;
    }
    while (m > 12) {
      m -= 12;
      y += 1;
    }
    setState(() {
      _viewYear = y;
      _viewMonth = m;
      // Anchor focus to the same day-of-month if possible, otherwise clamp
      // to the last day of the new month.
      final int existingDay = _focusedDay?.day ?? 1;
      final int lastOfMonth = _daysInMonth(y, m);
      final int day = existingDay > lastOfMonth ? lastOfMonth : existingDay;
      _focusedDay = DateTime.utc(y, m, day);
    });
  }

  void _moveFocusedDay(int dayDelta) {
    final DateTime base = _focusedDay ?? _today();
    final DateTime next = DateTime.utc(base.year, base.month, base.day + dayDelta);
    setState(() {
      _focusedDay = next;
      if (next.year != _viewYear || next.month != _viewMonth) {
        _viewYear = next.year;
        _viewMonth = next.month;
      }
    });
  }

  int _daysInMonth(int year, int month) {
    return DateTime.utc(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1)
        .subtract(const Duration(days: 1))
        .day;
  }

  KeyEventResult _onPopoverKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _closePopover();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveFocusedDay(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveFocusedDay(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocusedDay(-7);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocusedDay(7);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _shiftMonth(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _shiftMonth(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      final DateTime base = _focusedDay ?? _today();
      setState(() => _focusedDay = DateTime.utc(base.year, base.month, 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      final DateTime base = _focusedDay ?? _today();
      setState(() => _focusedDay =
          DateTime.utc(base.year, base.month, _daysInMonth(base.year, base.month)));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      final DateTime? d = _focusedDay;
      if (d != null && _withinBounds(d)) {
        _closePopover(committedValue: d);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final MThemeData theme = MTheme.of(context);
    final MInputModality resolvedModality =
        MInputModalityScope.resolve(context, widget.modality);
    final MDateFieldStyle resolved = theme.dateField
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

    final TextStyle textStyle =
        resolved.textStyle.copyWith(color: theme.colors.foreground);

    final bool empty = _editing.text.isEmpty;
    final bool showPlaceholder =
        empty && (widget.placeholder?.isNotEmpty ?? false);

    final Widget editable = EditableText(
      controller: _editing,
      focusNode: _focusNode,
      readOnly: widget.readOnly || !widget.enabled,
      maxLines: 1,
      keyboardType: TextInputType.datetime,
      style: textStyle,
      cursorColor: resolved.cursorColor,
      backgroundCursorColor: resolved.cursorColor,
      selectionColor: resolved.selectionColor,
      undoController: _undo,
      onSubmitted: _onSubmitted,
      contextMenuBuilder: null,
      rendererIgnoresPointer: false,
      enableInteractiveSelection: widget.enabled,
      autofocus: widget.autofocus,
    );

    final Widget content = Stack(
      children: <Widget>[
        if (showPlaceholder)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
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
          child: editable,
        ),
      ],
    );

    final Widget calendarToggle = _CalendarIconButton(
      color: resolved.iconColor,
      onTap: widget.enabled && !widget.readOnly
          ? () => _open ? _closePopover() : _openPopover()
          : null,
    );

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
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: content),
                SizedBox(width: resolved.decorationGap),
                calendarToggle,
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.enabled) {
      surface = Opacity(opacity: resolved.disabledOpacity, child: surface);
    }

    Widget tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled
          ? () {
              if (!_focusNode.hasFocus) _focusNode.requestFocus();
            }
          : null,
      child: surface,
    );

    if (!widget.enabled) {
      tappable = IgnorePointer(child: tappable);
    }

    final Widget ringed = MFocusRing(focused: _focused, child: tappable);

    final Widget portal = MOverlayAnchor(
      controller: _anchor,
      anchor: ringed,
      overlayOffset: Offset(0, resolved.minHeight + resolved.popoverGap),
      onDismiss: _closePopover,
      onKeyEvent: _onPopoverKey,
      overlayBuilder: (BuildContext overlayContext) =>
          _buildOverlay(overlayContext, resolved, theme),
    );

    return Semantics(
      textField: true,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      label: widget.semanticLabel,
      value: _editing.text,
      container: true,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.text
            : SystemMouseCursors.basic,
        child: portal,
      ),
    );
  }

  Widget _buildOverlay(
    BuildContext overlayContext,
    MDateFieldStyle s,
    MThemeData theme,
  ) {
    final DateTime? selected = _controller.value;

    final Widget header = _buildHeader(s);
    final Widget weekdays = _buildWeekdayRow(s);
    final Widget grid = _buildGrid(s, selected);

    // The calendar's natural width is 7 cells wide. Don't constrain to
    // _anchorWidth — a narrow input shouldn't squash the calendar.
    final Widget popoverBody = DecoratedBox(
      decoration: BoxDecoration(
        color: s.popoverBackgroundColor,
        borderRadius: s.popoverRadius,
        border: Border.all(
          color: s.popoverBorderColor,
          width: s.popoverBorderWidth,
        ),
        boxShadow: s.popoverElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: s.popoverShadowColor,
                  blurRadius: s.popoverElevation,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: s.popoverPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            const SizedBox(height: 4),
            weekdays,
            const SizedBox(height: 2),
            grid,
          ],
        ),
      ),
    );

    return IntrinsicWidth(child: popoverBody);
  }

  Widget _buildHeader(MDateFieldStyle s) {
    final String title = '${monthName(_viewMonth)} $_viewYear';
    return Row(
      children: <Widget>[
        _HeaderChevron(
          direction: -1,
          color: s.popoverHeaderForegroundColor,
          onTap: () => _shiftMonth(-1),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: s.popoverHeaderTextStyle
                  .copyWith(color: s.popoverHeaderForegroundColor),
            ),
          ),
        ),
        _HeaderChevron(
          direction: 1,
          color: s.popoverHeaderForegroundColor,
          onTap: () => _shiftMonth(1),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(MDateFieldStyle s) {
    return Row(
      children: <Widget>[
        for (int wd = DateTime.monday; wd <= DateTime.sunday; wd++)
          SizedBox(
            width: s.cellSize,
            height: s.cellSize * 0.6,
            child: Center(
              child: Text(
                shortWeekdayName(wd),
                style: s.popoverWeekdayTextStyle
                    .copyWith(color: s.popoverWeekdayColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid(MDateFieldStyle s, DateTime? selected) {
    final DateTime first = DateTime.utc(_viewYear, _viewMonth, 1);
    // Monday-start grid. DateTime.weekday: 1 = Monday, 7 = Sunday.
    final int leading = first.weekday - DateTime.monday;
    final int daysInThis = _daysInMonth(_viewYear, _viewMonth);
    // Pad to a multiple of 7 — typically 5 or 6 rows.
    final int totalCells = (((leading + daysInThis) + 6) ~/ 7) * 7;

    final List<Widget> rows = <Widget>[];
    for (int row = 0; row < totalCells ~/ 7; row++) {
      final List<Widget> cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final int idx = row * 7 + col;
        final int dayOffset = idx - leading;
        final DateTime day = first.add(Duration(days: dayOffset));
        final bool inMonth = dayOffset >= 0 && dayOffset < daysInThis;
        final bool isFocused = _focusedDay != null && _sameDay(_focusedDay, day);
        final bool isSelected = _sameDay(selected, day);
        final bool allowed = _withinBounds(day);
        cells.add(_DayCell(
          day: day,
          inMonth: inMonth,
          focused: isFocused,
          selected: isSelected,
          enabled: allowed,
          style: s,
          onTap: () {
            if (!allowed) return;
            _closePopover(committedValue: day);
          },
          onHover: () {
            if (!allowed) return;
            if (!_sameDay(_focusedDay, day)) {
              setState(() => _focusedDay = day);
            }
          },
        ));
      }
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: cells,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

class _CalendarIconButton extends StatelessWidget {
  const _CalendarIconButton({required this.color, required this.onTap});
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget icon = SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(painter: _CalendarPainter(color: color)),
    );
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: icon,
        ),
      ),
    );
  }
}

class _CalendarPainter extends CustomPainter {
  const _CalendarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double w = size.width;
    final double h = size.height;
    final RRect body = RRect.fromLTRBR(
      w * 0.1,
      h * 0.2,
      w * 0.9,
      h * 0.9,
      const Radius.circular(1.5),
    );
    canvas.drawRRect(body, stroke);
    // Top binder line.
    canvas.drawLine(
      Offset(w * 0.1, h * 0.4),
      Offset(w * 0.9, h * 0.4),
      stroke,
    );
    // Two binder rings.
    canvas.drawLine(Offset(w * 0.3, h * 0.1), Offset(w * 0.3, h * 0.3), stroke);
    canvas.drawLine(Offset(w * 0.7, h * 0.1), Offset(w * 0.7, h * 0.3), stroke);
  }

  @override
  bool shouldRepaint(_CalendarPainter old) => old.color != color;
}

class _HeaderChevron extends StatelessWidget {
  const _HeaderChevron({
    required this.direction,
    required this.color,
    required this.onTap,
  });

  /// `-1` for left, `1` for right.
  final int direction;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: _ChevronPainter(color: color, direction: direction),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.direction});
  final Color color;
  final int direction;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double w = size.width;
    final double h = size.height;
    final Path path = Path();
    if (direction < 0) {
      path
        ..moveTo(w * 0.6, h * 0.25)
        ..lineTo(w * 0.4, h * 0.5)
        ..lineTo(w * 0.6, h * 0.75);
    } else {
      path
        ..moveTo(w * 0.4, h * 0.25)
        ..lineTo(w * 0.6, h * 0.5)
        ..lineTo(w * 0.4, h * 0.75);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.color != color || old.direction != direction;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.focused,
    required this.selected,
    required this.enabled,
    required this.style,
    required this.onTap,
    required this.onHover,
  });

  final DateTime day;
  final bool inMonth;
  final bool focused;
  final bool selected;
  final bool enabled;
  final MDateFieldStyle style;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? style.cellSelectedForegroundColor
        : (inMonth
            ? style.cellForegroundColor
            : style.cellMutedForegroundColor);
    final Color? background = selected
        ? style.cellSelectedBackgroundColor
        : (focused ? style.cellFocusedBackgroundColor : null);

    final Widget label = Text(
      day.day.toString(),
      style: style.cellTextStyle.copyWith(color: foreground),
    );

    Widget cell = SizedBox(
      width: style.cellSize,
      height: style.cellSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: style.cellRadius,
        ),
        child: Center(child: label),
      ),
    );

    if (!enabled) {
      cell = Opacity(opacity: style.disabledOpacity, child: cell);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: '${monthName(day.month)} ${day.day}, ${day.year}',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (enabled) onHover();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: cell,
        ),
      ),
    );
  }
}
