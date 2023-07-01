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

class CustomTabPage extends ConsumerStatefulWidget {
  const CustomTabPage({Key? key, this.smallTabBar, this.extendedTabBar, required this.children})
      : super(key: key);
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final List<Widget> children;

  @override
  ConsumerState<CustomTabPage> createState() => _TabPageState();
}

class _TabPageState extends ConsumerState<CustomTabPage> {
  final ScrollController _controller = ScrollController(); // ScrollController used for ListView

  double previousPositionPixels = 0;
  double deltaPosition = 0;

  double pixelsOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_listen);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.position.isScrollingNotifier.addListener(_listen);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_listen);
    _controller.dispose();
    super.dispose();
  }

  void _listen() {
    ScrollPosition position = _controller.position;
    ScrollDirection direction = position.userScrollDirection;

    deltaPosition = (position.pixels - previousPositionPixels).abs();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        pixelsOffset = position.pixels;
      });
    });

    // Read the Provider to change its state
    final provider = ref.read(scrollForwardStateProvider.notifier);

    // Check user scroll direction
    if (direction == ScrollDirection.forward && provider.state == false && deltaPosition > 20 ||
        position.pixels == 0) {
      // User scroll down (ListView go up)
      provider.state = true;
    } else if (direction == ScrollDirection.reverse && provider.state == true) {
      // User scroll up (ListView go down)
      provider.state = false;
    }
    previousPositionPixels = position.pixels;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
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
                    ? const SizedBox(height: kBottomAppBarHeight + 8)
                    : widget.children[index - 1];
          },
        ),
        CustomTabBar(
          smallTabBar: widget.smallTabBar,
          extendedTabBar: widget.extendedTabBar,
          pixelsOffset: pixelsOffset,
        ),
      ],
    );
  }
}

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    Key? key,
    required this.pixelsOffset,
    this.extendedTabBar,
    this.smallTabBar,
  }) : super(key: key);

  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final double pixelsOffset;

  double _getAppBarHeight({required double pixelsOffset}) {
    if (extendedTabBar != null) {
      double height = (extendedTabBar!.height - pixelsOffset)
          .clamp(smallTabBar?.height ?? 0, extendedTabBar!.height);
      return height;
    } else if (smallTabBar != null) {
      return smallTabBar!.height;
    } else if (extendedTabBar != null) {
      return extendedTabBar!.height;
    } else {
      return 0;
    }
  }

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

  bool _isShowShadow(double pixelsOffset) {
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
    double appBarHeight = _getAppBarHeight(pixelsOffset: pixelsOffset);
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: appBarHeight + statusBarHeight,
      child: AnimatedContainer(
          duration: kBottomAppBarDuration,
          decoration: BoxDecoration(
            border: Border(
              bottom: _isShowShadow(pixelsOffset)
                  ? BorderSide(color: Colors.black.withOpacity(0.2), width: 2)
                  : BorderSide.none,
            ),
          ),
          child: _animateChangingChild(appBarHeight)),
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
