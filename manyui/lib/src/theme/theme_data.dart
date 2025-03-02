import 'package:flutter/foundation.dart';

import '../widgets/avatar/avatar_styles.dart';
import '../widgets/badge/badge_styles.dart';
import '../widgets/button/button_styles.dart';
import '../widgets/card/card_styles.dart';
import '../widgets/checkbox/checkbox_styles.dart';
import '../widgets/date_field/date_field_styles.dart';
import '../widgets/divider/divider_styles.dart';
import '../widgets/label/label_styles.dart';
import '../widgets/otp_field/otp_field_styles.dart';
import '../widgets/popover/popover_styles.dart';
import '../widgets/radio/radio_styles.dart';
import '../widgets/select/select_styles.dart';
import '../widgets/slider/slider_styles.dart';
import '../widgets/switch/switch_styles.dart';
import '../widgets/text_field/text_field_styles.dart';
import '../widgets/tooltip/tooltip_styles.dart';
import 'color_scheme.dart';
import 'focus_ring_style.dart';
import 'typography.dart';

/// The root theme object every manyui widget reads from.
///
/// Carries the color scheme, typography, focus-ring shape, default radius,
/// and the host platform. Widget-family sub-styles (button, card, …) will
/// be added in later phases without breaking this constructor — they default
/// to derived values from the tokens above when not supplied.
@immutable
class MThemeData {
  /// Builds a theme data instance.
  ///
  /// [platform] defaults to `defaultTargetPlatform`. Override it in tests to
  /// force a specific platform, or in apps that want to render a different
  /// platform's idiom (e.g. a desktop browser rendering iOS-style controls).
  MThemeData({
    required this.colors,
    MTypography? typography,
    MFocusRingStyle? focusRing,
    MButtonStyles? button,
    MCardStyles? card,
    MDividerStyles? divider,
    MBadgeStyles? badge,
    MAvatarStyles? avatar,
    MCheckboxStyles? checkbox,
    MSwitchStyles? switch_,
    MRadioStyles? radio,
    MSliderStyles? slider,
    MLabelStyles? label,
    MSelectStyles? select,
    MTextFieldStyles? textField,
    MDateFieldStyles? dateField,
    MOTPFieldStyles? otpField,
    MPopoverStyles? popover,
    MTooltipStyles? tooltip,
    this.radius = 6,
    TargetPlatform? platform,
  })  : typography = typography ?? const MTypography.standard(),
        focusRing = focusRing ?? const MFocusRingStyle(),
        button = button ?? const MButtonStyles(),
        card = card ?? const MCardStyles(),
        divider = divider ?? const MDividerStyles(),
        badge = badge ?? const MBadgeStyles(),
        avatar = avatar ?? const MAvatarStyles(),
        checkbox = checkbox ?? const MCheckboxStyles(),
        switch_ = switch_ ?? const MSwitchStyles(),
        radio = radio ?? const MRadioStyles(),
        slider = slider ?? const MSliderStyles(),
        label = label ?? const MLabelStyles(),
        select = select ?? const MSelectStyles(),
        textField = textField ?? const MTextFieldStyles(),
        dateField = dateField ?? const MDateFieldStyles(),
        otpField = otpField ?? const MOTPFieldStyles(),
        popover = popover ?? const MPopoverStyles(),
        tooltip = tooltip ?? const MTooltipStyles(),
        platform = platform ?? defaultTargetPlatform;

  /// The default light theme.
  factory MThemeData.light({TargetPlatform? platform}) {
    return MThemeData(
      colors: const MColorScheme.light(),
      platform: platform,
    );
  }

  /// The default dark theme.
  factory MThemeData.dark({TargetPlatform? platform}) {
    return MThemeData(
      colors: const MColorScheme.dark(),
      platform: platform,
    );
  }

  /// The 19-token color scheme.
  final MColorScheme colors;

  /// The named text styles used by every M-widget that renders text.
  final MTypography typography;

  /// The focus-ring shape used by `MFocusRing`.
  final MFocusRingStyle focusRing;

  /// The resolution table for [MButton] visual styles.
  ///
  /// Exposed as `theme.button.resolve(variant: ..., size: ..., modality: ...)`.
  /// Replace the default `MButtonStyles()` to re-skin every button in the
  /// tree with a different mapping from tokens to styles.
  final MButtonStyles button;

  /// The resolution table for [MCard] visual styles.
  ///
  /// Exposed as `theme.card.resolve(colors: ..., radius: ...)`. Replace the
  /// default `MCardStyles()` to re-skin every card in the tree.
  final MCardStyles card;

  /// The resolution table for [MDivider] visual styles.
  ///
  /// Exposed as `theme.divider.resolve(colors: ...)`.
  final MDividerStyles divider;

  /// The resolution table for [MBadge] visual styles.
  ///
  /// Exposed as `theme.badge.resolve(variant: ..., colors: ..., typography: ...)`.
  final MBadgeStyles badge;

  /// The resolution table for [MAvatar] visual styles.
  ///
  /// Exposed as `theme.avatar.resolve(colors: ..., typography: ..., radius: ...)`.
  final MAvatarStyles avatar;

  /// The resolution table for [MCheckbox] visual styles.
  ///
  /// Exposed as `theme.checkbox.resolve(modality: ..., colors: ..., radius: ...)`.
  final MCheckboxStyles checkbox;

  /// The resolution table for [MSwitch] visual styles.
  ///
  /// Exposed as `theme.switch_.resolve(modality: ..., colors: ...)`. The field
  /// is named `switch_` because `switch` is a Dart reserved keyword.
  final MSwitchStyles switch_;

  /// The resolution table for [MRadio] visual styles.
  ///
  /// Exposed as `theme.radio.resolve(modality: ..., colors: ...)`.
  final MRadioStyles radio;

  /// The resolution table for [MSlider] visual styles.
  ///
  /// Exposed as `theme.slider.resolve(modality: ..., colors: ...)`.
  final MSliderStyles slider;

  /// The resolution table for [MLabel] visual styles.
  ///
  /// Exposed as `theme.label.resolve(colors: ..., typography: ...)`.
  final MLabelStyles label;

  /// The resolution table for [MSelect] visual styles.
  ///
  /// Exposed as
  /// `theme.select.resolve(modality: ..., colors: ..., typography: ..., radius: ...)`.
  final MSelectStyles select;

  /// The resolution table for [MTextField] visual styles.
  ///
  /// Exposed as
  /// `theme.textField.resolve(modality: ..., colors: ..., typography: ..., radius: ...)`.
  final MTextFieldStyles textField;

  /// The resolution table for [MDateField] visual styles.
  ///
  /// Exposed as
  /// `theme.dateField.resolve(modality: ..., colors: ..., typography: ..., radius: ...)`.
  final MDateFieldStyles dateField;

  /// The resolution table for [MOTPField] visual styles.
  ///
  /// Exposed as
  /// `theme.otpField.resolve(modality: ..., colors: ..., typography: ..., radius: ...)`.
  final MOTPFieldStyles otpField;

  /// The resolution table for [MPopover] visual styles.
  ///
  /// Exposed as
  /// `theme.popover.resolve(colors: ..., typography: ..., radius: ...)`.
  final MPopoverStyles popover;

  /// The resolution table for [MTooltip] visual styles.
  ///
  /// Exposed as
  /// `theme.tooltip.resolve(colors: ..., typography: ..., radius: ...)`.
  final MTooltipStyles tooltip;

  /// The default corner radius for cards, buttons, and inputs.
  ///
  /// Individual widget styles may override this; v0.1 ships a single scalar
  /// rather than the multi-step scale shadcn now uses.
  final double radius;

  /// The host platform this theme renders for.
  ///
  /// Widgets use this to pick between modality-dependent variants (e.g. a
  /// touch-sized vs mouse-sized button). Defaults to
  /// `defaultTargetPlatform`; override for tests or for apps that want to
  /// render a non-host idiom.
  final TargetPlatform platform;

  /// Returns a copy with specific fields overridden.
  MThemeData copyWith({
    MColorScheme? colors,
    MTypography? typography,
    MFocusRingStyle? focusRing,
    MButtonStyles? button,
    MCardStyles? card,
    MDividerStyles? divider,
    MBadgeStyles? badge,
    MAvatarStyles? avatar,
    MCheckboxStyles? checkbox,
    MSwitchStyles? switch_,
    MRadioStyles? radio,
    MSliderStyles? slider,
    MLabelStyles? label,
    MSelectStyles? select,
    MTextFieldStyles? textField,
    MDateFieldStyles? dateField,
    MOTPFieldStyles? otpField,
    MPopoverStyles? popover,
    MTooltipStyles? tooltip,
    double? radius,
    TargetPlatform? platform,
  }) {
    return MThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      focusRing: focusRing ?? this.focusRing,
      button: button ?? this.button,
      card: card ?? this.card,
      divider: divider ?? this.divider,
      badge: badge ?? this.badge,
      avatar: avatar ?? this.avatar,
      checkbox: checkbox ?? this.checkbox,
      switch_: switch_ ?? this.switch_,
      radio: radio ?? this.radio,
      slider: slider ?? this.slider,
      label: label ?? this.label,
      select: select ?? this.select,
      textField: textField ?? this.textField,
      dateField: dateField ?? this.dateField,
      otpField: otpField ?? this.otpField,
      popover: popover ?? this.popover,
      tooltip: tooltip ?? this.tooltip,
      radius: radius ?? this.radius,
      platform: platform ?? this.platform,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MThemeData &&
        other.colors == colors &&
        other.typography == typography &&
        other.focusRing == focusRing &&
        other.button == button &&
        other.card == card &&
        other.divider == divider &&
        other.badge == badge &&
        other.avatar == avatar &&
        other.checkbox == checkbox &&
        other.switch_ == switch_ &&
        other.radio == radio &&
        other.slider == slider &&
        other.label == label &&
        other.select == select &&
        other.textField == textField &&
        other.dateField == dateField &&
        other.otpField == otpField &&
        other.popover == popover &&
        other.tooltip == tooltip &&
        other.radius == radius &&
        other.platform == platform;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
        colors,
        typography,
        focusRing,
        button,
        card,
        divider,
        badge,
        avatar,
        checkbox,
        switch_,
        radio,
        slider,
        label,
        select,
        textField,
        dateField,
        otpField,
        popover,
        tooltip,
        radius,
        platform,
      ]);
}
