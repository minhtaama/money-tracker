import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/provider.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';
import 'custom_tab_bar.dart';

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
        CustomListView(
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
