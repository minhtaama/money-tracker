part of 'custom_page.dart';

class CustomAdaptivePageView extends StatelessWidget {
  const CustomAdaptivePageView({
    super.key,
    required this.smallTabBar,
    this.extendedTabBar,
    this.toolBar,
    this.toolBarBuilder,
    this.toolBarHeight = kCustomToolBarHeight,
    this.pageController,
    this.onPageChanged,
    required this.itemBuilder,
    this.pageItemCount,
    this.onDragLeft,
    this.onDragRight,
    this.forcePageView = false,
    this.forceShowSmallTabBar = false,
  });

  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;

  /// For normal view
  final Widget? toolBar;

  /// For scrollable sheet
  final Widget Function(int)? toolBarBuilder;
  final double toolBarHeight;
  final PageController? pageController;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, WidgetRef, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;

  final bool forcePageView;
  final bool forceShowSmallTabBar;

  @override
  Widget build(BuildContext context) {
    if (context.isBigScreen || forcePageView) {
      return _NormalList(
        smallTabBar: smallTabBar,
        extendedTabBar: extendedTabBar,
        toolBar: toolBar,
        toolBarHeight: toolBarHeight,
        pageController: pageController,
        onPageChanged: onPageChanged,
        itemBuilder: itemBuilder,
        pageItemCount: pageItemCount,
        onDragLeft: onDragLeft,
        onDragRight: onDragRight,
      );
    }

    return _ScrollableSheet(
      smallTabBar: smallTabBar,
      extendedTabBar: extendedTabBar,
      toolBarBuilder: toolBarBuilder,
      toolBarHeight: toolBarHeight,
      pageController: pageController,
      onPageChanged: onPageChanged,
      itemBuilder: itemBuilder,
      pageItemCount: pageItemCount,
      onDragLeft: onDragLeft,
      onDragRight: onDragRight,
      forceShowSmallTabBar: forceShowSmallTabBar,
    );
  }
}

class _ScrollableSheet extends ConsumerStatefulWidget {
  const _ScrollableSheet({
    super.key,
    required this.smallTabBar,
    required this.extendedTabBar,
    required this.toolBarBuilder,
    required this.toolBarHeight,
    required this.pageController,
    required this.onPageChanged,
    required this.itemBuilder,
    required this.pageItemCount,
    required this.onDragLeft,
    required this.onDragRight,
    required this.forceShowSmallTabBar,
  }) : assert(toolBarHeight <= kCustomTabBarHeight);

  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final Widget Function(int)? toolBarBuilder;
  final double toolBarHeight;
  final PageController? pageController;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, WidgetRef, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;
  final bool forceShowSmallTabBar;

  @override
  ConsumerState<_ScrollableSheet> createState() => _ScrollableSheetState();
}

class _ScrollableSheetState extends ConsumerState<_ScrollableSheet> with TickerProviderStateMixin {
  late double _triggerSmallTabBarHeight;
  late double _sheetMinFraction;
  late double _sheetMaxFraction;
  late double _sheetMinHeight;
  late double _sheetMaxHeight;
  late double _sheetMaxOffset;

  late final _sheetController = DraggableScrollableController();
  late final _pageController = widget.pageController ?? PageController();

  late final _sheetOffsetAnimController = AnimationController(vsync: this, duration: k1msDuration, upperBound: 1000);

  late final _smallTabBarAnimController = AnimationController(vsync: this, duration: k250msDuration);
  late final _smallTabBarAnimation = _smallTabBarAnimController.drive(CurveTween(curve: Curves.easeInOut));

  late final _sheetAnimController = AnimationController(vsync: this, duration: k150msDuration);
  late final _sheetAnimation = _sheetAnimController.drive(CurveTween(curve: Curves.fastOutSlowIn));

  late bool _isShowSmallTabBar = widget.extendedTabBar == null ? true : false;
  late bool _shouldScaleDownSheet = true;
  late bool _isScaleDownSheet = false;

  @override
  void initState() {
    _sheetController.addListener(_sheetControllerListener);
    _pageController.addListener(_pageControllerListener);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _changeStatusBrightness();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ScrollableSheet oldWidget) {
    if (widget.forceShowSmallTabBar && !oldWidget.forceShowSmallTabBar) {
      double height = _sheetController.pixels;
      if (height < _triggerSmallTabBarHeight) {
        _showSmallTabBar();
      } else {
        _onSheetHeightChange(height);
      }
    }

    if (!widget.forceShowSmallTabBar && oldWidget.forceShowSmallTabBar) {
      double height = _sheetController.pixels;
      _onSheetHeightChange(height);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    setState(() {
      final screenHeight = Gap.screenHeight(context);
      _sheetMinFraction = 1.0 - (kExtendedCustomTabBarHeight / screenHeight);
      _sheetMaxFraction = 1.0 - (Gap.statusBarHeight(context) / screenHeight);
      _sheetMinHeight = _sheetMinFraction * Gap.screenHeight(context);
      _sheetMaxHeight = _sheetMaxFraction * Gap.screenHeight(context);
      _sheetMaxOffset = screenHeight - _sheetMinHeight;
      _triggerSmallTabBarHeight = _sheetMaxHeight - 7;
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _sheetOffsetAnimController.dispose();
    _smallTabBarAnimController.dispose();
    _sheetController.removeListener(_sheetControllerListener);
    _sheetController.dispose();
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onSheetHeightChange(double height) {
    _sheetOffsetAnimController.value = (height - _sheetMinHeight) / 3;

    // At the moment show smallAppBar
    if (height >= _triggerSmallTabBarHeight && _shouldScaleDownSheet) {
      _shouldScaleDownSheet = false;
    }

    // At the moment smallAppBar disappear
    if (height < _triggerSmallTabBarHeight && !_shouldScaleDownSheet) {
      _shouldScaleDownSheet = true;
    }

    if (widget.forceShowSmallTabBar) {
      return;
    }

    // At the moment show smallAppBar
    if (height >= _triggerSmallTabBarHeight && !_isShowSmallTabBar) {
      _showSmallTabBar();
    }

    // At the moment smallAppBar disappear
    if (height < _triggerSmallTabBarHeight && _isShowSmallTabBar) {
      _hideSmallTabBar();
    }
  }

  void _showSmallTabBar() {
    _smallTabBarAnimController.forward(from: 0);
    _isShowSmallTabBar = true;
    _changeStatusBrightness();
  }

  void _hideSmallTabBar() {
    _smallTabBarAnimController.reverse(from: 1);
    _isShowSmallTabBar = false;
    _changeStatusBrightness();
  }

  void _onPageChange(int index) {
    if (_isShowSmallTabBar) {
      HapticFeedback.vibrate();
    }
    widget.onPageChanged?.call(index);
  }

  void _sheetControllerListener() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (_sheetController.isAttached) {
        double height = _sheetController.pixels;
        _onSheetHeightChange(height);
      }
    });
  }

  void _pageControllerListener() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (_pageController.hasClients) {
        double page = _pageController.page!;
        _scalingSheet(page);
      }
    });
  }

  void _scalingSheet(double page) {
    if ((page - page.floor() < 0.98 && page - page.floor() > 0.02) && !_isScaleDownSheet && _shouldScaleDownSheet) {
      _sheetAnimController.forward();
      _isScaleDownSheet = true;
    }

    if ((page - page.floor() > 0.98 || page - page.floor() < 0.02) && _isScaleDownSheet && _shouldScaleDownSheet) {
      _sheetAnimController.reverse().whenComplete(() => HapticFeedback.vibrate());
      _isScaleDownSheet = false;
    }
  }

  void _changeStatusBrightness() {
    final statusBrnNotifier = ref.read(systemIconBrightnessProvider.notifier);

    if (_isShowSmallTabBar) {
      statusBrnNotifier.state = context.appTheme.systemIconBrightnessOnSmallTabBar;
      return;
    }

    if (widget.extendedTabBar?.backgroundColor != null) {
      final lum = widget.extendedTabBar!.backgroundColor!.computeLuminance();
      if (lum < 0.5) {
        statusBrnNotifier.state = Brightness.light;
      } else {
        statusBrnNotifier.state = Brightness.dark;
      }
      return;
    }

    statusBrnNotifier.state = context.appTheme.systemIconBrightnessOnExtendedTabBar;
  }

  Widget _smallTabBar() {
    return widget.extendedTabBar != null
        ? SizeTransition(
            sizeFactor: _smallTabBarAnimation,
            child: FadeTransition(
              opacity: _smallTabBarAnimation,
              child: AnimatedBuilder(
                animation: _smallTabBarAnimation,
                builder: (_, child) {
                  return IgnorePointer(
                    ignoring: _smallTabBarAnimation.value == 0,
                    child: child,
                  );
                },
                child: widget.smallTabBar,
              ),
            ),
          )
        : widget.smallTabBar;
  }

  /// Actually the widget display above and behind scrollable-sheet.
  Widget _extendedTabBar() {
    final bgColor = widget.extendedTabBar?.backgroundColor ??
        (context.appTheme.isDarkTheme ? context.appTheme.background2 : context.appTheme.background0);

    return AnimatedBuilder(
      animation: _sheetOffsetAnimController,
      builder: (_, child) {
        return Stack(
          children: [
            Container(
              color: widget.extendedTabBar?.backgroundColor ??
                  (context.appTheme.isDarkTheme ? context.appTheme.background2 : context.appTheme.background0),
            ),
            Opacity(
              opacity: 1 - (3 * _sheetOffsetAnimController.value / _sheetMaxOffset).clamp(0, 1),
              child: Container(
                color: widget.extendedTabBar?.overlayColor?.withOpacity(0.08),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -_sheetOffsetAnimController.value),
              child: Container(
                width: double.infinity,
                height: widget.extendedTabBar!.height - Gap.statusBarHeight(context) + 20,
                color: bgColor,
                padding: EdgeInsets.only(top: Gap.statusBarHeight(context)),
                child: Opacity(
                  opacity: 1 - (3 * _sheetOffsetAnimController.value / _sheetMaxOffset).clamp(0, 1),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      child: widget.extendedTabBar,
    );
  }

  Widget _sheetWrapper({required Widget child}) {
    return AnimatedBuilder(
      animation: _sheetAnimation,
      builder: (context, animChild) {
        return Transform.scale(
          scale: 1 - 0.045 * _sheetAnimation.value,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: context.appTheme.background1,
              border: Border(
                top: BorderSide(color: context.appTheme.onBackground.withOpacity(0.12 * _sheetAnimation.value)),
                left: BorderSide(color: context.appTheme.onBackground.withOpacity(0.12 * _sheetAnimation.value)),
                right: BorderSide(color: context.appTheme.onBackground.withOpacity(0.12 * _sheetAnimation.value)),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _extendedTabBar(),
        DraggableScrollableSheet(
          controller: _sheetController,
          minChildSize: _sheetMinFraction,
          initialChildSize: _sheetMinFraction,
          maxChildSize: _sheetMaxFraction,
          snap: true,
          snapAnimationDuration: k250msDuration,
          builder: (context, scrollController) => PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChange,
            itemCount: widget.pageItemCount,
            itemBuilder: (_, pageIndex) => Consumer(
              builder: (context, ref, _) => _sheetWrapper(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    widget.toolBarBuilder != null
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: (kCustomTabBarHeight - kCustomToolBarHeight) / 2),
                            child: SizedBox(
                              height: kCustomToolBarHeight,
                              child: widget.toolBarBuilder!.call(pageIndex),
                            ),
                          )
                        : Gap.noGap,
                    ...widget.itemBuilder(context, ref, pageIndex),
                    const SizedBox(
                      height: kBottomAppBarHeight + 50,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        _smallTabBar(),
      ],
    );
  }
}

class _NormalList extends StatelessWidget {
  const _NormalList({
    super.key,
    required this.smallTabBar,
    required this.extendedTabBar,
    required this.toolBar,
    required this.toolBarHeight,
    required this.pageController,
    required this.onPageChanged,
    required this.itemBuilder,
    required this.pageItemCount,
    required this.onDragLeft,
    required this.onDragRight,
  }) : assert(toolBarHeight <= kCustomTabBarHeight);

  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final Widget? toolBar;
  final double toolBarHeight;
  final PageController? pageController;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, WidgetRef, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;

  void _onPageChange(int index) {
    HapticFeedback.vibrate();
    onPageChanged?.call(index);
  }

  Widget _extendedTabBarForPageView() {
    return Container(
      width: double.infinity,
      height: extendedTabBar!.height,
      padding: const EdgeInsets.only(bottom: 52),
      child: extendedTabBar,
    );
  }

  Widget _toolBarForPageView(BuildContext context) {
    final bgColor = context.appTheme.background0;

    return toolBar != null
        ? CardItem(
            width: double.infinity,
            color: bgColor,
            elevation: 1.5,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: toolBarHeight,
              child: toolBar,
            ),
          )
        : Gap.noGap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  _extendedTabBarForPageView(),
                  _toolBarForPageView(context),
                ],
              ),
            ),
          ],
          body: PageView.builder(
            controller: pageController,
            onPageChanged: _onPageChange,
            itemCount: pageItemCount,
            itemBuilder: (_, pageIndex) => Consumer(
              builder: (context, ref, _) => ListView(
                children: [
                  ...itemBuilder(context, ref, pageIndex),
                  const SizedBox(
                    height: kBottomAppBarHeight,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
