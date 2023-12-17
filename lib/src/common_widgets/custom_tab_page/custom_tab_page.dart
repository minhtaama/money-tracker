import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';
import 'custom_tab_bar.dart';
import 'dart:math' as math;

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

  late final AnimationController _fadeDividerAController = AnimationController(vsync: this, duration: k250msDuration);

  late final Animation<double> _curveDividerFA = _fadeDividerAController.drive(CurveTween(curve: Curves.easeInOut));

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
          initialOffset: 0,
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
                        ? BorderSide(color: Colors.grey.shade300.withOpacity(_curveDividerFA.value), width: 1.5)
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
    this.controller,
    this.onPageChanged,
    required this.itemBuilder,
    this.pageItemCount,
    this.onDragLeft,
    this.onDragRight,
  });
  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final PageController? controller;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;

  @override
  ConsumerState<CustomTabPageWithPageView> createState() => _CustomTabPageWithPageViewState();
}

class _CustomTabPageWithPageViewState extends ConsumerState<CustomTabPageWithPageView> with TickerProviderStateMixin {
  late final double _triggerOffset = kExtendedCustomTabBarHeight - kCustomTabBarHeight - 15;
  late final double _triggerSmallTabBarDividerOffset = _triggerOffset + 30;

  late final PageController _controller = widget.controller ?? PageController();

  late final AnimationController _translateAController = AnimationController(
      vsync: this,
      duration: k1msDuration,
      lowerBound: 0,
      upperBound: (widget.extendedTabBar?.height ?? kExtendedCustomTabBarHeight) +
          (widget.extendedTabBar?.outerChildHeight ?? kExtendedTabBarOuterChildHeight));

  late final AnimationController _fadeAController = AnimationController(vsync: this, duration: k250msDuration);

  late final AnimationController _fadeDividerAController = AnimationController(vsync: this, duration: k250msDuration);

  late final Animation<double> _curveFA = _fadeAController.drive(CurveTween(curve: Curves.easeInOut));

  late final Animation<double> _curveDividerFA = _fadeDividerAController.drive(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    _fadeAController.value = 1;
    _fadeDividerAController.value = 0;
    _translateAController.value = 0;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.extendedTabBar?.systemIconBrightness ?? context.appTheme.systemIconBrightnessOnExtendedTabBar;
    });
    super.initState();
  }

  @override
  void dispose() {
    _translateAController.dispose();
    super.dispose();
  }

  late bool _showExtendedTabBar = widget.extendedTabBar != null ? true : false;
  late bool _showSmallTabBarDivider = false;

  void _onOffsetChange(double offset) {
    _translateAController.value = offset;

    // At the moment extendedTabBar disappear and show smallAppBar
    if (offset >= _triggerOffset && _showExtendedTabBar == true) {
      _fadeAController.reverse(from: 1);
      _showExtendedTabBar = false;
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.smallTabBar.systemIconBrightness ?? context.appTheme.systemIconBrightnessOnSmallTabBar;
      // At the moment smallAppBar disappear and show extendedTabBar
    } else if (offset < _triggerOffset && _showExtendedTabBar == false) {
      _fadeAController.forward(from: 0);
      _showExtendedTabBar = true;
      ref.read(systemIconBrightnessProvider.notifier).state =
          widget.extendedTabBar?.systemIconBrightness ?? context.appTheme.systemIconBrightnessOnExtendedTabBar;
    }

    if (offset >= _triggerSmallTabBarDividerOffset && _showSmallTabBarDivider == false) {
      _fadeDividerAController.forward(from: 0);
      _showSmallTabBarDivider = true;
    } else if (offset < _triggerSmallTabBarDividerOffset && _showSmallTabBarDivider == true) {
      _fadeDividerAController.reverse(from: 1);
      _showSmallTabBarDivider = false;
    }
  }

  void _onPageChange() {
    ref.read(systemIconBrightnessProvider.notifier).state =
        widget.extendedTabBar?.systemIconBrightness ?? context.appTheme.systemIconBrightnessOnExtendedTabBar;
    _translateAController.reverse();
    _fadeAController.forward();
    _showExtendedTabBar = true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < -10) {
              widget.onDragRight?.call();
            }
            if (details.delta.dx > 10) {
              widget.onDragLeft?.call();
            }
          },
          child: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            onPageChanged: (index) {
              _onPageChange();
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.pageItemCount,
            itemBuilder: (context, pageIndex) => _CustomListView(
              smallTabBar: widget.smallTabBar,
              extendedTabBar: widget.extendedTabBar,
              initialOffset: 0,
              onOffsetChange: (value) => _onOffsetChange(value),
              children: widget.itemBuilder(context, pageIndex),
            ),
          ),
        ),
        widget.extendedTabBar != null
            ? FadeTransition(
                opacity: ReverseAnimation(_curveFA),
                child: AnimatedBuilder(
                    animation: _curveDividerFA,
                    child: widget.smallTabBar,
                    builder: (BuildContext context, Widget? child) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: !context.appTheme.isDarkTheme
                                ? BorderSide(color: Colors.grey.shade300.withOpacity(_curveDividerFA.value), width: 1.5)
                                : BorderSide.none,
                          ),
                        ),
                        child: child,
                      );
                    }),
              )
            : Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: !context.appTheme.isDarkTheme
                        ? BorderSide(color: Colors.grey.shade300.withOpacity(_curveDividerFA.value), width: 1.5)
                        : BorderSide.none,
                  ),
                ),
                child: widget.smallTabBar,
              ),
        AnimatedBuilder(
          animation: _fadeAController,
          builder: (BuildContext context, Widget? child) {
            return IgnorePointer(
              ignoring: _fadeAController.value == 0,
              child: AnimatedBuilder(
                animation: _translateAController,
                builder: (BuildContext context, Widget? child) {
                  return Transform.translate(
                    offset: Offset(0, -_translateAController.value),
                    child: FadeTransition(
                        opacity: _curveFA,
                        child: Stack(
                          children: [
                            SizedBox(
                              height: kExtendedCustomTabBarHeight + Gap.statusBarHeight(context),
                              child: Container(
                                width: double.infinity,
                                height: kExtendedCustomTabBarHeight + Gap.statusBarHeight(context),
                                color: widget.extendedTabBar?.backgroundColor ??
                                    (context.appTheme.isDarkTheme
                                        ? context.appTheme.background2
                                        : context.appTheme.secondary),
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: Gap.statusBarHeight(context),
                                  bottom: 30,
                                ),
                                child: AnimatedBuilder(
                                  animation: _translateAController,
                                  builder: (BuildContext context, Widget? child) {
                                    return Transform.translate(
                                      offset: Offset(0, _translateAController.value / 3),
                                      child: child,
                                    );
                                  },
                                  child: widget.extendedTabBar,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 25,
                                decoration: BoxDecoration(
                                    color: context.appTheme.background,
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(100), topLeft: Radius.circular(100)),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.black.withOpacity(0.3), blurRadius: 4),
                                    ]),
                              ),
                            ),
                          ],
                        )),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////

class _CustomListView extends ConsumerStatefulWidget {
  const _CustomListView({
    this.smallTabBar,
    this.extendedTabBar,
    this.children = const [],
    this.onOffsetChange,
    this.initialOffset = 0,
  });

  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final List<Widget> children;
  final ValueChanged<double>? onOffsetChange;
  final double initialOffset;

  @override
  ConsumerState<_CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends ConsumerState<_CustomListView> {
  late ScrollController _scrollController; // ScrollController used for ListView
  double scrollPixelsOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: widget.initialOffset);
    _scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    _scrollController.dispose();
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
      physics: widget.smallTabBar != null && widget.extendedTabBar != null
          ? SnapScrollPhysics(
              parent: const AlwaysScrollableScrollPhysics(),
              snaps: [Snap.avoidZone(0, widget.extendedTabBar!.height - widget.smallTabBar!.height)],
            )
          : const ClampingScrollPhysics(),
      controller: _scrollController,
      itemCount: widget.children.length + 2,
      itemBuilder: (context, index) {
        return index == 0
            ? SizedBox(
                height: widget.smallTabBar == null && widget.extendedTabBar == null
                    ? 0
                    : widget.extendedTabBar == null
                        ? widget.smallTabBar!.height
                        : widget.extendedTabBar!.height,
              )
            : index == widget.children.length + 1
                ? const SizedBox(height: 30)
                : widget.children[index - 1];
      },
    );
  }
}

final systemIconBrightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);
