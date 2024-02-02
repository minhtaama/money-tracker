import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'custom_tab_bar.dart';

////////////////////////////////////////////////////////////////////////

class CustomTabPage extends ConsumerStatefulWidget {
  const CustomTabPage({
    super.key,
    required this.smallTabBar,
    this.children = const [],
  });
  final SmallTabBar smallTabBar;
  final List<Widget> children;

  @override
  ConsumerState<CustomTabPage> createState() => _CustomTabPageState();
}

class _CustomTabPageState extends ConsumerState<CustomTabPage> with TickerProviderStateMixin {
  late final double _triggerSmallTabBarDividerOffset = 30;

  late final AnimationController _fadeDividerAController =
      AnimationController(vsync: this, duration: k250msDuration);

  late final Animation<double> _curveDividerFA =
      _fadeDividerAController.drive(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    _fadeDividerAController.value = 0;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.smallTabBar.systemIconBrightness ?? context.appTheme.systemIconBrightnessOnSmallTabBar;
    });
    super.initState();
  }

  @override
  void dispose() {
    _fadeDividerAController.dispose();
    super.dispose();
  }

  late bool _showSmallTabBarDivider = false;

  void _onOffsetChange(double offset) {
    if (offset >= _triggerSmallTabBarDividerOffset && _showSmallTabBarDivider == false) {
      _fadeDividerAController.forward(from: 0);
      _showSmallTabBarDivider = true;
    } else if (offset < _triggerSmallTabBarDividerOffset && _showSmallTabBarDivider == true) {
      _fadeDividerAController.reverse(from: 1);
      _showSmallTabBarDivider = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CustomListView(
          smallTabBar: widget.smallTabBar,
          onOffsetChange: (value) => _onOffsetChange(value),
          children: widget.children,
        ),
        AnimatedBuilder(
            animation: _curveDividerFA,
            child: widget.smallTabBar,
            builder: (BuildContext context, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: !context.appTheme.isDarkTheme
                        ? BorderSide(
                            color: Colors.grey.shade300.withOpacity(_curveDividerFA.value), width: 1.5)
                        : BorderSide.none,
                  ),
                ),
                child: child,
              );
            }),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////

class CustomTabPageWithPageView extends ConsumerStatefulWidget {
  const CustomTabPageWithPageView({
    super.key,
    required this.smallTabBar,
    this.extendedTabBar,
    this.toolBar,
    this.controller,
    this.onPageChanged,
    required this.itemBuilder,
    this.pageItemCount,
    this.onDragLeft,
    this.onDragRight,
  });
  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final Widget? toolBar;
  final PageController? controller;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, WidgetRef, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;

  @override
  ConsumerState<CustomTabPageWithPageView> createState() => _CustomTabPageWithPageViewState();
}

class _CustomTabPageWithPageViewState extends ConsumerState<CustomTabPageWithPageView>
    with TickerProviderStateMixin {
  late final double _sheetMinFraction = 1.0 - kExtendedCustomTabBarHeight / Gap.screenHeight(context);
  late final double _sheetMaxFraction = 1.0 - kCustomTabBarHeight / Gap.screenHeight(context);
  late final double _sheetMinHeight = _sheetMinFraction * Gap.screenHeight(context);
  late final double _triggerSmallTabBarHeight =
      Gap.screenHeight(context) - Gap.statusBarHeight(context) - kCustomTabBarHeight;
  late final double _triggerDividerOffset = 30;

  late final PageController _controller = widget.controller ?? PageController();
  late final DraggableScrollableController _scrollableController = DraggableScrollableController();

  late final AnimationController _translateAController = AnimationController(
    vsync: this,
    duration: k1msDuration,
    lowerBound: 0,
    upperBound: 1000,
  );
  late final AnimationController _fadeAController =
      AnimationController(vsync: this, duration: k250msDuration);
  late final AnimationController _fadeDividerAController =
      AnimationController(vsync: this, duration: k250msDuration);

  late final Animation<double> _curveFA = _fadeAController.drive(
    CurveTween(curve: Curves.easeInOut),
  );
  late final Animation<double> _curveDividerFA = _fadeDividerAController.drive(
    CurveTween(curve: Curves.easeInOut),
  );

  @override
  void initState() {
    _fadeAController.value = 0;
    _fadeDividerAController.value = 0;
    _translateAController.value = 0;
    _scrollableController.addListener(_scrollControllerListener);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.extendedTabBar?.systemIconBrightness ??
              context.appTheme.systemIconBrightnessOnExtendedTabBar;
    });
    super.initState();
  }

  @override
  void dispose() {
    _translateAController.dispose();
    _fadeAController.dispose();
    _fadeDividerAController.dispose();
    _scrollableController.removeListener(_scrollControllerListener);
    _scrollableController.dispose();
    super.dispose();
  }

  late bool _showSmallTabBar = widget.extendedTabBar == null ? true : false;
  late bool _showSmallTabBarDivider = false;

  void _onHeightChange(double height) {
    _translateAController.value = (height - _sheetMinHeight) / 3;

    // At the moment show smallAppBar
    if (height >= _triggerSmallTabBarHeight && _showSmallTabBar == false) {
      _fadeAController.forward(from: 0);
      _showSmallTabBar = true;
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.smallTabBar.systemIconBrightness ?? context.appTheme.systemIconBrightnessOnSmallTabBar;
      // At the moment smallAppBar disappear
    } else if (height < _triggerSmallTabBarHeight && _showSmallTabBar == true) {
      _fadeAController.reverse(from: 1);
      _showSmallTabBar = false;
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.extendedTabBar?.systemIconBrightness ??
              context.appTheme.systemIconBrightnessOnExtendedTabBar;
    }
  }

  void _onListViewOffsetChange(double offset) {
    if (offset >= _triggerDividerOffset && _showSmallTabBarDivider == false) {
      _fadeDividerAController.forward(from: 0);
      _showSmallTabBarDivider = true;
    } else if (offset < _triggerDividerOffset && _showSmallTabBarDivider == true) {
      _fadeDividerAController.reverse(from: 1);
      _showSmallTabBarDivider = false;
    }
  }

  void _scrollControllerListener() {
    double height = _scrollableController.pixels;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _onHeightChange(height);
    });
  }

  Widget _smallTabBar() {
    return widget.extendedTabBar != null
        ? FadeTransition(
            opacity: _curveFA,
            child: AnimatedBuilder(
                animation: _curveFA,
                builder: (_, __) {
                  return IgnorePointer(
                    ignoring: _curveFA.value == 0,
                    child: AnimatedBuilder(
                      animation: _curveDividerFA,
                      builder: (_, child) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: !context.appTheme.isDarkTheme
                                  ? BorderSide(
                                      color: Colors.grey.shade300.withOpacity(_curveDividerFA.value),
                                      width: 1.5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: child,
                        );
                      },
                      child: widget.smallTabBar,
                    ),
                  );
                }),
          )
        : Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: !context.appTheme.isDarkTheme
                    ? BorderSide(
                        color: Colors.grey.shade300.withOpacity(_curveDividerFA.value), width: 1.5)
                    : BorderSide.none,
              ),
            ),
            child: widget.smallTabBar,
          );
  }

  Widget _extendedTabBar() {
    return AnimatedBuilder(
      animation: _translateAController,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, -_translateAController.value),
          child: Container(
            width: double.infinity,
            height: widget.extendedTabBar!.height + Gap.statusBarHeight(context),
            decoration: BoxDecoration(
              color: widget.extendedTabBar?.backgroundColor ??
                  (context.appTheme.isDarkTheme
                      ? context.appTheme.background2
                      : context.appTheme.secondary1),
            ),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(
              top: Gap.statusBarHeight(context),
              bottom: 30,
            ),
            child: widget.extendedTabBar,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _extendedTabBar(),
        DraggableScrollableSheet(
          controller: _scrollableController,
          minChildSize: _sheetMinFraction,
          initialChildSize: _sheetMinFraction,
          maxChildSize: _sheetMaxFraction,
          snap: true,
          snapAnimationDuration: k250msDuration,
          builder: (context, scrollController) {
            return Container(
              height: Gap.screenHeight(context),
              decoration: BoxDecoration(
                  color: context.appTheme.background1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.appTheme.onBackground
                          .withOpacity(context.appTheme.isDarkTheme ? 0.1 : 0.5),
                      blurRadius: 30,
                    )
                  ]),
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  widget.onPageChanged?.call(index);
                },
                itemCount: widget.pageItemCount,
                itemBuilder: (context, pageIndex) => Consumer(
                  builder: (_, ref, __) {
                    return _CustomListView(
                      controller: scrollController,
                      isInsideCustomTabPageWithPageView: true,
                      smallTabBar: widget.smallTabBar,
                      extendedTabBar: widget.extendedTabBar,
                      onOffsetChange: (value) => _onListViewOffsetChange(value),
                      children: widget.itemBuilder(context, ref, pageIndex),
                    );
                  },
                ),
              ),
            );
          },
        ),
        _smallTabBar(),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////

class _CustomListView extends ConsumerStatefulWidget {
  const _CustomListView({
    this.isInsideCustomTabPageWithPageView = false,
    this.controller,
    this.smallTabBar,
    this.extendedTabBar,
    this.children = const [],
    this.onOffsetChange,
  });

  final bool isInsideCustomTabPageWithPageView;
  final ScrollController? controller;
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final List<Widget> children;
  final ValueChanged<double>? onOffsetChange;

  @override
  ConsumerState<_CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends ConsumerState<_CustomListView> {
  late final ScrollController _scrollController =
      widget.controller ?? ScrollController(); // ScrollController used for ListView
  double scrollPixelsOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    if (!widget.isInsideCustomTabPageWithPageView) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _scrollControllerListener() {
    ScrollPosition position = _scrollController.position;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollPixelsOffset = position.pixels;
      widget.onOffsetChange?.call(scrollPixelsOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      controller: _scrollController,
      itemCount: widget.isInsideCustomTabPageWithPageView
          ? widget.children.length + 1
          : widget.children.length + 2,
      itemBuilder: (context, index) {
        if (!widget.isInsideCustomTabPageWithPageView) {
          if (index == 0) {
            return const SizedBox(height: kCustomTabBarHeight);
          }
          if (index == widget.children.length + 1) {
            return const SizedBox(height: 30);
          } else {
            return widget.children[index - 1];
          }
        }

        return index == widget.children.length ? const SizedBox(height: 30) : widget.children[index];
      },
    );
  }
}

final systemIconBrightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);
