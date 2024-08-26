part of 'custom_page.dart';

class CustomAdaptivePageView extends ConsumerStatefulWidget {
  const CustomAdaptivePageView({
    super.key,
    required this.smallTabBar,
    this.extendedTabBar,
    this.toolBar,
    this.toolBarHeight = kCustomToolBarHeight,
    this.controller,
    this.onPageChanged,
    required this.itemBuilder,
    this.pageItemCount,
    this.onDragLeft,
    this.onDragRight,
    this.forcePageView = false,
  }) : assert(toolBarHeight <= kCustomTabBarHeight);

  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final Widget? toolBar;
  final double toolBarHeight;
  final PageController? controller;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, WidgetRef, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;
  final bool forcePageView;

  @override
  ConsumerState<CustomAdaptivePageView> createState() => _CustomPageViewWithScrollableSheetState();
}

class _CustomPageViewWithScrollableSheetState extends ConsumerState<CustomAdaptivePageView>
    with TickerProviderStateMixin {
  late double _triggerSmallTabBarHeight;
  late double _sheetMinFraction;
  late double _sheetMaxFraction;
  late double _sheetMinHeight;
  late double _sheetMaxHeight;
  late double _sheetMaxOffset;

  late final _scrollableController = DraggableScrollableController();

  late final AnimationController _tabOffsetController;
  late final AnimationController _fadeTabBarController;

  late final Animation<double> _fadeTabBarAnimation;

  late bool _isShowSmallTabBar = widget.extendedTabBar == null ? true : false;

  @override
  void initState() {
    _tabOffsetController = AnimationController(vsync: this, duration: k1msDuration, upperBound: 1000);
    _fadeTabBarController = AnimationController(vsync: this, duration: k250msDuration);

    _fadeTabBarAnimation = _fadeTabBarController.drive(CurveTween(curve: Curves.easeInOut));

    _scrollableController.addListener(_scrollControllerListener);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _changeStatusBrightness();
    });

    super.initState();
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
    _tabOffsetController.dispose();
    _fadeTabBarController.dispose();
    _scrollableController.removeListener(_scrollControllerListener);
    _scrollableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isBigScreen || widget.forcePageView) {
      return _pageView();
    }
    return _scrollableSheet();
  }

  Widget _scrollableSheet() {
    return Stack(
      children: [
        _extendedTabBarForScrollableSheet(),
        DraggableScrollableSheet(
          controller: _scrollableController,
          minChildSize: _sheetMinFraction,
          initialChildSize: _sheetMinFraction,
          maxChildSize: _sheetMaxFraction,
          snap: true,
          snapAnimationDuration: k250msDuration,
          builder: (context, scrollController) => PageView.builder(
            controller: widget.controller,
            onPageChanged: _onPageChange,
            itemCount: widget.pageItemCount,
            itemBuilder: (_, pageIndex) => Consumer(
              builder: (context, ref, _) => _sheetWrapper(
                child: ListView(
                  controller: scrollController,
                  children: [
                    widget.toolBar != null
                        ? Transform.translate(
                            offset: const Offset(0, -7),
                            child: SizedBox(
                              height: kCustomToolBarHeight,
                              child: widget.toolBar!,
                            ),
                          )
                        : Gap.noGap,
                    ...widget.itemBuilder(context, ref, pageIndex),
                    const SizedBox(
                      height: kBottomAppBarHeight,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        _smallTabBarForScrollableSheet(),
      ],
    );
  }

  Widget _pageView() {
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
                  _toolBarForPageView(),
                ],
              ),
            ),
          ],
          body: PageView.builder(
            controller: widget.controller,
            onPageChanged: _onPageChange,
            itemCount: widget.pageItemCount,
            itemBuilder: (_, pageIndex) => Consumer(
              builder: (context, ref, _) => ListView(
                children: [
                  ...widget.itemBuilder(context, ref, pageIndex),
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

extension _ScrollableSheetFunctions on _CustomPageViewWithScrollableSheetState {
  void _onSheetHeightChange(double height) {
    _tabOffsetController.value = (height - _sheetMinHeight) / 3;

    // At the moment show smallAppBar
    if (height >= _triggerSmallTabBarHeight && _isShowSmallTabBar == false) {
      _showSmallTabBar();
    }

    // At the moment smallAppBar disappear
    if (height < _triggerSmallTabBarHeight && _isShowSmallTabBar == true) {
      _showExtendedTabBar();
    }
  }

  void _showSmallTabBar() {
    _fadeTabBarController.forward(from: 0);
    _isShowSmallTabBar = true;
    _changeStatusBrightness();
  }

  void _showExtendedTabBar() {
    _fadeTabBarController.reverse(from: 1);
    _isShowSmallTabBar = false;
    _changeStatusBrightness();
  }

  void _onPageChange(int index) {
    HapticFeedback.vibrate();
    widget.onPageChanged?.call(index);
  }

  void _scrollControllerListener() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollableController.isAttached) {
        double height = _scrollableController.pixels;
        _onSheetHeightChange(height);
      }
    });
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

  Widget _smallTabBarForScrollableSheet() {
    return widget.extendedTabBar != null
        ? SizeTransition(
            sizeFactor: _fadeTabBarAnimation,
            child: FadeTransition(
              opacity: _fadeTabBarAnimation,
              child: AnimatedBuilder(
                animation: _fadeTabBarAnimation,
                builder: (_, child) {
                  return IgnorePointer(
                    ignoring: _fadeTabBarAnimation.value == 0,
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
  Widget _extendedTabBarForScrollableSheet() {
    final bgColor = widget.extendedTabBar?.backgroundColor ??
        (context.appTheme.isDarkTheme ? context.appTheme.background2 : context.appTheme.background0);

    return AnimatedBuilder(
      animation: _tabOffsetController,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, -_tabOffsetController.value),
          child: Container(
            width: double.infinity,
            height: widget.extendedTabBar!.height - Gap.statusBarHeight(context) + 22,
            color: bgColor,
            padding: EdgeInsets.only(top: Gap.statusBarHeight(context)),
            child: Opacity(
              opacity: 1 - (3 * _tabOffsetController.value / _sheetMaxOffset).clamp(0, 1),
              child: child,
            ),
          ),
        );
      },
      child: widget.extendedTabBar,
    );
  }

  Widget _sheetWrapper({required Widget child}) {
    return Container(
      height: Gap.screenHeight(context),
      decoration: BoxDecoration(
        color: context.appTheme.background1,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.extendedTabBar?.backgroundColor ?? context.appTheme.background0)
                .withOpacity(context.appTheme.isDarkTheme ? 0.0 : 1),
            blurRadius: 7,
            spreadRadius: 5,
          )
        ],
      ),
      child: child,
    );
  }

  Widget _extendedTabBarForPageView() {
    return Container(
      width: double.infinity,
      height: widget.extendedTabBar!.height,
      padding: const EdgeInsets.only(bottom: 52),
      child: widget.extendedTabBar,
    );
  }

  Widget _toolBarForPageView() {
    final bgColor = context.appTheme.background0;

    return widget.toolBar != null
        ? CardItem(
            width: double.infinity,
            color: bgColor,
            elevation: 1.5,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: widget.toolBarHeight,
              child: widget.toolBar,
            ),
          )
        : Gap.noGap;
  }
}
