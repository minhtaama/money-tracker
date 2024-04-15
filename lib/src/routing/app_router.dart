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

List<NavigationRailItem> _navRailItems(BuildContext context) => [
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
          items: _navRailItems(context),
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
                child: const DashboardOnlyOrWithHomeScreenWrapper(),
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
                      pageBuilder: (context, state) => CustomAppModal(
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
                      pageBuilder: (context, state) => CustomAppModal(
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
                      pageBuilder: (context, state) => CustomAppModal(
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
          pageBuilder: (context, state) => CustomAppModal(
            key: state.pageKey,
            child: const AddRegularTxnModalScreen(TransactionType.income),
          ),
        ),
        GoRoute(
          path: '/addExpense',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModal(
            key: state.pageKey,
            child: const AddRegularTxnModalScreen(TransactionType.expense),
          ),
        ),
        GoRoute(
          path: '/addTransfer',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModal(
            key: state.pageKey,
            child: const AddRegularTxnModalScreen(TransactionType.transfer),
          ),
        ),
        GoRoute(
          path: '/addCreditSpending',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModal(
            key: state.pageKey,
            child: const AddCreditSpendingModalScreen(),
          ),
        ),
        GoRoute(
          path: '/addCreditPayment',
          parentNavigatorKey: _railNavKey,
          pageBuilder: (context, state) => CustomAppModal(
            key: state.pageKey,
            child: const AddCreditPaymentModalScreen(),
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

            return CustomAppModal(
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
          pageBuilder: (context, state) => CustomAppModal(
            key: state.pageKey,
            child: const DashboardEditModalScreen(),
          ),
        ),
      ],
    ),
  ],
);

////////// FOR [showCustomModal] function //////////
class CustomAppModalRoute<T> extends _CustomAppModalRoute<T> {
  CustomAppModalRoute(BuildContext context, {required Widget child})
      : super(
          context,
          CustomAppModal(
            key: const ValueKey('FUCK'),
            child: child,
          ),
        );

  //final Widget child;
}

///////////////// FOR GO ROUTER //////////////////

class CustomAppPage<T> extends Page<T> {
  /// Constructor for a page with custom transition functionality.
  ///
  /// To be used instead of MaterialPage or CupertinoPage, which provide
  /// their own transitions.
  const CustomAppPage({
    required this.child,
    this.transitionDuration = k250msDuration,
    this.reverseTransitionDuration = k250msDuration,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  final bool maintainState;

  final bool fullscreenDialog;

  final bool opaque;

  final bool barrierDismissible;

  final Color? barrierColor;

  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) => _CustomAppPageRoute<T>(this);
}

class _CustomAppPageRoute<T> extends PageRoute<T> {
  _CustomAppPageRoute(CustomAppPage<T> page) : super(settings: page);

  CustomAppPage<T> get _page => settings as CustomAppPage<T>;

  @override
  bool get barrierDismissible => _page.barrierDismissible;

  @override
  Color? get barrierColor => _page.barrierColor;

  @override
  String? get barrierLabel => _page.barrierLabel;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

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

class CustomAppModal<T> extends Page<T> {
  /// Constructor for a page with custom transition functionality.
  ///
  /// To be used instead of MaterialPage or CupertinoPage, which provide
  /// their own transitions.
  const CustomAppModal({
    required this.child,
    this.transitionDuration = k250msDuration,
    this.reverseTransitionDuration = k250msDuration,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = false,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  final bool maintainState;

  final bool fullscreenDialog;

  final bool opaque;

  final bool barrierDismissible;

  final Color? barrierColor;

  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) => _CustomAppModalRoute<T>(context, this);
}

class _CustomAppModalRoute<T> extends PopupRoute<T> {
  /// A modal bottom sheet route.
  _CustomAppModalRoute(this.context, CustomAppModal<T> settings) : super(settings: settings);

  final BuildContext context;

  CustomAppModal<T> get _page => settings as CustomAppModal<T>;

  @override
  Color? get barrierColor => context.isBigScreen
      ? null
      : context.appTheme.isDarkTheme
          ? AppColors.black.withOpacity(0.35)
          : AppColors.greyBgr(context).withOpacity(0.7);

  @override
  String? get barrierLabel => _page.barrierLabel;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => _page.maintainState;

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

  @override
  Widget buildPage(BuildContext context, Animation<double> _, Animation<double> __) {
    final Widget content = _ScrollableChecker(
      builder: (controller, isScrollable) => CardItem(
        color: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
        elevation: 20,
        constraints: BoxConstraints(
          maxWidth: context.isBigScreen ? 450 : Gap.screenWidth(context),
        ),
        margin: EdgeInsets.symmetric(
          vertical: context.isBigScreen ? 16 : 0,
          horizontal: context.isBigScreen ? 8 : 0,
        ),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
        borderRadius: context.isBigScreen
            ? const BorderRadius.all(Radius.circular(20))
            : BorderRadius.only(
                topLeft: Radius.circular(isScrollable ? 0 : 28), topRight: Radius.circular(isScrollable ? 0 : 28)),
        child: AnimatedPadding(
          padding:
              EdgeInsets.only(top: 16, bottom: (MediaQuery.of(context).viewInsets.bottom).clamp(8, double.infinity)),
          duration: const Duration(milliseconds: 50),
          child: SingleChildScrollView(
            controller: controller,
            child: _page.child,
          ),
        ),
      ),
    );

    return AnimatedAlign(
      alignment: context.isBigScreen ? Alignment.bottomRight : Alignment.bottomCenter,
      duration: transitionDuration,
      curve: Curves.easeOut,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: content,
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
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (!_isScrollable && maxScrollExtent > 0 || _isScrollable && maxScrollExtent <= 0) {
      setState(() {
        _isScrollable = !_isScrollable;
      });
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
