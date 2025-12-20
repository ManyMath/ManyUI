import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

import 'page_section.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String _lastMenuActivation = '—';

  void _menuAction(String label) {
    setState(() => _lastMenuActivation = label);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return PageSection(
      title: 'Navigation',
      subtitle: 'Tabs, MenuBar, ContextMenu, CommandPalette',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Demo(
            label: 'MTabs',
            child: SizedBox(
              width: 480,
              child: MTabs(
                initialId: 'overview',
                tabs: <MTab>[
                  MTab(
                    id: 'overview',
                    title: const Text('Overview'),
                    content: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Each tab swaps the content panel without rebuilding the rest.',
                        style: TextStyle(color: theme.colors.foreground),
                      ),
                    ),
                  ),
                  const MTab(
                    id: 'activity',
                    title: Text('Activity'),
                    content: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No recent activity.'),
                    ),
                  ),
                  const MTab(
                    id: 'settings',
                    title: Text('Settings'),
                    content: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Settings live here.'),
                    ),
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Demo(
            label: 'MMenuBar — last action: $_lastMenuActivation',
            child: MMenuBar(
              menus: <MMenu>[
                MMenu(
                  id: 'file',
                  title: const Text('File'),
                  items: <MMenuItem>[
                    MMenuItem(
                      id: 'new',
                      title: const Text('New'),
                      trailing: const Text('⌘N'),
                      onTap: () => _menuAction('File → New'),
                    ),
                    MMenuItem(
                      id: 'open',
                      title: const Text('Open…'),
                      trailing: const Text('⌘O'),
                      onTap: () => _menuAction('File → Open'),
                    ),
                    MMenuItem(
                      id: 'save',
                      title: const Text('Save'),
                      trailing: const Text('⌘S'),
                      enabled: false,
                    ),
                  ],
                ),
                MMenu(
                  id: 'edit',
                  title: const Text('Edit'),
                  items: <MMenuItem>[
                    MMenuItem(
                      id: 'copy',
                      title: const Text('Copy'),
                      trailing: const Text('⌘C'),
                      onTap: () => _menuAction('Edit → Copy'),
                    ),
                    MMenuItem(
                      id: 'paste',
                      title: const Text('Paste'),
                      trailing: const Text('⌘V'),
                      onTap: () => _menuAction('Edit → Paste'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Demo(
            label: 'MContextMenu — right-click (or long-press) the panel',
            child: MContextMenu(
              items: <MMenuItem>[
                MMenuItem(
                  id: 'cut',
                  title: const Text('Cut'),
                  trailing: const Text('⌘X'),
                  onTap: () => _menuAction('Context → Cut'),
                ),
                MMenuItem(
                  id: 'copy',
                  title: const Text('Copy'),
                  trailing: const Text('⌘C'),
                  onTap: () => _menuAction('Context → Copy'),
                ),
                MMenuItem(
                  id: 'inspect',
                  title: const Text('Inspect'),
                  onTap: () => _menuAction('Context → Inspect'),
                ),
              ],
              child: Container(
                width: 360,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colors.muted,
                  border: Border.all(color: theme.colors.border),
                ),
                child: Center(
                  child: Text(
                    'Right-click here',
                    style: TextStyle(color: theme.colors.mutedForeground),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Demo(
            label: 'MCommandPalette — modal typeahead',
            child: MButton(
              variant: MButtonVariant.outline,
              onPressed: () => _openPalette(context),
              child: const Text('Open palette'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPalette(BuildContext context) async {
    final MCommandItem<String>? picked = await showMCommandPalette<String>(
      context,
      placeholder: 'Type a command…',
      items: <MCommandItem<String>>[
        MCommandItem<String>(
          id: 'open-file',
          title: const Text('Open file…'),
          trailing: const Text('⌘O'),
          searchText: 'open file',
          keywords: const <String>['load', 'document'],
          value: 'open-file',
        ),
        MCommandItem<String>(
          id: 'new-project',
          title: const Text('New project'),
          trailing: const Text('⌘N'),
          searchText: 'new project',
          value: 'new-project',
        ),
        MCommandItem<String>(
          id: 'toggle-theme',
          title: const Text('Toggle theme'),
          searchText: 'toggle theme dark light',
          value: 'toggle-theme',
        ),
        MCommandItem<String>(
          id: 'quit',
          title: const Text('Quit (disabled demo)'),
          searchText: 'quit exit',
          enabled: false,
        ),
      ],
    );
    if (!mounted) return;
    setState(() {
      _lastMenuActivation =
          picked == null ? '(palette dismissed)' : 'Palette → ${picked.id}';
    });
  }
}
