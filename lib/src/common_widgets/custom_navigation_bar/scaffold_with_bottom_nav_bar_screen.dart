import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bottom_app_bar/bottom_app_bar_with_fab.dart';
import 'bottom_app_bar/custom_fab.dart';

class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  /// This is a [StatefulWidget], which return a [Scaffold] with [BottomAppBarWithFAB],
  /// a [CustomFloatingActionButton] and the child widget.
  /// This [Scaffold] screen is the [ShellRoute]'s child in [GoRouter] and using `rootNavKey`
  const ScaffoldWithBottomNavBar({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    bool isHomeScreen = GoRouterState.of(context).uri.toString() == '/home';

    final tabItems = <BottomAppBarItem>[
      BottomAppBarItem(
        path: RoutePath.home,
        iconData: AppIcons.home,
        text: context.localize.home,
      ),
      BottomAppBarItem(
        path: RoutePath.dashboard,
        iconData: AppIcons.summary,
        text: context.localize.dashboard,
      ),
    ];

    final roundedButtonItems = <FABItem>[
      FABItem(
        icon: AppIcons.income,
        label: context.localize.income,
        color: context.appTheme.onPositive,
        backgroundColor: context.appTheme.positive,
        onTap: () => context.go(RoutePath.addIncome),
      ),
      FABItem(
        icon: AppIcons.transfer,
        label: context.localize.transfer,
        color: context.appTheme.onBackground,
        backgroundColor: AppColors.grey(context),
        onTap: () => context.go(RoutePath.addTransfer),
      ),
      FABItem(
        icon: AppIcons.expense,
        label: context.localize.expense,
        color: context.appTheme.onNegative,
        backgroundColor: context.appTheme.negative,
        onTap: () => context.go(RoutePath.addExpense),
      ),
    ];

    final listItems = <FABItem>[
      FABItem(
        icon: AppIcons.receiptDollar,
        label: context.localize.creditSpending,
        onTap: () => context.go(RoutePath.addCreditSpending),
      ),
      FABItem(
        icon: AppIcons.handCoin,
        label: context.localize.creditPayment,
        onTap: () => context.go(RoutePath.addCreditPayment),
      ),
    ];

    // Each tabItem has a `path` to navigate under ShellRoute. When GoRouter push/go
    // a route which is the child of ShellRoute, this Scaffold will not disappear, but
    // display above the `tabItem`.
    return Scaffold(
      floatingActionButton: isHomeScreen
          ? CustomFloatingActionButton(
              roundedButtonItems: roundedButtonItems,
              listItems: listItems,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBarWithFAB(
        items: tabItems,
        onTabSelected: (int tabIndex) {
          context.go(tabItems[tabIndex].path); // Change Tab
          isHomeScreen = tabIndex == 0;
        },
      ),
      backgroundColor: context.appTheme.background1,
      extendBody: true,
      body: widget.child,
    );
  }
}
