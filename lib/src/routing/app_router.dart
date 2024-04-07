import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_navigation_rail_screen.dart';
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
import '../common_widgets/custom_navigation_bar/scaffold_with_bottom_nav_bar_screen.dart';
import '../common_widgets/modal_and_dialog.dart';
import '../features/settings_and_persistent_values/presentation/settings_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/transactions/presentation/screens/add_model_screen/add_credit_spending_modal_screen.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

class RoutePath {
  static String get home => '/home';
  static String get addIncome => '/home/addIncome';
  static String get addExpense => '/home/addExpense';
  static String get addTransfer => '/home/addTransfer';
  static String get addCreditSpending => '/home/addCreditSpending';
  static String get addCreditPayment => '/home/addCreditPayment';
  static String get dashboard => '/dashboard';
  static String get settings => '/adaptive-route/settings';
  static String get setCurrency => '/adaptive-route/settings/setCurrency';
  static String get selectIcon => '/adaptive-route/selectIcon';
  static String get categories => '/adaptive-route/categories';
  static String get addCategory => '/adaptive-route/categories/addCategory';
  static String get accounts => '/adaptive-route/accounts';
  static String get accountScreen => '/adaptive-route/accounts/accountScreen';
  static String get addAccount => '/adaptive-route/accounts/addAccount';
  static String get budgets => '/adaptive-route/budgets';
  static String get addBudget => '/adaptive-route/budgets/addBudget';
  static String get transaction => '/transaction';
  static String get editDashboard => '/editDashboard';
}

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

final AdaptiveRoute adaptiveRoute = AdaptiveRoute();

final goRouter = GoRouter(
  initialLocation: RoutePath.home,
  navigatorKey: _rootNavKey,
  debugLogDiagnostics: true,
  overridePlatformDefaultLocation: true,
  redirect: (context, state) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    print(state.uri.toString());
    //print('called');
    return adaptiveRoute.navigate(state, mediaQuery);
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) {
        if (Gap.screenWidth(context) > kMaxWidthForSmallScreen) {
          return ScaffoldWithNavigationRail(
            child: child,
          );
        }
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
              pageBuilder: (context, state) => showCustomModalPage(
                context,
                state,
                hasHandle: false,
                child: const AddRegularTxnModalScreen(TransactionType.income),
              ),
            ),
            GoRoute(
              path: 'addExpense',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showCustomModalPage(
                context,
                state,
                hasHandle: false,
                child: const AddRegularTxnModalScreen(TransactionType.expense),
              ),
            ),
            GoRoute(
              path: 'addTransfer',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showCustomModalPage(
                context,
                state,
                hasHandle: false,
                child: const AddRegularTxnModalScreen(TransactionType.transfer),
              ),
            ),
            GoRoute(
              path: 'addCreditSpending',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showCustomModalPage(
                context,
                state,
                hasHandle: false,
                child: const AddCreditSpendingModalScreen(),
              ),
            ),
            GoRoute(
              path: 'addCreditPayment',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showCustomModalPage(
                context,
                state,
                hasHandle: false,
                child: const AddCreditPaymentModalScreen(),
              ),
            ),
          ],
        ),
        // Dashboard
        GoRoute(
          path: '/dashboard',
          parentNavigatorKey: _shellNavKey,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/big-width',
          parentNavigatorKey: _shellNavKey,
          builder: (_, __) => const Placeholder(),
          routes: _adaptiveRoutes(_shellNavKey),
        ),
      ],
    ),
    GoRoute(
      path: '/small-width',
      parentNavigatorKey: _rootNavKey,
      builder: (_, __) => const Placeholder(),
      routes: _adaptiveRoutes(_rootNavKey),
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
);

List<GoRoute> _adaptiveRoutes(GlobalKey<NavigatorState> key) => [
      GoRoute(
        path: 'settings',
        parentNavigatorKey: key,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'setCurrency',
            //parentNavigatorKey: _rootNavKey,
            builder: (context, state) => const SelectCurrencyScreen(),
          )
        ],
      ),
      GoRoute(
        path: 'selectIcon',
        parentNavigatorKey: key,
        builder: (context, state) => const SelectIconsScreen(),
      ),
      GoRoute(
        path: 'categories',
        parentNavigatorKey: key,
        builder: (context, state) => const CategoriesListScreen(),
        routes: [
          GoRoute(
            path: 'addCategory',
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
        parentNavigatorKey: key,
        builder: (context, state) => const AccountsListScreen(),
        routes: [
          GoRoute(
            path: 'accountScreen',
            builder: (context, state) => AccountScreen(objectIdHexString: state.extra as String),
          ),
          GoRoute(
            path: 'addAccount',
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
        parentNavigatorKey: key,
        builder: (context, state) => const BudgetsListScreen(),
        routes: [
          // GoRoute(
          //   path: 'budgetScreen',
          //   parentNavigatorKey: _rootNavKey,
          //   builder: (context, state) => AccountScreen(objectIdHexString: state.extra as String),
          // ),
          GoRoute(
            path: 'addBudget',
            pageBuilder: (context, state) => showCustomModalPage(
              context,
              state,
              child: const AddBudgetModalScreen(),
            ),
          ),
        ],
      )
    ];

class AdaptiveRoute {
  String? lastRoute;
  String? navigate(GoRouterState state, MediaQueryData mediaQuery) {
    lastRoute = state.uri.toString().contains("/small-width") ||
            state.uri.toString().contains("/big-width") ||
            state.uri.toString().contains("/adaptive-route")
        ? lastRoute
        : state.uri.toString();

    // final isAdaptiveRoute = lastRoute == null
    //     ? false
    //     : lastRoute!.contains("/small-width") ||
    //         lastRoute!.contains("/big-width") ||
    //         lastRoute!.contains("/adaptive-route");

    final isAdaptiveRoute = state.uri.toString().contains("/small-width") ||
        state.uri.toString().contains("/big-width") ||
        state.uri.toString().contains("/adaptive-route");

    final regexp = RegExp(r'(?<!\w)(/big-width|/small-width|/adaptive-route)(?!\w)');
    String truePath = state.uri.toString().replaceAll(regexp, '').trim();

    // print('lastRoute: ' + lastRoute.toString());
    print('realURL2: ' + state.uri.toString());
    // print('truePath: ' + truePath);
    print('test: ' + isAdaptiveRoute.toString());

    if (isAdaptiveRoute) {
      if (mediaQuery.size.width >= kMaxWidthForSmallScreen) {
        return '/big-width$truePath';
      } else {
        return '/small-width$truePath';
      }
    }

    return null;

    // if (mediaQuery.size.width >= 700.0) {
    //   // Desktop Route
    //   if (state.uri.toString().contains("/mobile")) {
    //     return "/desktop$lastRoute";
    //   }
    //   return "/desktop$changed";
    // } else {
    //   //Mobile
    //   if (state.uri.toString().contains("/desktop")) {
    //     return "/mobile$lastRoute";
    //   }
    //   return "/mobile$changed";
    // }
  }
}
