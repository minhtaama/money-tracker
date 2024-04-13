import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'navigation_rail/custom_navigation_rail.dart';

final navigationRailChildKey = GlobalKey();
final navigationRailKey = GlobalKey();

class ScaffoldWithNavRail extends StatefulWidget {
  const ScaffoldWithNavRail({
    super.key,
    required this.items,
    required this.body,
  });

  final List<NavigationRailItem> items;
  final Widget body;

  @override
  State<ScaffoldWithNavRail> createState() => _ScaffoldWithNavRailState();
}

class _ScaffoldWithNavRailState extends State<ScaffoldWithNavRail> {
  @override
  Widget build(BuildContext context) {
    final isBigScreen = context.isBigScreen;
    final currentPath = GoRouterState.of(context).uri.toString();
    final currentIndex = widget.items.indexWhere((item) => item.path == currentPath);

    return Scaffold(
      key: navigationRailKey,
      backgroundColor: context.appTheme.background1,
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          CustomNavigationRail(
            items: widget.items,
            selectedIndex: currentIndex,
            onTabSelected: (int tabIndex) {
              context.go(widget.items[tabIndex].path); // Change Tab
            },
            isShow: isBigScreen,
          ),
          Expanded(
            key: navigationRailChildKey,
            child: widget.body,
          ),
        ],
      ),
    );
  }
}
