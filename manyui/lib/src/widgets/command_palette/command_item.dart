import 'package:flutter/widgets.dart';

/// A single command rendered inside an [MCommandPalette].
///
/// Command-palette items are richer than [MMenuItem]s: they carry a leading
/// slot (typically an icon), an optional subtitle line, a trailing slot
/// (typically a keyboard-shortcut hint), a typed [value] used as the
/// activation result, and [keywords] / [searchText] that drive the typeahead
/// filter.
///
/// Activation: when the user taps an item — or focuses it and presses Enter —
/// the palette pops the route with this item, [onTap] fires, and the
/// `Future<MCommandItem<T>?>` returned by [showMCommandPalette] resolves to
/// this item. Both the callback and the future-return fire; either is
/// optional.
///
/// ```dart
/// MCommandItem<String>(
///   id: 'open-file',
///   title: const Text('Open File…'),
///   leading: const Icon(Icons.file_open),
///   trailing: const Text('⌘O'),
///   keywords: const <String>['open', 'load', 'file'],
///   value: 'open',
///   onTap: () => openFile(),
/// )
/// ```
@immutable
class MCommandItem<T> {
  /// Builds a command item declaration.
  const MCommandItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.searchText,
    this.keywords = const <String>[],
    this.category,
    this.value,
    this.onTap,
    this.enabled = true,
  });

  /// Stable identifier for this item within its enclosing palette.
  ///
  /// Must be unique within the items list. Used for focus bookkeeping and
  /// as the key for behavioral tests.
  final String id;

  /// The primary label rendered in the item row.
  ///
  /// Typically a [Text] widget. Because the typeahead matcher reads
  /// [searchText] and [keywords] — not text extracted from this widget —
  /// callers may pass arbitrary widgets here without breaking search.
  final Widget title;

  /// Optional secondary label rendered below [title] in a muted color.
  final Widget? subtitle;

  /// Optional leading widget rendered before [title], typically an icon.
  final Widget? leading;

  /// Optional trailing widget rendered after [title], typically a
  /// keyboard-shortcut hint such as `Text('⌘O')`.
  final Widget? trailing;

  /// The text the typeahead matcher searches against.
  ///
  /// When non-null, the filter matches `searchText` directly. When null,
  /// the filter falls back to joining [keywords]. Separate from [title]
  /// because [title] is a widget — callers control what's searchable
  /// independent of presentation. If both are null/empty, the item only
  /// matches the empty query (i.e. it is always visible).
  final String? searchText;

  /// Additional terms appended to [searchText] for filtering.
  ///
  /// The matcher tests `(searchText ?? '') + ' ' + keywords.join(' ')`
  /// lowercased against the lowercased query.
  final List<String> keywords;

  /// A grouping label for v0.2 category headers.
  ///
  /// **Reserved for v0.2.** v0.1's palette renders a flat list and ignores
  /// this field; it is exposed now so callers can declare categories
  /// against a stable API.
  final String? category;

  /// The payload activated against. Used as the route's pop value when the
  /// item is activated; the activated item itself is returned to the
  /// caller of [showMCommandPalette].
  final T? value;

  /// Invoked when the user activates the item.
  ///
  /// Fires in addition to the future-return — both happen.
  final VoidCallback? onTap;

  /// Whether the item responds to user interaction.
  ///
  /// Disabled items render dimmed, refuse pointer and keyboard activation,
  /// and are skipped by Up/Down navigation.
  final bool enabled;
}
