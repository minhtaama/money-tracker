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

class RoutePath {
  static String get home => '/home';
  static String get addIncome => '/addIncome';
  static String get addExpense => '/addExpense';
  static String get addTransfer => '/addTransfer';
  static String get addCreditSpending => '/addCreditSpending';
  static String get addCreditPayment => '/addCreditPayment';
  static String get dashboard => '/dashboard';
  static String get settings => '/dashboard/settings';
  static String get setCurrency => '/dashboard/settings/setCurrency';
  static String get selectIcon => '/dashboard/selectIcon';
  static String get categories => '/dashboard/categories';
  static String get addCategory => '/dashboard/categories/addCategory';
  static String get accounts => '/dashboard/accounts';
  static String get accountScreen => '/dashboard/accounts/accountScreen';
  static String get addAccount => '/dashboard/accounts/addAccount';
  static String get budgets => '/dashboard/budgets';
  static String get addBudget => '/dashboard/budgets/addBudget';
  static String get transaction => '/transaction';
  static String get editDashboard => '/editDashboard';
}

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

Widget _customTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween =
      Tween(begin: const Offset(0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
  return FadeTransition(
      opacity: animation,
      child: context.isBigScreen
          ? child
          : SlideTransition(
              position: animation.drive(tween),
              child: child,
            ));
}

_fabRoundedButtonItems(BuildContext context) => <FABItem>[
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

_fabListItems(BuildContext context) => <FABItem>[
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

_fabMainItem(BuildContext context) => FABItem(
      icon: AppIcons.heartOutline,
      label: '',
      color: context.appTheme.onAccent,
      backgroundColor: context.appTheme.accent2,
      onTap: () => showCustomModal(
        context: context,
        child: const AddTemplateTransactionModalScreen(),
      ),
    );

_navRailItems(BuildContext context) => <NavigationRailItem>[
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
      NavigationRailItem(
        path: RoutePath.settings,
        iconData: AppIcons.settings,
        text: context.localize.settings,
      ),
    ];

_bottomTabItems(BuildContext context) => <BottomAppBarItem>[
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

final goRouter = GoRouter(
  initialLocation: RoutePath.home,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      navigatorKey: _rootNavKey,
      builder: (context, state, child) {
        return ScaffoldWithNavRail(
          items: _navRailItems(context),
          body: child,
        );
      },
      routes: [
        ShellRoute(
          navigatorKey: _shellNavKey,
          parentNavigatorKey: _rootNavKey,
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
              parentNavigatorKey: _shellNavKey,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
                transitionsBuilder: _customTransition,
              ),
            ),
            GoRoute(
              path: '/dashboard',
              parentNavigatorKey: _shellNavKey,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const DashboardScreen(),
                transitionsBuilder: _customTransition,
              ),
              routes: [
                GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootNavKey,
                    pageBuilder: (context, state) => CustomTransitionPage(
                          key: state.pageKey,
                          child: const SettingsScreen(),
                          transitionsBuilder: _customTransition,
                        ),
                    routes: [
                      GoRoute(
                        path: 'setCurrency',
                        parentNavigatorKey: _rootNavKey,
                        pageBuilder: (context, state) => CustomTransitionPage(
                          key: state.pageKey,
                          child: const SelectCurrencyScreen(),
                          transitionsBuilder: _customTransition,
                        ),
                      )
                    ]),
                GoRoute(
                  path: 'selectIcon',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const SelectIconsScreen(),
                    transitionsBuilder: _customTransition,
                  ),
                ),
                GoRoute(
                  path: 'categories',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const CategoriesListScreen(),
                    transitionsBuilder: _customTransition,
                  ),
                  routes: [
                    GoRoute(
                      path: 'addCategory',
                      parentNavigatorKey: _rootNavKey,
                      pageBuilder: (context, state) => showCustomModalPage(
                        context,
                        state,
                        child: const AddCategoryModalScreen(),
                      ),
                    )
                  ],
                ),
                GoRoute(
                  path: 'accounts',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const AccountsListScreen(),
                    transitionsBuilder: _customTransition,
                  ),
                  routes: [
                    GoRoute(
                      path: 'accountScreen',
                      parentNavigatorKey: _rootNavKey,
                      pageBuilder: (context, state) => CustomTransitionPage(
                        key: state.pageKey,
                        child: AccountScreen(objectIdHexString: state.extra as String),
                        transitionsBuilder: _customTransition,
                      ),
                    ),
                    GoRoute(
                      path: 'addAccount',
                      parentNavigatorKey: _rootNavKey,
                      pageBuilder: (context, state) => showCustomModalPage(
                        context,
                        state,
                        child: const AddAccountModalScreen(),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'budgets',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const BudgetsListScreen(),
                    transitionsBuilder: _customTransition,
                  ),
                  routes: [
                    // GoRoute(
                    //   path: 'budgetScreen',
                    //   parentNavigatorKey: _rootNavKey,
                    //   builder: (context, state) => AccountScreen(objectIdHexString: state.extra as String),
                    // ),
                    GoRoute(
                      path: 'addBudget',
                      parentNavigatorKey: _rootNavKey,
                      pageBuilder: (context, state) => showCustomModalPage(
                        context,
                        state,
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
          parentNavigatorKey: _rootNavKey,
          pageBuilder: (context, state) => showCustomModalPage(
            context,
            state,
            hasHandle: false,
            child: const AddRegularTxnModalScreen(TransactionType.income),
          ),
        ),
        GoRoute(
          path: '/addExpense',
          parentNavigatorKey: _rootNavKey,
          pageBuilder: (context, state) => showCustomModalPage(
            context,
            state,
            hasHandle: false,
            child: const AddRegularTxnModalScreen(TransactionType.expense),
          ),
        ),
        GoRoute(
          path: '/addTransfer',
          parentNavigatorKey: _rootNavKey,
          pageBuilder: (context, state) => showCustomModalPage(
            context,
            state,
            hasHandle: false,
            child: const AddRegularTxnModalScreen(TransactionType.transfer),
          ),
        ),
        GoRoute(
          path: '/addCreditSpending',
          parentNavigatorKey: _rootNavKey,
          pageBuilder: (context, state) => showCustomModalPage(
            context,
            state,
            hasHandle: false,
            child: const AddCreditSpendingModalScreen(),
          ),
        ),
        GoRoute(
          path: '/addCreditPayment',
          parentNavigatorKey: _rootNavKey,
          pageBuilder: (context, state) => showCustomModalPage(
            context,
            state,
            hasHandle: false,
            child: const AddCreditPaymentModalScreen(),
          ),
        ),
        GoRoute(
          path: '/transaction',
          parentNavigatorKey: _rootNavKey,
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

            return showCustomModalPage(
              context,
              state,
              hasHandle: true,
              child: TransactionDetailsModalScreen(
                objectIdHexString: objectIdHexString,
                screenType: screenType,
              ),
            );
          },
        ),
        GoRoute(
          path: '/editDashboard',
          parentNavigatorKey: _rootNavKey,
          pageBuilder: (context, state) {
            return showCustomModalPage(
              context,
              state,
              hasHandle: true,
              child: const DashboardEditModalScreen(),
            );
          },
        ),
      ],
    ),
  ],
);
