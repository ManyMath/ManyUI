import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

import 'page_section.dart';

class OverlaysPage extends StatefulWidget {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  final MPopoverController _popover = MPopoverController();

  @override
  void dispose() {
    _popover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageSection(
      title: 'Overlays',
      subtitle: 'Tooltip, Popover, Dialog, Sheet, Toast',
      child: DemoGrid(
        children: <Widget>[
          Demo(
            label: 'MTooltip — hover the button',
            child: MTooltip(
              message: 'Open project settings',
              child: MButton(
                variant: MButtonVariant.outline,
                onPressed: () {},
                child: const Text('Settings'),
              ),
            ),
          ),
          Demo(
            label: 'MPopover — click to anchor a panel',
            child: MPopover(
              controller: _popover,
              popoverBuilder: (BuildContext ctx, VoidCallback close) {
                return SizedBox(
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Quick actions',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Anchored panels track the trigger and dismiss on outside taps or Escape.',
                        ),
                        const SizedBox(height: 12),
                        MButton(
                          size: MButtonSize.sm,
                          onPressed: close,
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: MButton(
                variant: MButtonVariant.outline,
                onPressed: () => _popover.open(),
                child: const Text('Open popover'),
              ),
            ),
          ),
          Demo(
            label: 'MDialog — modal route with scrim',
            child: MButton(
              onPressed: () => _showDialog(context),
              child: const Text('Open dialog'),
            ),
          ),
          Demo(
            label: 'MSheet — bottom anchor',
            child: MButton(
              variant: MButtonVariant.secondary,
              onPressed: () => _showSheet(context, MSheetAnchor.bottom),
              child: const Text('Bottom sheet'),
            ),
          ),
          Demo(
            label: 'MSheet — start anchor',
            child: MButton(
              variant: MButtonVariant.secondary,
              onPressed: () => _showSheet(context, MSheetAnchor.start),
              child: const Text('Side sheet'),
            ),
          ),
          Demo(
            label: 'MToast — auto-dismissing overlay',
            child: MButton(
              variant: MButtonVariant.outline,
              onPressed: () => _showToast(context),
              child: const Text('Show toast'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) {
    return showMDialog<void>(
      context,
      builder: (BuildContext ctx) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Delete project?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action is permanent. You can dismiss with Escape or by tapping the scrim.',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MButton(
                  variant: MButtonVariant.ghost,
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                MButton(
                  variant: MButtonVariant.destructive,
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSheet(BuildContext context, MSheetAnchor anchor) {
    return showMSheet<void>(
      context,
      anchor: anchor,
      builder: (BuildContext ctx) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              anchor == MSheetAnchor.bottom ? 'Bottom sheet' : 'Side sheet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Modal surface anchored to a viewport edge. Drag-handle, focus trap, and Escape-dismiss are built in.',
            ),
            const SizedBox(height: 16),
            MButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showToast(BuildContext context) {
    showMToast(
      context,
      duration: const Duration(seconds: 3),
      builder: (BuildContext ctx) =>
          const Text('Saved — toast auto-dismisses in 3s'),
    );
  }
}
