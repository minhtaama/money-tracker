import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../common_widgets/card_item.dart';
import '../theme_and_ui/colors.dart';
import '../utils/constants.dart';

class CustomAppModalRoute<T> extends _CustomAppModalPageRoute<T> {
  CustomAppModalRoute(BuildContext context, {required Widget child})
      : super(
          context,
          CustomAppModalPage(
            child: child,
          ),
        );
}

class CustomAppDialogRoute<T> extends _CustomAppModalPageRoute<T> {
  /// Use [child] when no need to modify modal wrapper with scrollable content.
  /// If [builder] is specified, will use [builder] instead of [child].
  CustomAppDialogRoute(
    BuildContext context, {
    Widget? child,
    Widget Function(ScrollController controller, bool isScrollable)? builder,
  }) : super(
          context,
          CustomAppModalPage(
            child: child,
            builder: builder,
            isDialog: true,
          ),
          isDialog: true,
        );
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
  final Widget Function(ScrollController controller, bool isScrollable)? builder;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  final bool isDialog;

  @override
  Route<T> createRoute(BuildContext context) => _CustomAppModalPageRoute<T>(context, this, isDialog: isDialog);
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
        child: _page.builder!.call(controller, isScrollable),
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