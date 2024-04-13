import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/bottom_app_bar/custom_bottom_app_bar.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_template_transaction.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/constants.dart';
import 'bottom_app_bar/custom_fab.dart';

class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.items,
    required this.child,
  });
  final List<BottomAppBarItem> items;
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

    final roundedButtonItems = <FABItem>[
      FABItem(
        icon: AppIcons.income,
        label: context.localize.income,
        color: context.appTheme.onPositive,
        backgroundColor: context.appTheme.positive,
        onTap: () => context.push(RoutePath.addIncome),
      ),
      FABItem(
        icon: AppIcons.transfer,
        label: context.localize.transfer,
        color: context.appTheme.onBackground,
        backgroundColor: AppColors.grey(context),
        onTap: () => context.push(RoutePath.addTransfer),
      ),
      FABItem(
        icon: AppIcons.expense,
        label: context.localize.expense,
        color: context.appTheme.onNegative,
        backgroundColor: context.appTheme.negative,
        onTap: () => context.push(RoutePath.addExpense),
      ),
    ];

    final listItems = <FABItem>[
      FABItem(
        icon: AppIcons.receiptDollar,
        label: context.localize.creditSpending,
        onTap: () => context.push(RoutePath.addCreditSpending),
      ),
      FABItem(
        icon: AppIcons.handCoin,
        label: context.localize.creditPayment,
        onTap: () => context.push(RoutePath.addCreditPayment),
      ),
    ];

    final mainItem = FABItem(
      icon: AppIcons.heartOutline,
      label: '',
      color: context.appTheme.onAccent,
      backgroundColor: context.appTheme.accent2,
      onTap: () => showCustomModal(
        context: context,
        child: const AddTemplateTransactionModalScreen(),
      ),
    );

    // Each tabItem has a `path` to navigate under ShellRoute. When GoRouter push/go
    // a route which is the child of ShellRoute, this Scaffold will not disappear, but
    // display above the `tabItem`.
    return Scaffold(
      floatingActionButton: CustomFloatingActionButton(
        roundedButtonItems: roundedButtonItems,
        listItems: listItems,
        mainItem: mainItem,
      ),
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
