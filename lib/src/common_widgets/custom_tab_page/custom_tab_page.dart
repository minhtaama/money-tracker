import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';
import 'custom_tab_bar.dart';

////////////////////////////////////////////////////////////////////////

class CustomTabPage extends StatefulWidget {
  const CustomTabPage({
    Key? key,
    this.smallTabBar,
    this.extendedTabBar,
    this.children = const [],
  }) : super(key: key);
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final List<Widget> children;

  @override
  State<CustomTabPage> createState() => _CustomTabPageState();
}

class _CustomTabPageState extends State<CustomTabPage> {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CustomListView(
          smallTabBar: widget.smallTabBar,
          extendedTabBar: widget.extendedTabBar,
          onOffsetChange: (value) {
            scrollOffset = value;
            appBarHeight = _getAppBarHeight(pixelsOffset: scrollOffset);
            setState(() {});
          },
          children: widget.children,
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

////////////////////////////////////////////////////////////////////////

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
    this.onDragLeft,
    this.onDragRight,
  }) : super(key: key);
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final PageController? controller;
  final int? pageItemCount;
  final List<Widget> Function(BuildContext, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;

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

  // Get initial scroll view offset of new page
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
              scrollOffset = _getInitialOffset(appBarHeight: appBarHeight);
              setState(() {});
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.pageItemCount,
            itemBuilder: (context, pageIndex) => _CustomListView(
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
              children: widget.itemBuilder(context, pageIndex),
            ),
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

////////////////////////////////////////////////////////////////////////

class _CustomListView extends ConsumerStatefulWidget {
  const _CustomListView({
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
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _scrollController.position.isScrollingNotifier.addListener(_scrollControllerListener);
    // });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollControllerListener() {
    ScrollPosition position = _scrollController.position;
    //ScrollDirection direction = position.userScrollDirection;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      // if (position.pixels == position.maxScrollExtent) {
      //   position.jumpTo(position.maxScrollExtent - 0.3);
      // }
      scrollPixelsOffset = position.pixels;
      widget.onOffsetChange(scrollPixelsOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.smallTabBar != null && widget.extendedTabBar != null
          ? SnapScrollPhysics(
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
                        : widget.extendedTabBar!.height + 12,
              )
            : index == widget.children.length + 1
                ? const SizedBox(height: 30)
                : widget.children[index - 1];
      },
    );
  }
}
