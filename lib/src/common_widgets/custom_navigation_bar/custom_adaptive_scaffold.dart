import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'navigation_rail/custom_navigation_rail.dart';

final navigationKey = GlobalKey<NavigatorState>();

class CustomAdaptiveScaffold extends StatefulWidget {
  const CustomAdaptiveScaffold({
    super.key,
    required this.navRailItems,
    required this.onNavRailChange,
    required this.currentRailIndex,
    required this.body,
  });

  final List<NavigationRailItem> navRailItems;
  final ValueSetter<int> onNavRailChange;
  final int currentRailIndex;
  final Widget body;

  @override
  State<CustomAdaptiveScaffold> createState() => _CustomAdaptiveScaffoldState();
}

class _CustomAdaptiveScaffoldState extends State<CustomAdaptiveScaffold> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Gap.screenWidth(context) < kSmallWidthBreakpoint;

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: Row(
        children: [
          CustomNavigationRail(
            items: widget.navRailItems,
            selectedIndex: widget.currentRailIndex,
            onTabSelected: widget.onNavRailChange,
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
