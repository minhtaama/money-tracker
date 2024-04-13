import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/expanded_page_view.dart';
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
  late final double _triggerDividerAtListOffset = 30;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    _fadeController = AnimationController(vsync: this, duration: k250msDuration);
    _fadeAnimation = _fadeController.drive(CurveTween(curve: Curves.easeInOut));

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(systemIconBrightnessProvider.notifier).state =
          context.appTheme.systemIconBrightnessOnSmallTabBar;
    });
    super.initState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  late bool _showDivider = false;

  void _onOffsetChange(double offset) {
    if (offset >= _triggerDividerAtListOffset && _showDivider == false) {
      _fadeController.forward(from: 0);
      _showDivider = true;
    }

    if (offset < _triggerDividerAtListOffset && _showDivider == true) {
      _fadeController.reverse(from: 1);
      _showDivider = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: Stack(
        children: [
          _CustomListView(
            smallTabBar: widget.smallTabBar,
            onOffsetChange: (value) => _onOffsetChange(value),
            children: [
              ...widget.children,
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 32,
              )
            ],
          ),
          AnimatedBuilder(
              animation: _fadeAnimation,
              child: widget.smallTabBar,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: !context.appTheme.isDarkTheme
                          ? BorderSide(
                              color: Colors.grey.shade300.withOpacity(_fadeAnimation.value), width: 1.5)
                          : BorderSide.none,
                    ),
                  ),
                  child: child,
                );
              }),
        ],
      ),
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
    this.toolBarHeight = kCustomToolBarHeight,
    this.controller,
    this.onPageChanged,
    required this.itemBuilder,
    this.pageItemCount,
    this.onDragLeft,
    this.onDragRight,
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

  @override
  ConsumerState<CustomTabPageWithPageView> createState() => _CustomTabPageWithPageViewState();
}

class _CustomTabPageWithPageViewState extends ConsumerState<CustomTabPageWithPageView>
    with TickerProviderStateMixin {
  late final double _triggerSmallTabBarHeight = _sheetMaxHeight - 7;
  late final double _triggerDividerOffset = 30;

  late double _sheetMinFraction;
  late double _sheetMaxFraction;
  late double _sheetMinHeight;
  late double _sheetMaxHeight;
  late double _sheetMaxOffset;

  late final _scrollableController = DraggableScrollableController();

  late final AnimationController _tabOffsetController;
  late final AnimationController _fadeTabBarController;
  late final AnimationController _fadeDividerController;

  late final Animation<double> _fadeTabBarAnimation;
  late final Animation<double> _fadeDividerAnimation;

  @override
  void initState() {
    _tabOffsetController = AnimationController(vsync: this, duration: k1msDuration, upperBound: 1000);
    _fadeTabBarController = AnimationController(vsync: this, duration: k250msDuration);
    _fadeDividerController = AnimationController(vsync: this, duration: k250msDuration);

    _fadeTabBarAnimation = _fadeTabBarController.drive(CurveTween(curve: Curves.easeInOut));
    _fadeDividerAnimation = _fadeDividerController.drive(CurveTween(curve: Curves.easeInOut));

    _scrollableController.addListener(_scrollControllerListener);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _changeStatusBrightness();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final safeZoneHeight = (Gap.screenHeight(context) - Gap.statusBarHeight(context));

    _sheetMinFraction = 1.0 - (kExtendedCustomTabBarHeight / safeZoneHeight);
    _sheetMaxFraction = 1.0 - (kCustomTabBarHeight - widget.toolBarHeight) / safeZoneHeight;

    _sheetMinHeight = _sheetMinFraction * Gap.screenHeight(context);
    _sheetMaxHeight = _sheetMaxFraction * Gap.screenHeight(context);
    _sheetMaxOffset = safeZoneHeight - _sheetMinHeight;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabOffsetController.dispose();
    _fadeTabBarController.dispose();
    _fadeDividerController.dispose();
    _scrollableController.removeListener(_scrollControllerListener);
    _scrollableController.dispose();
    super.dispose();
  }

  late bool _isShowSmallTabBar = widget.extendedTabBar == null ? true : false;
  late bool _isShowSmallTabBarDivider = false;

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

  void _onListViewOffsetChange(double offset) {
    if (offset >= _triggerDividerOffset && _isShowSmallTabBarDivider == false) {
      _fadeDividerController.forward(from: 0);
      _isShowSmallTabBarDivider = true;
    }

    if (offset < _triggerDividerOffset && _isShowSmallTabBarDivider == true) {
      _fadeDividerController.reverse(from: 1);
      _isShowSmallTabBarDivider = false;
    }
  }

  void _onPageChange(int index) {
    if (_isShowSmallTabBarDivider == true) {
      _fadeDividerController.reverse(from: 1);
      _isShowSmallTabBarDivider = false;
    }
    widget.onPageChanged?.call(index);
  }

  void _scrollControllerListener() {
    double height = _scrollableController.pixels;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _onSheetHeightChange(height);
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
          builder: (context, scrollController) => _sheetWrapper(
            child: _CustomListView(
              controller: scrollController,
              forPageView: true,
              smallTabBar: widget.smallTabBar,
              extendedTabBar: widget.extendedTabBar,
              onOffsetChange: (value) => _onListViewOffsetChange(value),
              children: [
                widget.toolBar != null
                    ? Transform.translate(
                        offset: const Offset(0, -7),
                        child: SizedBox(
                          height: widget.toolBarHeight,
                          child: widget.toolBar,
                        ),
                      )
                    : Gap.noGap,
                widget.toolBar != null ? Gap.h8 : Gap.noGap,
                ExpandablePageView(
                  controller: widget.controller,
                  onPageChanged: _onPageChange,
                  itemCount: widget.pageItemCount,
                  itemBuilder: (_, pageIndex) => Consumer(
                    builder: (context, ref, _) => Column(
                      children: [
                        ...widget.itemBuilder(context, ref, pageIndex),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 32,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _smallTabBar(),
      ],
    );
  }

  Widget _smallTabBar() {
    return widget.extendedTabBar != null
        ? SizeTransition(
            sizeFactor: _fadeTabBarAnimation,
            child: FadeTransition(
              opacity: _fadeTabBarAnimation,
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeDividerAnimation, _fadeTabBarAnimation]),
                builder: (_, child) {
                  return IgnorePointer(
                    ignoring: _fadeTabBarAnimation.value == 0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: !context.appTheme.isDarkTheme
                              ? BorderSide(
                                  color: Colors.grey.shade300.withOpacity(_fadeDividerAnimation.value),
                                  width: 1.5)
                              : BorderSide.none,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: widget.smallTabBar,
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: !context.appTheme.isDarkTheme
                    ? BorderSide(
                        color: Colors.grey.shade300.withOpacity(_fadeDividerAnimation.value), width: 1.5)
                    : BorderSide.none,
              ),
            ),
            child: widget.smallTabBar,
          );
  }

  Widget _extendedTabBar() {
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
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
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

  Widget _optionalWrapper() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.appTheme.negative,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
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
    );
  }
}

////////////////////////////////////////////////////////////////////////

class _CustomListView extends ConsumerStatefulWidget {
  const _CustomListView({
    this.forPageView = false,
    this.controller,
    this.smallTabBar,
    this.extendedTabBar,
    this.children = const [],
    this.onOffsetChange,
  });

  final bool forPageView;
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
    if (!widget.forPageView) {
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
      controller: _scrollController,
      itemCount: widget.forPageView ? widget.children.length : widget.children.length + 2,
      padding: const EdgeInsets.only(top: 25),
      itemBuilder: (context, index) {
        if (!widget.forPageView) {
          if (index == 0) {
            return const SizedBox(height: kCustomTabBarHeight);
          }
          if (index == widget.children.length + 1) {
            return const SizedBox(height: 30);
          } else {
            return widget.children[index - 1];
          }
        }

        return widget.children[index];
      },
    );
  }
}

final systemIconBrightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);
