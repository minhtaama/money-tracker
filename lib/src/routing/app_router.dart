import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/custom_navigation_bar/presentation/scaffold_with_bottom_nav_bar_screen.dart';

class RoutePath {
  static String get home => '/home';
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
          path: RoutePath.home,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: RoutePath.accounts,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const AccountsScreen(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),
  ],
);
