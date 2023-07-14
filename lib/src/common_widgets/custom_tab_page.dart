import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';
import 'card_item.dart';

final scrollForwardStateProvider = StateProvider<bool>((ref) {
  return true;
});

class CustomTabPage extends StatefulWidget {
  const CustomTabPage({
    Key? key,
    this.smallTabBar,
    this.extendedTabBar,
    this.hasPageView = false,
    this.listViewChildren = const [],
    this.pageViewChildren = const {},
  }) : super(key: key);
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final bool hasPageView;
  final List<Widget> listViewChildren;
  final Map<dynamic, List<Widget>> pageViewChildren;

  @override
  State<CustomTabPage> createState() => _CustomTabPageState();
}

class _CustomTabPageState extends State<CustomTabPage> {
  final PageController _pageController = PageController(); // PageController used for PageView
  double currentPage = 0;
  double scrollOffset = 0;

  late double appBarHeight = _getAppBarHeight(pixelsOffset: scrollOffset);

  double _getAppBarHeight({required double pixelsOffset}) {
    if (widget.extendedTabBar != null) {
      double height = (widget.extendedTabBar!.height - pixelsOffset)
          .clamp(widget.smallTabBar?.height ?? 0, widget.extendedTabBar!.height);
      return height;
    } else if (widget.smallTabBar != null) {
      return widget.smallTabBar!.height;
    } else if (widget.extendedTabBar != null) {
      return widget.extendedTabBar!.height;
    } else {
      return 0;
    }
  }

  double _getInitialOffset({required double appBarHeight}) {
    if (widget.smallTabBar != null &&
        widget.extendedTabBar != null &&
        appBarHeight == widget.smallTabBar!.height) {
      return widget.extendedTabBar!.height - widget.smallTabBar!.height;
    } else {
      return 0;
    }
  }

  PageView pageViewBuilder(Map<dynamic, List<Widget>> mapChildren) {
    final mapKeysList = mapChildren.keys.toList();
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (_) {
        scrollOffset = _getInitialOffset(appBarHeight: appBarHeight);
        setState(() {});
      },
      itemCount: mapKeysList.length,
      itemBuilder: (context, index) => CustomListView(
        smallTabBar: widget.smallTabBar,
        extendedTabBar: widget.extendedTabBar,
        initialOffset: _getInitialOffset(appBarHeight: appBarHeight),
        onOffsetChange: (value) => setState(() {
          scrollOffset = value;
          appBarHeight = _getAppBarHeight(
            pixelsOffset: scrollOffset,
          );
        }),
        children: mapChildren[mapKeysList[index]]!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        !widget.hasPageView
            ? CustomListView(
                smallTabBar: widget.smallTabBar,
                extendedTabBar: widget.extendedTabBar,
                onOffsetChange: (value) => setState(() => scrollOffset = value),
                children: widget.listViewChildren,
              )
            : pageViewBuilder(widget.pageViewChildren),
        CustomTabBar(
          smallTabBar: widget.smallTabBar,
          extendedTabBar: widget.extendedTabBar,
          height: appBarHeight,
          pixelOffset: scrollOffset,
        ),
      ],
    );
  }
}

class CustomListView extends ConsumerStatefulWidget {
  const CustomListView({
    Key? key,
    this.smallTabBar,
    this.extendedTabBar,
    this.children = const [],
    required this.onOffsetChange,
    this.initialOffset = 0,
  }) : super(key: key);

  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final List<Widget> children;
  final ValueChanged<double> onOffsetChange;
  final double initialOffset;

  @override
  ConsumerState<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends ConsumerState<CustomListView> {
  late ScrollController _scrollController; // ScrollController used for ListView

  double scrollPreviousPositionPixels = 0;
  double scrollDeltaPosition = 0;
  double scrollPixelsOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: widget.initialOffset);
    _scrollController.addListener(_scrollControllerListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.position.isScrollingNotifier.addListener(_scrollControllerListener);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollControllerListener() {
    ScrollPosition position = _scrollController.position;
    ScrollDirection direction = position.userScrollDirection;

    scrollDeltaPosition = (position.pixels - scrollPreviousPositionPixels).abs();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        scrollPixelsOffset = position.pixels;
        widget.onOffsetChange(scrollPixelsOffset);
      });
    });

    // Read the Provider to change its state
    final provider = ref.read(scrollForwardStateProvider.notifier);

    // Check user scroll direction
    if (direction == ScrollDirection.forward && provider.state == false && scrollDeltaPosition > 20 ||
        position.pixels == 0) {
      // User scroll down (ListView go up)
      provider.state = true;
    } else if (direction == ScrollDirection.reverse && provider.state == true) {
      // User scroll up (ListView go down)
      provider.state = false;
    }
    scrollPreviousPositionPixels = position.pixels;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.smallTabBar != null
          ? SnapScrollPhysics(
              snaps: [
                Snap.avoidZone(
                    0,
                    widget.extendedTabBar != null
                        ? widget.extendedTabBar!.height - widget.smallTabBar!.height
                        : 30)
              ],
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
                        : widget.extendedTabBar!.height + 12,
              )
            : index == widget.children.length + 1
                ? const SizedBox(height: kBottomAppBarHeight + 8)
                : widget.children[index - 1];
      },
    );
  }
}

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    Key? key,
    required this.height,
    this.extendedTabBar,
    this.smallTabBar,
    required this.pixelOffset,
  }) : super(key: key);

  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final double height;
  final double pixelOffset;

  double _getAppBarChildOpacity({required bool isExtendedChild, required double appBarHeight}) {
    final height = appBarHeight;

    if (extendedTabBar != null && smallTabBar != null) {
      double opacity = (height - smallTabBar!.height) / (extendedTabBar!.height - smallTabBar!.height);
      if (isExtendedChild) {
        return opacity;
      } else {
        return 1 - opacity;
      }
    } else {
      return 1;
    }
  }

  Widget _animateChangingChild(double appBarHeight) {
    double childOpacity = _getAppBarChildOpacity(isExtendedChild: false, appBarHeight: appBarHeight);
    double extendedChildOpacity =
        _getAppBarChildOpacity(isExtendedChild: true, appBarHeight: appBarHeight);

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: extendedChildOpacity,
          duration: kNoDuration,
          child: IgnorePointer(
            ignoring: extendedChildOpacity == 1 ? false : true,
            child: extendedTabBar ?? const SizedBox(),
          ),
        ),
        AnimatedOpacity(
          opacity: childOpacity,
          duration: kNoDuration,
          child: IgnorePointer(
            ignoring: childOpacity == 1 ? false : true,
            child: smallTabBar ?? const SizedBox(),
          ),
        ),
      ],
    );
  }

  bool _isShowDivider(double pixelsOffset) {
    if (extendedTabBar != null && smallTabBar != null) {
      return pixelsOffset > extendedTabBar!.height - smallTabBar!.height;
    } else if (extendedTabBar == null && smallTabBar != null) {
      return pixelsOffset > 15;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height + statusBarHeight,
      child: AnimatedContainer(
          duration: kBottomAppBarDuration,
          decoration: BoxDecoration(
            border: Border(
              bottom: _isShowDivider(pixelOffset) && !context.appTheme.isDarkTheme
                  ? BorderSide(color: Colors.grey.shade700, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: _animateChangingChild(height)),
    );
  }
}

class SmallTabBar extends StatelessWidget {
  const SmallTabBar({
    Key? key,
    this.backgroundColor,
    required this.child,
    this.height = kCustomTabBarHeight,
  }) : super(key: key);
  final Color? backgroundColor;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: Gap.statusBarHeight(context)),
      margin: EdgeInsets.zero,
      color: backgroundColor ?? context.appTheme.background,
      child: child,
    );
  }
}

class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar({
    super.key,
    this.backgroundColor,
    required this.innerChild,
    this.outerChild,
    this.height = kExtendedCustomTabBarHeight,
    this.outerChildHeight = kOuterChildHeight,
  });
  final Color? backgroundColor;
  final Widget innerChild;
  final Widget? outerChild;
  final double height;
  final double outerChildHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform(
          transform: Matrix4.translationValues(0.0, -outerChildHeight / 2, 0.0),
          child: CardItem(
            width: double.infinity,
            height: double.infinity,
            isGradient: context.appTheme.isDarkTheme ? false : true,
            color: backgroundColor ??
                (context.appTheme.isDarkTheme
                    ? context.appTheme.background2
                    : context.appTheme.secondary),
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.zero,
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: outerChild != null ? 22.0 : 0,
                top: Gap.statusBarHeight(context) + outerChildHeight / 2),
            elevation: context.appTheme.isDarkTheme ? 0 : 2,
            child: innerChild,
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: outerChild),
      ],
    );
  }
}
