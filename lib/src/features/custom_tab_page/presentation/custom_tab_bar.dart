import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class CustomTabBar extends ConsumerWidget {
  const CustomTabBar({Key? key, this.extendedChild, required this.child}) : super(key: key);
  final Widget child;
  final Widget? extendedChild;

  final _triggerHeight = kCustomAppBarHeight + (kExtendedCustomAppBarHeight - kCustomAppBarHeight) / 2;

  double _getAppBarHeight({required bool isScrollIdle, required double pixelsOffset}) {
    double height;
    height = (kExtendedCustomAppBarHeight - 2 * pixelsOffset)
        .clamp(kCustomAppBarHeight, kExtendedCustomAppBarHeight);
    if (isScrollIdle) {
      return height > _triggerHeight ? kExtendedCustomAppBarHeight : kCustomAppBarHeight;
    }
    return height;
  }

  double _getAppBarChildOpacity({required bool isExtendedChild, required double appBarHeight}) {
    final height = appBarHeight;

    if (isExtendedChild) {
      return height <= _triggerHeight
          ? 1 - kCustomAppBarHeight / height
          : height >= kCustomAppBarHeight
              ? 1
              : 0;
    } else {
      return height >= _triggerHeight
          ? 1 - height / kExtendedCustomAppBarHeight
          : height <= _triggerHeight
              ? 1
              : 0;
    }
  }

  Widget _animateChangingChild(double appBarHeight) {
    double childOpacity = _getAppBarChildOpacity(isExtendedChild: false, appBarHeight: appBarHeight);
    double extendedChildOpacity =
        _getAppBarChildOpacity(isExtendedChild: true, appBarHeight: appBarHeight);

    if (extendedChild != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: extendedChildOpacity,
            duration: kAppBarExtendDuration,
            child: IgnorePointer(
              ignoring: extendedChildOpacity == 1 ? false : true,
              child: extendedChild!,
            ),
          ),
          AnimatedOpacity(
            opacity: childOpacity,
            duration: kAppBarExtendDuration,
            child: IgnorePointer(
              ignoring: childOpacity == 1 ? false : true,
              child: child,
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixelsOffset =
        ref.watch(customListViewStateControllerProvider.select((value) => value.pixelsOffset));
    final isScrollIdle =
        ref.watch(customListViewStateControllerProvider.select((value) => value.isIdling));

    double appBarHeight = _getAppBarHeight(pixelsOffset: pixelsOffset, isScrollIdle: isScrollIdle);

    return AnimatedContainer(
      duration: kAppBarExtendDuration,
      height: appBarHeight,
      child: _animateChangingChild(appBarHeight),
    );
  }
}
