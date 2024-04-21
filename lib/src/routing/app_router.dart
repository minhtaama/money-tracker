import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_navigation_rail_shell.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/account_screen.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/accounts_list_screen.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/add_account_modal_screen.dart';
import 'package:money_tracker_app/src/features/budget/presentation/add_budget_modal_screen.dart';
import 'package:money_tracker_app/src/features/budget/presentation/budgets_list_screen.dart';
import 'package:money_tracker_app/src/features/category/presentation/add_category_modal_screen.dart';
import 'package:money_tracker_app/src/features/category/presentation/categories_list_screen.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/dashboard_edit_modal_screen.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/select_icon_screen.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/presentation/components/select_currency_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_credit_payment_modal_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_regular_txn_modal_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/details_modal_screen/transaction_details_modal_screen.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../common_widgets/custom_navigation_bar/bottom_app_bar/custom_bottom_app_bar.dart';
import '../common_widgets/custom_navigation_bar/bottom_app_bar/custom_fab.dart';
import '../common_widgets/custom_navigation_bar/navigation_rail/custom_navigation_rail.dart';
import '../common_widgets/custom_navigation_bar/scaffold_with_bottom_nav_bar_shell.dart';
import '../common_widgets/modal_and_dialog.dart';
import '../features/settings_and_persistent_values/presentation/settings_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/transactions/presentation/screens/add_model_screen/add_credit_spending_modal_screen.dart';
import '../features/transactions/presentation/screens/add_model_screen/add_template_transaction.dart';
import '../theme_and_ui/colors.dart';
import '../theme_and_ui/icons.dart';
import '../utils/enums.dart';
import 'custom_app_modal_page.dart';
import 'custom_app_page.dart';

class RoutePath {
  static const String home = '/home';
  static const String addIncome = '/addIncome';
  static const String addExpense = '/addExpense';
  static const String addTransfer = '/addTransfer';
  static const String addCreditSpending = '/addCreditSpending';
  static const String addCreditPayment = '/addCreditPayment';
  static const String dashboardOrHomeInBigScreen = '/dashboard';
  static const String settings = '/dashboard/settings';
  static const String setCurrency = '/dashboard/settings/setCurrency';
  static const String selectIcon = '/dashboard/selectIcon';
  static const String categories = '/dashboard/categories';
  static const String addCategory = '/dashboard/categories/addCategory';
  static const String accounts = '/dashboard/accounts';
  static const String accountScreen = '/dashboard/accounts/accountScreen';
  static const String addAccount = '/dashboard/accounts/addAccount';
  static const String budgets = '/dashboard/budgets';
  static const String addBudget = '/dashboard/budgets/addBudget';
  static const String transaction = '/transaction';
  static const String editDashboard = '/editDashboard';
}

final _railNavKey = GlobalKey<NavigatorState>();
final _bottomNavKey = GlobalKey<NavigatorState>();

List<FABItem> _fabRoundedButtonItems(BuildContext context) => [
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

List<FABItem> _fabListItems(BuildContext context) => [
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

FABItem _fabMainItem(BuildContext context) => FABItem(
      icon: AppIcons.heartOutline,
      label: '',
      color: context.appTheme.onAccent,
      backgroundColor: context.appTheme.accent2,
      onTap: () => showCustomModal(
        context: context,
        child: const AddTemplateTransactionModalScreen(),
      ),
    );

List<NavigationRailItem> _navRailTopItems(BuildContext context) => [
      NavigationRailItem(
        path: RoutePath.dashboardOrHomeInBigScreen,
        iconData: AppIcons.home,
        text: context.localize.home,
      ),
      NavigationRailItem(
        path: RoutePath.budgets,
        iconData: AppIcons.budgets,
        text: context.localize.budget,
      ),
      NavigationRailItem(
        path: RoutePath.accounts,
        iconData: AppIcons.accounts,
        text: context.localize.accounts,
      ),
      NavigationRailItem(
        path: RoutePath.categories,
        iconData: AppIcons.categories,
        text: context.localize.categories,
      ),
    ];

List<NavigationRailItem> _navRailBottomItems(BuildContext context) => [
      NavigationRailItem(
        path: RoutePath.settings,
        iconData: AppIcons.settings,
        text: context.localize.settings,
      ),
    ];

List<BottomAppBarItem> _bottomTabItems(BuildContext context) => [
      BottomAppBarItem(
        path: RoutePath.home,
        iconData: AppIcons.home,
        text: context.localize.home,
      ),
      BottomAppBarItem(
        path: RoutePath.dashboardOrHomeInBigScreen,
        iconData: AppIcons.summary,
        text: context.localize.dashboard,
      ),
    ];

final goRouter = GoRouter(
  initialLocation: RoutePath.home,
  debugLogDiagnostics: true,
  requestFocus: false,
  redirect: (context, routerState) {
    final location = routerState.matchedLocation;
    if (kDebugMode) {
      print(location);
    }

    if (context.isBigScreen && location == RoutePath.home) {
      return RoutePath.dashboardOrHomeInBigScreen;
    }

    return null;
  },
  routes: [
    ShellRoute(
      navigatorKey: _railNavKey,
      builder: (context, state, child) {
        return ScaffoldWithNavRail(
          topItems: _navRailTopItems(context),
          bottomItems: _navRailBottomItems(context),
          body: child,
        );
      },
      routes: [
        ShellRoute(
          navigatorKey: _bottomNavKey,
          parentNavigatorKey: _railNavKey,
          builder: (context, state, child) {
            return ScaffoldWithBottomNavBar(
              items: _bottomTabItems(context),
              floatingActionButton: CustomFloatingActionButton(
                roundedButtonItems: _fabRoundedButtonItems(context),
                listItems: _fabListItems(context),
                mainItem: _fabMainItem(context),
              ),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              parentNavigatorKey: _bottomNavKey,
              pageBuilder: (context, state) => CustomAppPage(
                key: state.pageKey,
                child: const HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/dashboard',
              parentNavigatorKey: _bottomNavKey,
              pageBuilder: (context, state) => CustomAppPage(
                key: state.pageKey,
                child: const DashboardAdaptiveWrapper(),
              ),
              routes: [
                GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _railNavKey,
                    pageBuilder: (context, state) => CustomAppPage(
                          key: state.pageKey,
                          child: const SettingsScreen(),
                        ),
                    routes: [
                      GoRoute(
                        path: 'setCurrency',
                        parentNavigatorKey: _railNavKey,
                        pageBuilder: (context, state) => CustomAppPage(
                          key: state.pageKey,
                          child: const SelectCurrencyScreen(),
                        ),
                      )
                    ]),
                GoRoute(
                  path: 'selectIcon',
                  parentNavigatorKey: _railNavKey,
                  pageBuilder: (context, state) => CustomAppPage(
                    key: state.pageKey,
                    child: const SelectIconsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'categories',
                  parentNavigatorKey: _railNavKey,
                  pageBuilder: (context, state) => CustomAppPage(
                    key: state.pageKey,
                    child: const CategoriesListScreen(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'addCategory',
                      parentNavigatorKey: _railNavKey,
                      pageBuilder: (context, state) => CustomAppModalPage(
                        key: state.pageKey,
                        child: const AddCategoryModalScreen(),
                      ),
                    )
                  ],
                ),
                GoRoute(
                  path: 'accounts',
                  parentNavigatorKey: _railNavKey,
                  pageBuilder: (context, state) => CustomAppPage(
                    key: state.pageKey,
                    child: const AccountsListScreen(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'accountScreen',
                      parentNavigatorKey: _railNavKey,
                      pageBuilder: (context, state) => CustomAppPage(
                        key: state.pageKey,
                        child: AccountScreen(objectIdHexString: state.extra as String),
                      ),
                    ),
                    GoRoute(
                      path: 'addAccount',
                      parentNavigatorKey: _railNavKey,
                      pageBuilder: (context, state) => CustomAppModalPage(
                        key: state.pageKey,
                        child: const AddAccountModalScreen(),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'budgets',
                  parentNavigatorKey: _railNavKey,
                  pageBuilder: (context, state) => CustomAppPage(
                    key: state.pageKey,
                    child: const BudgetsListScreen(),
                  ),
                  routes: [
                    // GoRoute(
                    //   path: 'budgetScreen',
                    //   parentNavigatorKey: _rootNavKey,
                    //   builder: (context, state) => AccountScreen(objectIdHexString: state.extra as String),
                    // ),
                    GoRoute(
                      path: 'addBudget',
                      parentNavigatorKey: _railNavKey,
                      pageBuilder: (context, state) => CustomAppModalPage(
                        key: state.pageKey,
                        child: const AddBudgetModalScreen(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/addIncome',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller, isScrollable) =>
                AddRegularTxnModalScreen(controller, isScrollable, TransactionType.income),
          ),
        ),
        GoRoute(
          path: '/addExpense',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller, isScrollable) =>
                AddRegularTxnModalScreen(controller, isScrollable, TransactionType.expense),
          ),
        ),
        GoRoute(
          path: '/addTransfer',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller, isScrollable) =>
                AddRegularTxnModalScreen(controller, isScrollable, TransactionType.transfer),
          ),
        ),
        GoRoute(
          path: '/addCreditSpending',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller, isScrollable) => AddCreditSpendingModalScreen(controller, isScrollable),
          ),
        ),
        GoRoute(
          path: '/addCreditPayment',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller, isScrollable) => AddCreditPaymentModalScreen(controller, isScrollable),
          ),
        ),
        GoRoute(
          path: '/transaction',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) {
            final String objectIdHexString;
            final TransactionScreenType screenType;

            if (state.extra is String) {
              objectIdHexString = state.extra as String;
              screenType = TransactionScreenType.editable;
            } else {
              objectIdHexString = (state.extra as ({String string, TransactionScreenType type})).string;
              screenType = (state.extra as ({String string, TransactionScreenType type})).type;
            }

            return CustomAppModalPage(
              key: state.pageKey,
              child: TransactionDetailsModalScreen(
                objectIdHexString: objectIdHexString,
                screenType: screenType,
              ),
            );
          },
        ),
        GoRoute(
          path: '/editDashboard',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            child: const DashboardEditModalScreen(),
          ),
        ),
      ],
    ),
  ],
);

////////// FOR [showCustomModal] function //////////

////////////////////// SCROLLABLE CHECKER ////////////////////////
