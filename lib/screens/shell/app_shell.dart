import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../dashboard/dashboard_screen.dart';
import '../folders/folders_screen.dart';
import '../devices/devices_screen.dart';
import '../settings/settings_screen.dart';

class AppShellController extends InheritedWidget {
  const AppShellController({
    super.key,
    required this.switchToTab,
    required super.child,
  });

  final void Function(int index) switchToTab;

  static AppShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellController>();
  }

  @override
  bool updateShouldNotify(covariant AppShellController oldWidget) {
    return switchToTab != oldWidget.switchToTab;
  }
}

/// Main app shell with adaptive navigation.
/// Mobile: NavigationBar (bottom). Tablet+: NavigationRail (side).
/// Follows LocalSend pattern: PageView + NeverScrollableScrollPhysics
/// to keep all tab states alive without rebuild on switch.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final void Function(int index) _switchToTab;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _switchToTab = _onTabSelected;
    // Setup edge-to-edge after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppTheme.setupSystemUI(context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < AppSpacing.mobileBreakpoint;
    final bool isDesktop = width >= AppSpacing.desktopBreakpoint;
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<_TabItem> tabs = <_TabItem>[
      _TabItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: l10n.tabDashboard,
      ),
      _TabItem(
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder_rounded,
        label: l10n.tabFolders,
      ),
      _TabItem(
        icon: Icons.devices_outlined,
        selectedIcon: Icons.devices_rounded,
        label: l10n.tabDevices,
      ),
      _TabItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: l10n.tabSettings,
      ),
    ];

    return AppShellController(
      switchToTab: _switchToTab,
      child: Scaffold(
        body: Row(
          children: <Widget>[
            // ── NavigationRail (tablet / desktop) ──
            if (!isMobile) ...<Widget>[
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabSelected,
                extended: isDesktop,
                labelType: isDesktop
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                leading: isDesktop
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.sync_rounded,
                                size: 28, color: colors.primary),
                            const SizedBox(width: 12),
                            Text(
                              'SyncSphere',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 8),
                        child: Icon(Icons.sync_rounded,
                            size: 28, color: colors.primary),
                      ),
                destinations: tabs
                    .map((tab) => NavigationRailDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: Text(tab.label),
                        ))
                    .toList(),
              ),
              const VerticalDivider(width: 1),
            ],

            // ── Content Area ──
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  DashboardScreen(),
                  FoldersScreen(),
                  DevicesScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          ],
        ),

        // ── NavigationBar (mobile) ──
        bottomNavigationBar: isMobile
            ? NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabSelected,
                destinations: tabs
                    .map((tab) => NavigationDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: tab.label,
                        ))
                    .toList(),
              )
            : null,
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
