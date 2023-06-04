import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import '../../../theming/app_theme.dart';

class CustomTabBar extends ConsumerWidget {
  const CustomTabBar({Key? key, this.extendedTabBar, required this.childTabBar}) : super(key: key);
  final ChildTabBar childTabBar;
  final ExtendedTabBar? extendedTabBar;

  final _triggerHeight = kCustomTabBarHeight + (kExtendedCustomTabBarHeight - kCustomTabBarHeight) / 2;

  double _getAppBarHeight({required bool isScrollIdle, required double pixelsOffset}) {
    double height;
    height = (kExtendedCustomTabBarHeight - pixelsOffset - 2) // 2px is added for clamping
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
              child: childTabBar,
            ),
          ),
        ],
      );
    } else {
      return childTabBar;
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

class ChildTabBar extends StatelessWidget {
  const ChildTabBar({Key? key, required this.backgroundColor, required this.child}) : super(key: key);
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

class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar({Key? key, required this.backgroundColor, required this.child}) : super(key: key);
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backgroundColor, AppTheme.of(context).background],
          stops: [0, 1],
        )),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: Gap.statusBarHeight(context)),
          child: child,
        ));
  }
}
