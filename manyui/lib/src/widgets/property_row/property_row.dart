import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';

/// Layout modes for [MPropertyRow].
enum MPropertyRowLayout {
  /// Label over value/description, with optional trailing actions beside the
  /// content on wide layouts and below it on compact layouts.
  stacked,

  /// Label and value share one row on wide layouts, falling back to stacked
  /// when the row is too narrow.
  inline,
}

/// A compact row for read-only facts, settings, and property controls.
///
/// `MPropertyRow` standardizes the common "label, value/helper copy, trailing
/// action/control" shape used by account facts, settings rows, status fields,
/// and metadata panels. It is non-interactive; put buttons,
/// switches, or copy controls in [trailing].
class MPropertyRow extends StatelessWidget {
  /// Builds a property row.
  const MPropertyRow({
    required this.label,
    this.value,
    this.description,
    this.trailing,
    this.layout = MPropertyRowLayout.stacked,
    this.padding = EdgeInsets.zero,
    this.compactBreakpoint = 520,
    this.labelValueGap = 4,
    this.horizontalGap = 24,
    this.compactTrailingGap = 12,
    this.labelStyle,
    this.valueStyle,
    this.descriptionStyle,
    super.key,
  });

  /// The visible property name.
  final String label;

  /// The primary property value.
  final Widget? value;

  /// Supporting copy shown below [value], or below [label] when [value] is
  /// absent.
  final String? description;

  /// Optional action or control associated with the property.
  final Widget? trailing;

  /// Whether the row is primarily stacked or inline.
  final MPropertyRowLayout layout;

  /// Padding around the whole row.
  final EdgeInsetsGeometry padding;

  /// Width below which rows with trailing controls stack vertically.
  final double compactBreakpoint;

  /// Space between [label] and [value]/[description].
  final double labelValueGap;

  /// Space between content and [trailing] in wide layouts.
  final double horizontalGap;

  /// Space between content and [trailing] in compact layouts.
  final double compactTrailingGap;

  /// Optional label text style override.
  final TextStyle? labelStyle;

  /// Optional value text style inherited by [value].
  final TextStyle? valueStyle;

  /// Optional description text style override.
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final effectiveLabelStyle =
        labelStyle ??
        switch (layout) {
          MPropertyRowLayout.inline => theme.typography.bodySmall.copyWith(
            color: theme.colors.mutedForeground,
          ),
          MPropertyRowLayout.stacked => theme.typography.label,
        };
    final effectiveValueStyle =
        valueStyle ??
        switch (layout) {
          MPropertyRowLayout.inline => theme.typography.bodySmall,
          MPropertyRowLayout.stacked => theme.typography.body,
        };
    final effectiveDescriptionStyle =
        descriptionStyle ??
        theme.typography.caption.copyWith(color: theme.colors.mutedForeground);

    final Widget labelWidget = Text(label, style: effectiveLabelStyle);

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        labelWidget,
        if (value != null) ...<Widget>[
          SizedBox(height: labelValueGap),
          DefaultTextStyle.merge(style: effectiveValueStyle, child: value!),
        ],
        if (description != null && description!.isNotEmpty) ...<Widget>[
          SizedBox(height: labelValueGap),
          Text(description!, style: effectiveDescriptionStyle),
        ],
      ],
    );

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < compactBreakpoint;
          if (layout == MPropertyRowLayout.inline &&
              !compact &&
              description == null) {
            return _buildInline(labelWidget, effectiveValueStyle);
          }

          if (trailing == null) {
            return content;
          }

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                content,
                SizedBox(height: compactTrailingGap),
                Align(alignment: Alignment.centerLeft, child: trailing),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: content),
              SizedBox(width: horizontalGap),
              trailing!,
            ],
          );
        },
      ),
    );
  }

  Widget _buildInline(Widget labelWidget, TextStyle effectiveValueStyle) {
    final List<Widget> trailingWidgets = <Widget>[];
    if (value != null) {
      trailingWidgets.add(
        Flexible(
          child: DefaultTextStyle.merge(
            style: effectiveValueStyle,
            child: value!,
          ),
        ),
      );
    }
    if (trailing != null) {
      if (trailingWidgets.isNotEmpty) {
        trailingWidgets.add(SizedBox(width: labelValueGap));
      }
      trailingWidgets.add(trailing!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: labelWidget),
        if (trailingWidgets.isNotEmpty)
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: trailingWidgets,
            ),
          ),
      ],
    );
  }
}
