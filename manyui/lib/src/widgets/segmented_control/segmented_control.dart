import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../button/button.dart';
import '../button/button_style.dart';

/// One option in an [MSegmentedControl].
@immutable
class MSegmentedItem<T> {
  /// Builds a segmented-control item.
  const MSegmentedItem({
    required this.value,
    required this.label,
    this.enabled = true,
    this.semanticLabel,
  });

  /// Value passed to [MSegmentedControl.onChanged] when this item is selected.
  final T value;

  /// Visible item label.
  final String label;

  /// Whether this segment can be selected.
  final bool enabled;

  /// Optional accessibility label for this segment.
  final String? semanticLabel;
}

/// A compact mutually-exclusive mode picker.
///
/// Use segmented controls for small mode sets where every option should remain
/// visible, such as editor modes, time ranges, or display density.
class MSegmentedControl<T> extends StatelessWidget {
  /// Builds a segmented control.
  const MSegmentedControl({
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.size = MButtonSize.sm,
    this.fullWidth = false,
    super.key,
  });

  /// Options in visual order.
  final List<MSegmentedItem<T>> items;

  /// Currently selected value.
  final T value;

  /// Called when the user selects an enabled item.
  final ValueChanged<T> onChanged;

  /// Whether the entire control responds to interaction.
  final bool enabled;

  /// Segment hit-target and text scale.
  final MButtonSize size;

  /// Whether each segment should expand to share all available width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final radius = BorderRadius.circular(theme.radius);

    final children = <Widget>[];
    for (var index = 0; index < items.length; index += 1) {
      if (index > 0) {
        children.add(Container(width: 1, color: theme.colors.border));
      }
      final segment = _Segment<T>(
        item: items[index],
        selected: items[index].value == value,
        enabled: enabled && items[index].enabled,
        size: size,
        onChanged: onChanged,
      );
      children.add(fullWidth ? Expanded(child: segment) : segment);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.size,
    required this.onChanged,
  });

  final MSegmentedItem<T> item;
  final bool selected;
  final bool enabled;
  final MButtonSize size;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: item.semanticLabel ?? item.label,
      onTap: enabled ? () => onChanged(item.value) : null,
      selected: selected,
      child: ExcludeSemantics(
        child: MButton(
          variant: selected ? MButtonVariant.secondary : MButtonVariant.ghost,
          size: size,
          style: const MButtonStyleDelta(
            borderColor: Color(0x00000000),
            borderWidth: 0,
            radius: BorderRadius.zero,
          ),
          onPressed: enabled ? () => onChanged(item.value) : null,
          child: Text(item.label),
        ),
      ),
    );
  }
}
