import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../routing/app_router.dart';
import '../../theme_and_ui/icons.dart';
import 'navigation_rail/custom_navigation_rail.dart';

final navigationKey = GlobalKey<NavigatorState>();

class ScaffoldWithNavRail extends StatefulWidget {
  const ScaffoldWithNavRail({
    super.key,
    required this.currentIndex,
    required this.body,
  });

  final int currentIndex;
  final Widget body;

  @override
  State<ScaffoldWithNavRail> createState() => _ScaffoldWithNavRailState();
}

class _ScaffoldWithNavRailState extends State<ScaffoldWithNavRail> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Gap.screenWidth(context) < kSmallWidthBreakpoint;

    final tabItems = <NavigationRailItem>[
      NavigationRailItem(
        path: RoutePath.home,
        iconData: AppIcons.home,
        text: context.localize.home,
      ),
      NavigationRailItem(
        path: RoutePath.dashboard,
        iconData: AppIcons.summary,
        text: context.localize.dashboard,
      ),
    ];

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: Row(
        children: [
          CustomNavigationRail(
            items: tabItems,
            selectedIndex: widget.currentIndex,
            onTabSelected: (int tabIndex) {
              context.go(tabItems[tabIndex].path); // Change Tab
            },
            isShow: !isSmallScreen,
          ),
          Expanded(
            child: ClipRect(
              child: Scaffold(
                extendBody: true,
                backgroundColor: context.appTheme.background1,
                body: widget.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
