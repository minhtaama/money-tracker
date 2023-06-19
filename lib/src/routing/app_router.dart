import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/add_transaction_modal_screen.dart';
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
  static String get setting => '/summary/settings';
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
              pageBuilder: (_, __) => showAddTransactionModalPage(
                _,
                __,
                child: const AddTransactionModalScreen(TransactionType.income),
              ),
              //TODO: Implement add transaction widget
            ),
            GoRoute(
              path: 'addExpense',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (_, __) => showAddTransactionModalPage(
                _,
                __,
                child: const AddTransactionModalScreen(TransactionType.expense),
              ),
              //TODO: Implement add transaction widget
            ),
            GoRoute(
              path: 'addTransfer',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (_, __) => showAddTransactionModalPage(
                _,
                __,
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
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
              )
            ]),
      ],
    ),
  ],
);
