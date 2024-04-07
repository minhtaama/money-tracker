import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/main.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_template_transaction.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/constants.dart';
import 'bottom_app_bar/bottom_app_bar_with_fab.dart';
import 'bottom_app_bar/custom_fab.dart';

class ScaffoldWithNavigationRail extends ConsumerStatefulWidget {
  /// This is a [StatefulWidget], which return a [Scaffold] with [BottomAppBarWithFAB],
  /// a [CustomFloatingActionButton] and the child widget.
  /// This [Scaffold] screen is the [ShellRoute]'s child in [GoRouter] and using `rootNavKey`
  const ScaffoldWithNavigationRail({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ScaffoldWithNavigationRail> createState() => _ScaffoldWithBottomNavBarState();
}

class RailItem extends NavigationRailDestination {
  RailItem(
    BuildContext context, {
    required String iconPath,
    required this.path,
    required String label,
  }) : super(
          icon: SvgIcon(
            iconPath,
            size: 25,
            color: context.appTheme.onBackground,
          ),
          selectedIcon: SvgIcon(
            iconPath,
            size: 25,
            color: context.appTheme.onAccent,
          ),
          label: Text(
            label,
            style: kHeader4TextStyle.copyWith(
                color: context.appTheme.onBackground, height: 1, fontSize: 13),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        );

  final String path;
}

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithNavigationRail> {
  int _destinationIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<RailItem> destinations = [
      RailItem(
        context,
        iconPath: AppIcons.home,
        label: context.localize.home,
        path: RoutePath.home,
      ),
      RailItem(
        context,
        iconPath: AppIcons.summary,
        label: context.localize.dashboard,
        path: RoutePath.dashboard,
      ),
    ];

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
      // floatingActionButton: isHomeScreen
      //     ? CustomFloatingActionButton(
      //         roundedButtonItems: roundedButtonItems,
      //         listItems: listItems,
      //         mainItem: mainItem,
      //       )
      //     : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      backgroundColor: context.appTheme.background1,
      extendBody: true,
      body: Row(
        children: [
          NavigationRail(
            destinations: destinations,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomFloatingActionButton(
                  roundedButtonItems: roundedButtonItems,
                  listItems: listItems,
                  mainItem: mainItem,
                ),
              ),
            ),
            selectedIndex: _destinationIndex,
            backgroundColor: context.appTheme.background1,
            labelType: NavigationRailLabelType.all,
            indicatorColor: context.appTheme.accent1,
            indicatorShape: const StadiumBorder(),
            minWidth: 100,
            onDestinationSelected: (int index) {
              context.go(destinations[index].path); // Change Tab
              _destinationIndex = index;
            },
          ),
          Container(
            width: 1,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.greyBorder(context), AppColors.greyBorder(context).withOpacity(0)],
              stops: const [0, 0.5],
            )),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
