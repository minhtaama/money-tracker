import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

/// Use this class as the value for [CustomTabPage]'s argument
class CustomTabBar extends ConsumerWidget {
  const CustomTabBar({Key? key, this.extendedTabBar, required this.smallTabBar}) : super(key: key);
  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;

  final _triggerHeight = kCustomTabBarHeight + (kExtendedCustomTabBarHeight - kCustomTabBarHeight) / 2;

  double _getAppBarHeight({required bool isScrollIdle, required double pixelsOffset}) {
    double height;
    height = (kExtendedCustomTabBarHeight - pixelsOffset)
        .clamp(kCustomTabBarHeight, kExtendedCustomTabBarHeight);
    if (isScrollIdle) {
      return height > _triggerHeight ? kExtendedCustomTabBarHeight : kCustomTabBarHeight;
    }
    return height;
  }

  double _getAppBarChildOpacity({required bool isExtendedChild, required double appBarHeight}) {
    final height = appBarHeight;

    if (isExtendedChild) {
      return (height - kCustomTabBarHeight) / (kExtendedCustomTabBarHeight - kCustomTabBarHeight);
    } else {
      return 1 - (height - kCustomTabBarHeight) / (kExtendedCustomTabBarHeight - kCustomTabBarHeight);
    }
  }

  Widget _animateChangingChild(double appBarHeight) {
    double childOpacity = _getAppBarChildOpacity(isExtendedChild: false, appBarHeight: appBarHeight);
    double extendedChildOpacity =
        _getAppBarChildOpacity(isExtendedChild: true, appBarHeight: appBarHeight);

    if (extendedTabBar != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: extendedChildOpacity,
            duration: kAppBarExtendDuration,
            child: IgnorePointer(
              ignoring: extendedChildOpacity == 1 ? false : true,
              child: extendedTabBar!,
            ),
          ),
          AnimatedOpacity(
            opacity: childOpacity,
            duration: kAppBarExtendDuration,
            child: IgnorePointer(
              ignoring: childOpacity == 1 ? false : true,
              child: smallTabBar,
            ),
          ),
        ],
      );
    } else {
      return smallTabBar;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixelsOffset =
        ref.watch(customListViewStateControllerProvider.select((value) => value.pixelsOffset));
    final isScrollIdle =
        ref.watch(customListViewStateControllerProvider.select((value) => value.isIdling));

    double appBarHeight = _getAppBarHeight(pixelsOffset: pixelsOffset, isScrollIdle: isScrollIdle);
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: kAppBarExtendDuration,
      height: appBarHeight + statusBarHeight,
      child: _animateChangingChild(appBarHeight),
    );
  }
}

/// Use this class as the value for [CustomTabBar]'s argument
class SmallTabBar extends StatelessWidget {
  const SmallTabBar({Key? key, required this.backgroundColor, required this.child}) : super(key: key);
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: Gap.statusBarHeight(context)),
          child: child,
        ));
  }
}

/// Use this class as the value for [CustomTabBar]'s argument
class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar(
      {Key? key, required this.backgroundColor, required this.innerChild, required this.outerChild})
      : super(key: key);
  final Color backgroundColor;
  final Widget innerChild;
  final Widget outerChild;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform(
          transform: Matrix4.identity()..translate(0.0, -kOuterChildHeight / 2, 0.0),
          child: CardItem(
            width: double.infinity,
            height: double.infinity,
            isGradient: true,
            color: backgroundColor,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.zero,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: innerChild,
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: outerChild),
      ],
    );
  }
}
