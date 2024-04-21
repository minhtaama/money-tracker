import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

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
