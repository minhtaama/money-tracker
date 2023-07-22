import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/provider.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';
import 'custom_tab_bar.dart';

class CustomTabPageWithPageView extends StatefulWidget {
  /// This Widget is used only on HomePage for DateTime changing
  const CustomTabPageWithPageView({
    Key? key,
    this.smallTabBar,
    this.extendedTabBar,
    this.controller,
    this.onPageChanged,
    required this.itemBuilder,
    this.pageItemCount,
    required this.listItemCount,
  }) : super(key: key);
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final PageController? controller;
  final int? pageItemCount;
  final Widget Function(BuildContext, int, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final int listItemCount;

  @override
  State<CustomTabPageWithPageView> createState() => _CustomTabPageWithPageViewState();
}

class _CustomTabPageWithPageViewState extends State<CustomTabPageWithPageView> {
  late final PageController _controller =
      widget.controller ?? PageController(); // PageController used for PageView

  double currentPage = 0;
  double scrollOffset = 0;

  late double appBarHeight = _getAppBarHeight(pixelsOffset: scrollOffset);

  /// Get AppBar height based on current scroll view offset
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

  // Get initial scroll view offset of new page if hasPageView is true
  double _getInitialOffset({required double appBarHeight}) {
    if (widget.smallTabBar != null &&
        widget.extendedTabBar != null &&
        appBarHeight == widget.smallTabBar!.height) {
      return widget.extendedTabBar!.height - widget.smallTabBar!.height;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          onPageChanged: (index) {
            scrollOffset = _getInitialOffset(appBarHeight: appBarHeight);
            setState(() {});
            widget.onPageChanged?.call(index);
          },
          itemCount: widget.pageItemCount,
          itemBuilder: (context, pageIndex) => CustomListViewBuilder(
            smallTabBar: widget.smallTabBar,
            extendedTabBar: widget.extendedTabBar,
            initialOffset: _getInitialOffset(appBarHeight: appBarHeight),
            onOffsetChange: (value) => setState(
              () {
                scrollOffset = value;
                appBarHeight = _getAppBarHeight(
                  pixelsOffset: scrollOffset,
                );
              },
            ),
            itemBuilder: (context, listIndex) => widget.itemBuilder(context, pageIndex, listIndex),
            itemCount: widget.listItemCount,
          ),
        ),
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

class CustomListViewBuilder extends ConsumerStatefulWidget {
  const CustomListViewBuilder({
    Key? key,
    this.smallTabBar,
    this.extendedTabBar,
    required this.itemBuilder,
    required this.itemCount,
    required this.onOffsetChange,
    this.initialOffset = 0,
  }) : super(key: key);

  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final ValueChanged<double> onOffsetChange;
  final double initialOffset;

  @override
  ConsumerState<CustomListViewBuilder> createState() => _CustomListViewState();
}

class _CustomListViewState extends ConsumerState<CustomListViewBuilder> {
  late ScrollController _controller; // ScrollController used for ListView

  double previousOffset = 0;
  double delta = 0;
  double pixelOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: widget.initialOffset);
    _controller.addListener(_scrollControllerListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.position.isScrollingNotifier.addListener(_scrollControllerListener);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollControllerListener);
    _controller.dispose();
    super.dispose();
  }

  void _scrollControllerListener() {
    ScrollPosition position = _controller.position;
    ScrollDirection direction = position.userScrollDirection;

    delta = (position.pixels - previousOffset).abs();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        pixelOffset = position.pixels;
        widget.onOffsetChange(pixelOffset);
      });
    });

    // Read the Provider to change its state
    final provider = ref.read(scrollForwardStateProvider.notifier);

    // Check user scroll direction
    if (direction == ScrollDirection.forward && provider.state == false && delta > 20 ||
        position.pixels == 0) {
      // User scroll down (ListView go up)
      provider.state = true;
    } else if (direction == ScrollDirection.reverse && provider.state == true) {
      // User scroll up (ListView go down)
      provider.state = false;
    }
    previousOffset = position.pixels;
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
      controller: _controller,
      itemCount: widget.itemCount + 2,
      itemBuilder: (context, index) {
        return index == 0
            ? SizedBox(
                height: widget.smallTabBar == null && widget.extendedTabBar == null
                    ? 0
                    : widget.extendedTabBar == null
                        ? widget.smallTabBar!.height
                        : widget.extendedTabBar!.height + 12,
              )
            : index == widget.itemCount + 1
                ? const SizedBox(height: kBottomAppBarHeight + 8)
                : widget.itemBuilder(context, index - 1);
      },
    );
  }
}
