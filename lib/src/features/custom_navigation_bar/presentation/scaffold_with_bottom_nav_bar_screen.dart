import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/bottom_app_bar_with_fab.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/custom_fab.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/theming/app_theme.dart';
import 'package:money_tracker_app/src/utils/extensions/app_localization_context_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is a StatefulWidget, which return a Scaffold with BottomAppBar, a FAB and
// a SafeArea wrap the child widget.
// This Scaffold screen is the ShellRoute's child in GoRouter and using `rootNavKey`
class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithBottomNavBar({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final tabItems = <BottomAppBarItem>[
      BottomAppBarItem(
        path: RoutePath.home,
        iconData: Icons.home.temporaryIcon,
        text: context.localize.home,
      ),
      BottomAppBarItem(
        path: RoutePath.accounts,
        iconData: Icons.account_balance_wallet_sharp.temporaryIcon,
        text: context.localize.accounts,
      ),
    ];

    final fabItems = <FABItem>[
      FABItem(
        icon: Icons.arrow_circle_down.temporaryIcon,
        label: 'Income'.hardcoded,
        color: Colors.lightBlueAccent,
        onTap: () => print('tapped'),
      ),
      FABItem(
        icon: Icons.compare_arrows.temporaryIcon,
        label: 'Transfer'.hardcoded,
        color: Colors.blueGrey,
        onTap: () => print('tapped'),
      ),
      FABItem(
        icon: Icons.arrow_circle_up,
        label: 'Expense'.hardcoded,
        color: Colors.redAccent,
        onTap: () => print('tapped'),
      ),
      //TODO: Implement Hive icon
    ];

    // Watch state in TabPage to change behaviour of Floating Action Button
    bool isFABDocked =
        ref.watch(customListViewStateControllerProvider.select((value) => value.isScrollForward));

    // Each tabItem has a `path` to navigate under ShellRoute. When GoRouter push/go
    // a route which is the child of ShellRoute, this Scaffold will not disappear, but
    // display above the `tabItem`.
    return Scaffold(
      floatingActionButton: CustomFloatingActionButton(items: fabItems),
      floatingActionButtonLocation: isFABDocked
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBarWithFAB(
        items: tabItems,
        onTabSelected: (int tabIndex) {
          context.go(tabItems[tabIndex].path); // Change Tab
        },
      ),
      extendBody: false,
      backgroundColor: AppTheme.of(context).background,
      body: widget.child,
    );
  }
}
