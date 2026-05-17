import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final WidgetBuilder builder;

  const NavDestination({
    required this.icon,
    required this.label,
    required this.builder,
    this.selectedIcon,
  });
}

class PlatformAwareNavShell extends StatefulWidget {
  final List<NavDestination> destinations;
  final int initialIndex;

  const PlatformAwareNavShell({
    super.key,
    required this.destinations,
    this.initialIndex = 0,
  });

  @override
  State<PlatformAwareNavShell> createState() => _PlatformAwareNavShellState();
}

class _PlatformAwareNavShellState extends State<PlatformAwareNavShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIos) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: [
            for (final d in widget.destinations)
              BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
          ],
        ),
        tabBuilder: (context, i) => CupertinoTabView(
          builder: widget.destinations[i].builder,
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (final d in widget.destinations) Builder(builder: d.builder),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in widget.destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: d.selectedIcon == null ? null : Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
