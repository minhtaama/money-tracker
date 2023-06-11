import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/add_transaction_modal_screen.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import '../features/accounts/presentation/accounts_list_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/custom_navigation_bar/presentation/scaffold_with_bottom_nav_bar_screen.dart';
import '../utils/enums.dart';

class RoutePath {
  static String get home => '/home';
  static String get addIncome => '/home/addIncome';
  static String get addExpense => '/home/addExpense';
  static String get addTransfer => '/home/addTransfer';
  static String get accounts => '/accounts';
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
          pageBuilder: (_, __) => showFadeTransitionPage(
            _,
            __,
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
          path: '/accounts',
          pageBuilder: (_, __) => showFadeTransitionPage(
            _,
            __,
            child: const AccountsListScreen(),
          ),
        ),
      ],
    ),
  ],
);

Page<void> showFadeTransitionPage(BuildContext context, GoRouterState state, {required Widget child}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: kBottomAppBarDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
