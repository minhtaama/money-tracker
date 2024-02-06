import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/account_screen.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/credit/credit_details.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/accounts_list_screen.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/add_account_modal_screen.dart';
import 'package:money_tracker_app/src/features/category/presentation/add_category_modal_screen.dart';
import 'package:money_tracker_app/src/features/category/presentation/categories_list_screen.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/select_icon_screen.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/presentation/select_currency_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_credit_payment_modal_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_regular_txn_modal_screen.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/details_modal_screen/transaction_details_modal_screen.dart';
import '../common_widgets/custom_navigation_bar/scaffold_with_bottom_nav_bar_screen.dart';
import '../common_widgets/modal_and_dialog.dart';
import '../features/settings_and_persistent_values/presentation/settings_screen.dart';
import '../features/summary/presentation/summary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/transactions/presentation/screens/add_model_screen/add_credit_spending_modal_screen.dart';
import '../utils/enums.dart';

class RoutePath {
  static String get home => '/home';
  static String get addIncome => '/home/addIncome';
  static String get addExpense => '/home/addExpense';
  static String get addTransfer => '/home/addTransfer';
  static String get addCreditSpending => '/home/addCreditSpending';
  static String get addCreditPayment => '/home/addCreditPayment';
  static String get summary => '/summary';
  static String get settings => '/summary/settings';
  static String get setCurrency => '/summary/settings/setCurrency';
  static String get selectIcon => '/summary/selectIcon';
  static String get categories => '/summary/categories';
  static String get addCategory => '/summary/categories/addCategory';
  static String get accounts => '/summary/accounts';
  static String get accountScreen => '/summary/accounts/accountScreen';
  static String get addAccount => '/summary/accounts/addAccount';
  static String get transaction => '/transaction';
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
                hasHandle: false,
                child: const AddRegularTxnModalScreen(TransactionType.income),
              ),
            ),
            GoRoute(
              path: 'addExpense',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                hasHandle: false,
                child: const AddRegularTxnModalScreen(TransactionType.expense),
              ),
            ),
            GoRoute(
              path: 'addTransfer',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                hasHandle: false,
                child: const AddRegularTxnModalScreen(TransactionType.transfer),
              ),
            ),
            GoRoute(
              path: 'addCreditSpending',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                hasHandle: false,
                child: const AddCreditSpendingModalScreen(),
              ),
            ),
            GoRoute(
              path: 'addCreditPayment',
              parentNavigatorKey: _rootNavKey,
              pageBuilder: (context, state) => showModalBottomSheetPage(
                context,
                state,
                hasHandle: false,
                child: const AddCreditPaymentModalScreen(),
              ),
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
              builder: (context, state) => const AccountsListScreen(),
              routes: [
                GoRoute(
                  path: 'accountScreen',
                  parentNavigatorKey: _rootNavKey,
                  builder: (context, state) => AccountScreen(objectIdHexString: state.extra as String),
                ),
                GoRoute(
                  path: 'addAccount',
                  parentNavigatorKey: _rootNavKey,
                  pageBuilder: (context, state) => showModalBottomSheetPage(
                    context,
                    state,
                    child: const AddAccountModalScreen(),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/transaction',
      parentNavigatorKey: _rootNavKey,
      pageBuilder: (context, state) {
        final String objectIdHexString;
        final TransactionScreenType screenType;
        if (state.extra is List) {
          objectIdHexString = (state.extra as List<dynamic>)[0] as String;
          screenType = (state.extra as List<dynamic>)[1] as TransactionScreenType;
        } else {
          objectIdHexString = state.extra as String;
          screenType = TransactionScreenType.editable;
        }

        return showModalBottomSheetPage(
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
  ],
);
