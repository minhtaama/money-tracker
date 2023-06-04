import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';

// This class used to wrap the contents of each tab to expose user
// scroll direction to the ScaffoldWithBottomNavBar. This class returns
// a `ListView` which has a `ScrollController` and is
// linked with ScaffoldWithBottomNavBar through a state class CustomListViewState,
// which is exposed by customListViewStateControllerProvider.
class CustomTabPage extends ConsumerStatefulWidget {
  const CustomTabPage({Key? key, this.customTabBar, required this.children}) : super(key: key);
  final CustomTabBar? customTabBar;
  final List<Widget> children;

  @override
  ConsumerState<CustomTabPage> createState() => _TabPageState();
}

class _TabPageState extends ConsumerState<CustomTabPage> {
  final ScrollController _controller = ScrollController(); // ScrollController used for ListView

  double previousPositionPixels = 0;

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
    double deltaPosition = (position.pixels - previousPositionPixels).abs();
    bool isIdle = !_controller.position.isScrollingNotifier.value;

    // Read the Provider to change its state
    final state = ref.read(customListViewStateControllerProvider.notifier);

    // Check user scroll direction
    if (direction == ScrollDirection.forward &&
            state.getScrollForwardState == false &&
            deltaPosition > 20 ||
        position.pixels == 0) {
      // User scroll down (ListView go up)
      state.setScrollForwardState(true);
    } else if (direction == ScrollDirection.reverse && state.getScrollForwardState == true) {
      // User scroll up (ListView go down)
      state.setScrollForwardState(false);
    }

    //Set idle state of ListView
    if (isIdle) {
      Future(() {
        state.setIsIdlingState(isIdle);
      });
    } else if (deltaPosition > 1) {
      // Prevent user tap can change idling state
      Future(() {
        state.setIsIdlingState(isIdle);
      });
    }

    //The number of pixels to offset the children in the opposite of the axis direction.
    if (widget.customTabBar != null) {
      Future(() {
        state.setPixelsOffset(position.pixels);
      });
    }

    previousPositionPixels = position.pixels;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          physics: widget.customTabBar != null
              ? SnapScrollPhysics(
                  snaps: [Snap.avoidZone(0, kExtendedCustomAppBarHeight - kCustomAppBarHeight)],
                )
              : const ClampingScrollPhysics(),
          controller: _controller,
          children: [
            SizedBox(height: widget.customTabBar != null ? kExtendedCustomAppBarHeight : 0),
            ...widget.children,
          ],
        ),
        widget.customTabBar ?? const SizedBox(),
      ],
    );
  }
}
