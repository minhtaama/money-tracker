import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'navigation_rail/custom_navigation_rail.dart';

final navigationRailChildKey = GlobalKey();
final navigationRailKey = GlobalKey();

class ScaffoldWithNavRail extends StatelessWidget {
  const ScaffoldWithNavRail({
    super.key,
    required this.topItems,
    required this.bottomItems,
    required this.body,
  });

  final List<NavigationRailItem> topItems;
  final List<NavigationRailItem> bottomItems;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final isBigScreen = context.isBigScreen;
    final currentPath = GoRouterState.of(context).uri.toString();
    final combinedItems = List.from(topItems)..addAll(bottomItems);

    final currentIndex = combinedItems.indexWhere((item) => item.path == currentPath);

    return Scaffold(
      key: navigationRailKey,
      backgroundColor: context.appTheme.background1,
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          CustomNavigationRail(
            topItems: topItems,
            bottomItems: bottomItems,
            selectedIndex: currentIndex,
            onTabSelected: (int tabIndex) {
              context.go(combinedItems[tabIndex].path); // Change Tab
            },
            isShow: isBigScreen,
          ),
          Expanded(
            key: navigationRailChildKey,
            child: body,
          ),
        ],
      ),
    );
  }
}
