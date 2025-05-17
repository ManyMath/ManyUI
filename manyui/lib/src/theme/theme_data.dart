import 'package:flutter/foundation.dart';

import '../widgets/accordion/accordion_styles.dart';
import '../widgets/avatar/avatar_styles.dart';
import '../widgets/badge/badge_styles.dart';
import '../widgets/button/button_styles.dart';
import '../widgets/card/card_styles.dart';
import '../widgets/checkbox/checkbox_styles.dart';
import '../widgets/command_palette/command_palette_styles.dart';
import '../widgets/context_menu/context_menu_styles.dart';
import '../widgets/date_field/date_field_styles.dart';
import '../widgets/dialog/dialog_styles.dart';
import '../widgets/divider/divider_styles.dart';
import '../widgets/label/label_styles.dart';
import '../widgets/menu_bar/menu_bar_styles.dart';
import '../widgets/otp_field/otp_field_styles.dart';
import '../widgets/popover/popover_styles.dart';
import '../widgets/progress/progress_styles.dart';
import '../widgets/radio/radio_styles.dart';
import '../widgets/resizable/resizable_styles.dart';
import '../widgets/scaffold/scaffold_styles.dart';
import '../widgets/select/select_styles.dart';
import '../widgets/sheet/sheet_styles.dart';
import '../widgets/slider/slider_styles.dart';
import '../widgets/switch/switch_styles.dart';
import '../widgets/tabs/tabs_styles.dart';
import '../widgets/text_field/text_field_styles.dart';
import '../widgets/toast/toast_styles.dart';
import '../widgets/tooltip/tooltip_styles.dart';
import 'color_scheme.dart';
import 'focus_ring_style.dart';
import 'typography.dart';

/// The root theme object every manyui widget reads from.
///
/// Carries the color scheme, typography, focus-ring shape, default radius,
/// per-widget style tables, and the host platform.
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
    MDialogStyles? dialog,
    MSheetStyles? sheet,
    MToastStyles? toast,
    MTabsStyles? tabs,
    MMenuBarStyles? menuBar,
    MContextMenuStyles? contextMenu,
    MCommandPaletteStyles? commandPalette,
    MProgressStyles? progress,
    MAccordionStyles? accordion,
    MResizableStyles? resizable,
    MScaffoldStyles? scaffold,
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
        dialog = dialog ?? const MDialogStyles(),
        sheet = sheet ?? const MSheetStyles(),
        toast = toast ?? const MToastStyles(),
        tabs = tabs ?? const MTabsStyles(),
        menuBar = menuBar ?? const MMenuBarStyles(),
        contextMenu = contextMenu ?? const MContextMenuStyles(),
        commandPalette = commandPalette ?? const MCommandPaletteStyles(),
        progress = progress ?? const MProgressStyles(),
        accordion = accordion ?? const MAccordionStyles(),
        resizable = resizable ?? const MResizableStyles(),
        scaffold = scaffold ?? const MScaffoldStyles(),
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

  /// Style table for [MButton].
  final MButtonStyles button;

  /// Style table for [MCard].
  final MCardStyles card;

  /// Style table for [MDivider].
  final MDividerStyles divider;

  /// Style table for [MBadge].
  final MBadgeStyles badge;

  /// Style table for [MAvatar].
  final MAvatarStyles avatar;

  /// Style table for [MCheckbox].
  final MCheckboxStyles checkbox;

  /// Style table for [MSwitch].
  ///
  /// Named `switch_` because `switch` is a Dart reserved keyword.
  final MSwitchStyles switch_;

  /// Style table for [MRadio].
  final MRadioStyles radio;

  /// Style table for [MSlider].
  final MSliderStyles slider;

  /// Style table for [MLabel].
  final MLabelStyles label;

  /// Style table for [MSelect].
  final MSelectStyles select;

  /// Style table for [MTextField].
  final MTextFieldStyles textField;

  /// Style table for [MDateField].
  final MDateFieldStyles dateField;

  /// Style table for [MOTPField].
  final MOTPFieldStyles otpField;

  /// Style table for [MPopover].
  final MPopoverStyles popover;

  /// Style table for [MTooltip].
  final MTooltipStyles tooltip;

  /// Style table for [MDialog].
  final MDialogStyles dialog;

  /// Style table for [MSheet].
  final MSheetStyles sheet;

  /// Style table for [MToast].
  final MToastStyles toast;

  /// Style table for [MTabs].
  final MTabsStyles tabs;

  /// Style table for [MMenuBar].
  final MMenuBarStyles menuBar;

  /// Style table for [MContextMenu].
  final MContextMenuStyles contextMenu;

  /// Style table for [MCommandPalette].
  final MCommandPaletteStyles commandPalette;

  /// Style table for [MProgress] and [MCircularProgress].
  final MProgressStyles progress;

  /// Style table for [MAccordion].
  final MAccordionStyles accordion;

  /// Style table for [MResizable].
  final MResizableStyles resizable;

  /// Style table for [MScaffold].
  final MScaffoldStyles scaffold;

  /// Default corner radius for cards, buttons, and inputs.
  final double radius;

  /// The host platform this theme renders for.
  ///
  /// Defaults to `defaultTargetPlatform`; override for tests or non-host
  /// platform rendering.
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
    MDialogStyles? dialog,
    MSheetStyles? sheet,
    MToastStyles? toast,
    MTabsStyles? tabs,
    MMenuBarStyles? menuBar,
    MContextMenuStyles? contextMenu,
    MCommandPaletteStyles? commandPalette,
    MProgressStyles? progress,
    MAccordionStyles? accordion,
    MResizableStyles? resizable,
    MScaffoldStyles? scaffold,
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
      dialog: dialog ?? this.dialog,
      sheet: sheet ?? this.sheet,
      toast: toast ?? this.toast,
      tabs: tabs ?? this.tabs,
      menuBar: menuBar ?? this.menuBar,
      contextMenu: contextMenu ?? this.contextMenu,
      commandPalette: commandPalette ?? this.commandPalette,
      progress: progress ?? this.progress,
      accordion: accordion ?? this.accordion,
      resizable: resizable ?? this.resizable,
      scaffold: scaffold ?? this.scaffold,
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
        other.dialog == dialog &&
        other.sheet == sheet &&
        other.toast == toast &&
        other.tabs == tabs &&
        other.menuBar == menuBar &&
        other.contextMenu == contextMenu &&
        other.commandPalette == commandPalette &&
        other.progress == progress &&
        other.accordion == accordion &&
        other.resizable == resizable &&
        other.scaffold == scaffold &&
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
        dialog,
        sheet,
        toast,
        tabs,
        menuBar,
        contextMenu,
        commandPalette,
        progress,
        accordion,
        resizable,
        scaffold,
        radius,
        platform,
      ]);
}
