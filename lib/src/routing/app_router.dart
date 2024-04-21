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
import '../common_widgets/card_item.dart';
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
import '../utils/constants.dart';
import '../utils/enums.dart';

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
            builder: (controller) => AddRegularTxnModalScreen(controller, TransactionType.income),
          ),
        ),
        GoRoute(
          path: '/addExpense',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller) => AddRegularTxnModalScreen(controller, TransactionType.expense),
          ),
        ),
        GoRoute(
          path: '/addTransfer',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller) => AddRegularTxnModalScreen(controller, TransactionType.transfer),
          ),
        ),
        GoRoute(
          path: '/addCreditSpending',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller) => AddCreditSpendingModalScreen(controller),
          ),
        ),
        GoRoute(
          path: '/addCreditPayment',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModalPage(
            key: state.pageKey,
            builder: (controller) => AddCreditPaymentModalScreen(controller),
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
class CustomAppModalRoute<T> extends _CustomAppModalPageRoute<T> {
  CustomAppModalRoute(BuildContext context, {required Widget child})
      : super(
          context,
          CustomAppModalPage(
            child: child,
          ),
        );

  //final Widget child;
}

class CustomAppDialogRoute<T> extends _CustomAppModalPageRoute<T> {
  /// Use [child] when no need to modify modal wrapper with scrollable content.
  /// If [builder] is specified, will use [builder] instead of [child].
  CustomAppDialogRoute(BuildContext context, {Widget? child, Widget Function(ScrollController controller)? builder})
      : super(
          context,
          CustomAppModalPage(
            child: child,
            builder: builder,
            isDialog: true,
          ),
          isDialog: true,
        );
}

///////////////////////// FOR GO ROUTER ///////////////////////////

class CustomAppPage<T> extends Page<T> {
  const CustomAppPage({
    required this.child,
    this.transitionDuration = k250msDuration,
    this.reverseTransitionDuration = k250msDuration,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  @override
  Route<T> createRoute(BuildContext context) => _CustomAppPageRoute<T>(this);
}

class CustomAppModalPage<T> extends Page<T> {
  const CustomAppModalPage({
    this.child,
    this.builder,
    this.transitionDuration = k250msDuration,
    this.reverseTransitionDuration = k250msDuration,
    this.isDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// Use [child] when no need to modify modal wrapper with scrollable content.
  /// If [builder] is specified, will use [builder] instead of [child].
  final Widget? child;

  /// Use [builder] when need to modify modal wrapper with scrollable content inside.
  /// Must use this controller callback.
  final Widget Function(ScrollController controller)? builder;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  final bool isDialog;

  @override
  Route<T> createRoute(BuildContext context) => _CustomAppModalPageRoute<T>(context, this, isDialog: isDialog);
}

//////////////////////////// ROUTES ///////////////////////////////

class _CustomAppPageRoute<T> extends PageRoute<T> {
  _CustomAppPageRoute(CustomAppPage<T> page) : super(settings: page);

  CustomAppPage<T> get _page => settings as CustomAppPage<T>;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => false;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.fastOutSlowIn));
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
      child: context.isBigScreen
          ? child
          : SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
    );
  }
}

class _CustomAppModalPageRoute<T> extends PopupRoute<T> {
  /// A modal bottom sheet route.
  _CustomAppModalPageRoute(
    this.context,
    CustomAppModalPage<T> settings, {
    this.isDialog = false,
    this.bigScreenWidth = 350,
  }) : super(settings: settings);

  final BuildContext context;

  final bool isDialog;

  final double bigScreenWidth;

  CustomAppModalPage<T> get _page => settings as CustomAppModalPage<T>;

  @override
  Color? get barrierColor => context.isBigScreen
      ? null
      : context.appTheme.isDarkTheme
          ? AppColors.black.withOpacity(0.35)
          : AppColors.greyBgr(context).withOpacity(0.7);

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => true;

  @override
  bool get opaque => false;

  @override
  AnimationController createAnimationController() {
    return AnimationController(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      vsync: navigator!,
    );
  }

  @override
  Animation<double> createAnimation() {
    return controller!.drive(CurveTween(curve: Curves.fastOutSlowIn));
  }

  Widget _cardWrapper({Widget? child, bool? isScrollable}) {
    return CardItem(
      color: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
      elevation: context.isBigScreen && !context.appTheme.isDarkTheme ? 4.5 : 20,
      width: isDialog
          ? null
          : context.isBigScreen
              ? bigScreenWidth
              : double.infinity,
      margin: isDialog
          ? const EdgeInsets.all(38)
          : EdgeInsets.symmetric(
              vertical: context.isBigScreen ? 16 : 0,
              horizontal: context.isBigScreen ? 8 : 0,
            ),
      padding: isDialog ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 12, right: 12, top: 8),
      borderRadius: context.isBigScreen || isDialog
          ? const BorderRadius.all(Radius.circular(20))
          : BorderRadius.only(
              topLeft: Radius.circular((isScrollable ?? false) ? 0 : 28),
              topRight: Radius.circular((isScrollable ?? false) ? 0 : 28)),
      child: AnimatedPadding(
        duration: k1msDuration,
        padding: EdgeInsets.only(
          top: isDialog ? 0 : 16,
          bottom: (MediaQuery.of(context).viewInsets.bottom).clamp(16, double.infinity),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> _, Animation<double> __) {
    assert(_page.child != null || _page.builder != null);

    final Widget contentWithScrollView = _ScrollableChecker(
      builder: (controller, isScrollable) => _cardWrapper(
        isScrollable: isScrollable,
        child: _page.builder!.call(controller),
      ),
    );

    final Widget contentNoScrollView = _cardWrapper(
      child: _page.child,
    );

    return AnimatedAlign(
      alignment: isDialog
          ? Alignment.center
          : context.isBigScreen
              ? Alignment.bottomRight
              : Alignment.bottomCenter,
      duration: transitionDuration,
      curve: Curves.easeOut,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: _page.builder != null ? contentWithScrollView : contentNoScrollView,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(tween),
        child: child,
      ),
    );
  }
}

////////////////////// SCROLLABLE CHECKER ////////////////////////

class _ScrollableChecker extends StatefulWidget {
  const _ScrollableChecker({
    required this.builder,
  });

  final Widget Function(ScrollController scrollController, bool isScrollable) builder;

  @override
  State<_ScrollableChecker> createState() => _ScrollableCheckerState();
}

class _ScrollableCheckerState extends State<_ScrollableChecker> {
  late final ScrollController _scrollController = ScrollController();

  bool _isScrollable = false;

  @override
  void initState() {
    _scrollController.addListener(_listener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _listener();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ScrollableChecker oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _listener() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      if (!_isScrollable && maxScrollExtent > 0 || _isScrollable && maxScrollExtent <= 0) {
        setState(() {
          _isScrollable = !_isScrollable;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _listener();
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: widget.builder.call(_scrollController, _isScrollable),
      ),
    );
  }
}
