import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/bottom_app_bar/custom_bottom_app_bar.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bottom_app_bar/custom_fab.dart';

class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.items,
    required this.floatingActionButton,
    required this.child,
  });
  final List<BottomAppBarItem> items;
  final Widget floatingActionButton;
  final Widget child;

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = !context.isBigScreen;
    final currentPath = GoRouterState.of(context).uri.toString();
    final currentIndex = widget.items.indexWhere((item) => item.path == currentPath);

    // Each tabItem has a `path` to navigate under ShellRoute. When GoRouter push/go
    // a route which is the child of ShellRoute, this Scaffold will not disappear, but
    // display above the `tabItem`.
    return Scaffold(
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: isSmallScreen
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: currentIndex,
        isShow: isSmallScreen,
        items: widget.items,
        onTabSelected: (int tabIndex) {
          context.go(widget.items[tabIndex].path); // Change Tab
        },
      ),
      backgroundColor: context.appTheme.background1,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: widget.child,
    );
  }
}
