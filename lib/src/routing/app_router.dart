import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/accounts_screen.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/add_acount_modal_screen.dart';
import 'package:money_tracker_app/src/features/category/presentation/add_category_modal_screen.dart';
import 'package:money_tracker_app/src/features/category/presentation/categories_list_screen.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/select_icon_screen.dart';
import 'package:money_tracker_app/src/features/settings/presentation/select_currency_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/add_transaction_modal_screen.dart';
import '../common_widgets/modal_bottom_sheets.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/summary/presentation/summary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/custom_navigation_bar/presentation/scaffold_with_bottom_nav_bar_screen.dart';
import '../utils/enums.dart';

class RoutePath {
  static String get home => '/home';
  static String get addIncome => '/home/addIncome';
  static String get addExpense => '/home/addExpense';
  static String get addTransfer => '/home/addTransfer';
  static String get summary => '/summary';
  static String get settings => '/summary/settings';
  static String get setCurrency => '/summary/settings/setCurrency';
  static String get selectIcon => '/summary/selectIcon';
  static String get categories => '/summary/categories';
  static String get addCategory => '/summary/categories/addCategory';
  static String get accounts => '/summary/accounts';
  static String get addAccount => '/summary/accounts/addAccount';
}

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  initialLocation: RoutePath.home,
  navigatorKey: _rootNavKey,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          parentNavigatorKey: _shellNavKey,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
          routes: [
            GoRoute(
              path: 'addIncome',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                child: const AddTransactionModalScreen(TransactionType.income),
              ),
              //TODO: Implement add transaction widget
            ),
            GoRoute(
              path: 'addExpense',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                child: const AddTransactionModalScreen(TransactionType.expense),
              ),
              //TODO: Implement add transaction widget
            ),
            GoRoute(
              path: 'addTransfer',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                child: const AddTransactionModalScreen(TransactionType.transfer),
              ),
              //TODO: Implement add transaction widget
            ),
          ],
        ),
        GoRoute(
          path: '/summary',
          parentNavigatorKey: _shellNavKey,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const SummaryScreen(),
          ),
          routes: [
            GoRoute(
                path: 'settings',
                parentNavigatorKey: _rootNavKey,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'setCurrency',
                    parentNavigatorKey: _rootNavKey,
                    builder: (context, state) => const SelectCurrencyScreen(),
                  )
                ]),
            GoRoute(
              path: 'selectIcon',
              parentNavigatorKey: _rootNavKey,
              builder: (context, state) => const SelectIconsScreen(),
            ),
            GoRoute(
              path: 'categories',
              parentNavigatorKey: _rootNavKey,
              builder: (context, state) => const CategoriesListScreen(),
              routes: [
                GoRoute(
                  path: 'addCategory',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => showModalBottomSheetPage(
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
              builder: (context, state) => const AccountsScreen(),
              routes: [
                GoRoute(
                  path: 'addAccount',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => showModalBottomSheetPage(
                    context,
                    state,
                    child: const AddAccountModalScreen(),
                  ),
                )
              ],
            )
          ],
        ),
      ],
    ),
  ],
);
