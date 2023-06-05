import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/bottom_app_bar_with_fab.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/custom_fab.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  /// This is a [StatefulWidget], which return a [Scaffold] with [BottomAppBarWithFAB],
  /// a [CustomFloatingActionButton] and the child widget.
  /// This [Scaffold] screen is the [ShellRoute]'s child in [GoRouter] and using `rootNavKey`
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
        icon: Icons.arrow_downward.temporaryIcon,
        label: 'Income'.hardcoded,
        color: Color.lerp(context.appTheme.primary, Colors.indigo[400], 0.5)!,
        onTap: () => context.go(RoutePath.addIncome),
      ),
      FABItem(
        icon: Icons.compare_arrows.temporaryIcon,
        label: 'Transfer'.hardcoded,
        color: Color.lerp(context.appTheme.secondary, Colors.grey[600], 0.5)!,
        onTap: () => context.go(RoutePath.addTransfer),
      ),
      FABItem(
        icon: Icons.arrow_upward.temporaryIcon,
        label: 'Expense'.hardcoded,
        color: Color.lerp(context.appTheme.accent, Colors.pink[400], 0.5)!,
        onTap: () => context.go(RoutePath.addExpense),
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
      backgroundColor: context.appTheme.background,
      body: widget.child,
    );
  }
}
