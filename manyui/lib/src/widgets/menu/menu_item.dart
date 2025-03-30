import 'package:flutter/widgets.dart';

/// A single item rendered inside a manyui menu surface.
///
/// Shared between [MMenuBar] (top-strip pulldown menus) and [MContextMenu]
/// (right-click / long-press pointer menus). The two widgets render
/// instances of this type identically — same per-id focus tracking, same
/// trailing-slot treatment, same disabled-skip rule for keyboard nav.
@immutable
class MMenuItem {
  /// Builds a menu item declaration.
  const MMenuItem({
    required this.id,
    required this.title,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });

  /// Stable identifier for this item within its enclosing menu.
  ///
  /// Must be unique within the menu it lives in. Used for focus bookkeeping
  /// and to key tests.
  final String id;

  /// The widget rendered inside the item, typically a [Text].
  final Widget title;

  /// Invoked when the user activates the item. After it runs the enclosing
  /// menu is closed and focus returns to the trigger.
  ///
  /// When null, activation still closes the menu — useful for "no-op /
  /// coming soon" items that should still dismiss.
  final VoidCallback? onTap;

  /// An optional trailing widget rendered after [title], typically a
  /// keyboard-shortcut hint like `Text('⌘S')`.
  final Widget? trailing;

  /// Whether the item responds to user interaction.
  ///
  /// Disabled items render dimmed, refuse pointer and keyboard activation,
  /// and are skipped by Up/Down navigation inside the open menu.
  final bool enabled;
}
