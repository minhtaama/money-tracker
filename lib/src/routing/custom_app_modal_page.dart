import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../common_widgets/card_item.dart';
import '../theme_and_ui/colors.dart';
import '../utils/constants.dart';

class CustomAppModalRoute<T> extends _CustomAppModalPageRoute<T> {
  CustomAppModalRoute({Widget? child, Widget Function(ScrollController controller, bool isScrollable)? builder})
      : super(
          CustomAppModalPage(
            child: child,
            builder: builder,
          ),
        );
}

class CustomAppDialogRoute<T> extends _CustomAppModalPageRoute<T> {
  /// Use [child] when no need to modify modal wrapper with scrollable content.
  /// If [builder] is specified, will use [builder] instead of [child].
  CustomAppDialogRoute({
    Widget? child,
    Widget Function(ScrollController controller, bool isScrollable)? builder,
  }) : super(
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
    this.secondaryChild,
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

  final Widget? secondaryChild;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  final bool isDialog;

  @override
  Route<T> createRoute(BuildContext context) => _CustomAppModalPageRoute<T>(this, isDialog: isDialog);
}

class _CustomAppModalPageRoute<T> extends PopupRoute<T> {
  /// A modal bottom sheet route.
  _CustomAppModalPageRoute(
    CustomAppModalPage<T> settings, {
    this.isDialog = false,
    this.bigScreenWidth = 350,
  }) : super(settings: settings);

  final bool isDialog;

  final double bigScreenWidth;

  CustomAppModalPage<T> get _page => settings as CustomAppModalPage<T>;

  @override
  Color? get barrierColor => navigator!.context.isBigScreen
      ? null
      : navigator!.context.appTheme.isDarkTheme
          ? AppColors.black.withOpacity(0.60)
          : AppColors.black.withOpacity(0.15);

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

  bool _roundedTopCornerSmallScreen(BuildContext context, bool? isScrollable) => isScrollable ?? false
      ? _page.secondaryChild != null
          ? MediaQuery.of(context).viewInsets.bottom > 0
              ? false
              : true
          : false
      : true;

  Widget _cardWrapper(BuildContext context, {Widget? child, bool? isScrollable}) {
    return CardItem(
      color: context.appTheme.background0,
      elevation: 2.5,
      width: isDialog
          ? null
          : context.isBigScreen
              ? bigScreenWidth
              : double.infinity,
      margin: isDialog
          ? const EdgeInsets.all(24)
          : EdgeInsets.only(
              top: context.isBigScreen ? Gap.statusBarHeight(context) + 10 : 0,
              bottom: context.isBigScreen ? 16 : 0,
              left: context.isBigScreen ? 6 : 0,
              right: context.isBigScreen ? 8 : 0,
            ),
      padding: isDialog
          ? const EdgeInsets.symmetric(vertical: 12)
          : EdgeInsets.only(
              top: _roundedTopCornerSmallScreen(context, isScrollable) || context.isBigScreen
                  ? 0
                  : (Gap.statusBarHeight(context) - 12.5).clamp(0, double.infinity),
            ),
      border: Border.all(
        color:
            context.appTheme.onBackground.withOpacity(context.isBigScreen && context.appTheme.isDarkTheme ? 0.25 : 0),
      ),
      borderRadius: context.isBigScreen || isDialog
          ? const BorderRadius.all(Radius.circular(18))
          : BorderRadius.only(
              topLeft: Radius.circular(_roundedTopCornerSmallScreen(context, isScrollable) ? 18 : 0),
              topRight: Radius.circular(_roundedTopCornerSmallScreen(context, isScrollable) ? 18 : 0),
            ),
      child: child,
    );
  }

  Widget _contentWithScrollView(BuildContext context) => _ScrollableChecker(
        builder: (controller, isScrollable) => _cardWrapper(
          context,
          isScrollable: isScrollable,
          child: _page.builder!.call(controller, isScrollable),
        ),
      );

  Widget _contentNoScrollView(BuildContext context) => _cardWrapper(
        context,
        child: _page.child,
      );

  Widget _finalChild(BuildContext context) => isDialog
      ? _page.builder != null
          ? _contentWithScrollView(context)
          : _contentNoScrollView(context)
      : context.isBigScreen
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _page.secondaryChild != null
                    ? Flexible(
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: Gap.statusBarHeight(context) + 10, bottom: 8, left: 12, right: 6),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 350,
                              maxHeight: Gap.screenHeight(context) - Gap.statusBarHeight(context),
                            ),
                            child: SingleChildScrollView(child: _page.secondaryChild),
                          ),
                        ),
                      )
                    : Gap.noGap,
                _page.builder != null ? _contentWithScrollView(context) : _contentNoScrollView(context)
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _page.secondaryChild != null
                    ? HideableContainer(
                        hide: MediaQuery.of(context).viewInsets.bottom > 0,
                        initialAnimation: false,
                        child: AnimatedOpacity(
                          opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 1,
                          duration: k350msDuration,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: Gap.statusBarHeight(context) + 12, bottom: 24, left: 16, right: 16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: Gap.screenHeight(context) / 3),
                                child: SingleChildScrollView(child: _page.secondaryChild),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Gap.noGap,
                Flexible(child: _page.builder != null ? _contentWithScrollView(context) : _contentNoScrollView(context))
              ],
            );

  @override
  Widget buildPage(BuildContext context, Animation<double> _, Animation<double> __) {
    assert(_page.child != null || _page.builder != null);

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
        child: _finalChild(context),
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
