import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bottom_app_bar/bottom_app_bar_with_fab.dart';
import 'bottom_app_bar/custom_fab.dart';

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
    bool isHomeScreen = GoRouterState.of(context).location == '/home';
    final tabItems = <BottomAppBarItem>[
      BottomAppBarItem(
        path: RoutePath.home,
        iconData: AppIcons.home,
        text: context.localize.home,
      ),
      BottomAppBarItem(
        path: RoutePath.summary,
        iconData: AppIcons.summary,
        text: context.localize.summary,
      ),
    ];

    final roundedButtonItems = <FABItem>[
      FABItem(
        icon: AppIcons.income,
        label: 'Income'.hardcoded,
        color: context.appTheme.onPositive,
        backgroundColor: context.appTheme.positive,
        onTap: () => context.go(RoutePath.addIncome),
      ),
      FABItem(
        icon: AppIcons.transfer,
        label: 'Transfer'.hardcoded,
        color: context.appTheme.backgroundNegative,
        backgroundColor: AppColors.darkerGrey,
        onTap: () => context.go(RoutePath.addTransfer),
      ),
      FABItem(
        icon: AppIcons.expense,
        label: 'Expense'.hardcoded,
        color: context.appTheme.onNegative,
        backgroundColor: context.appTheme.negative,
        onTap: () => context.go(RoutePath.addExpense),
      ),
    ];

    final listItems = <FABItem>[
      FABItem(
          icon: AppIcons.add,
          label: 'Add Credit transaction',
          onTap: () {
            print('pressed');
            // TODO: PUSH TO ADD CREDIT TRANSACTION
          }),
    ];

    // Each tabItem has a `path` to navigate under ShellRoute. When GoRouter push/go
    // a route which is the child of ShellRoute, this Scaffold will not disappear, but
    // display above the `tabItem`.
    return Scaffold(
      floatingActionButton: isHomeScreen
          ? CustomFloatingActionButton(
              roundedButtonItems: roundedButtonItems,
              listItems: listItems,
              label: 'regular transaction',
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
      backgroundColor: context.appTheme.background,
      extendBody: true,
      body: widget.child,
    );
  }
}
