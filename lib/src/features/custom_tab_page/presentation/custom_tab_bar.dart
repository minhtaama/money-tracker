import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

final _extendedTabBarKey = GlobalKey();

/// Use this class as the value for [CustomTabPage]'s argument
class CustomTabBar extends ConsumerWidget {
  const CustomTabBar({
    Key? key,
    this.extendedTabBar,
    required this.smallTabBar,
  }) : super(key: key);
  final SmallTabBar smallTabBar;
  final ExtendedTabBar? extendedTabBar;

  double _getAppBarHeight({required bool isScrollIdle, required double pixelsOffset}) {
    if (extendedTabBar != null) {
      final triggerHeight = smallTabBar.height + (extendedTabBar!.height - smallTabBar.height) / 2;
      double height =
          (extendedTabBar!.height - pixelsOffset).clamp(smallTabBar.height, extendedTabBar!.height);
      if (isScrollIdle) {
        return height > triggerHeight ? extendedTabBar!.height : smallTabBar.height;
      }
      return height;
    } else {
      return smallTabBar.height;
    }
  }

  double _getAppBarChildOpacity({required bool isExtendedChild, required double appBarHeight}) {
    final height = appBarHeight;

    if (extendedTabBar != null) {
      if (isExtendedChild) {
        return (height - smallTabBar.height) / (extendedTabBar!.height - smallTabBar.height);
      } else {
        return 1 - (height - smallTabBar.height) / (extendedTabBar!.height - smallTabBar.height);
      }
    } else {
      return 1;
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
class SmallTabBar extends ConsumerWidget {
  /// By default, no need to change `extendedTabBarHeight` argument.
  /// If there is an extendedTabBar, change `isHasExtendedTabBar` to `true`
  /// and config `extendedTabBarHeight` if the extended tab bar has custom height.
  const SmallTabBar({
    Key? key,
    this.backgroundColor,
    required this.child,
    this.height = kCustomTabBarHeight,
    this.extendedTabBarHeight = kExtendedCustomTabBarHeight,
    this.isHasExtendedTabBar = false,
  }) : super(key: key);
  final Color? backgroundColor;
  final Widget child;
  final double height;
  final double extendedTabBarHeight;
  final bool isHasExtendedTabBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixelsOffset =
        ref.watch(customListViewStateControllerProvider.select((value) => value.pixelsOffset));

    double offsetTriggerShowBottomDivider = isHasExtendedTabBar ? extendedTabBarHeight - height + 3 : 10;

    return AnimatedContainer(
      duration: kBottomAppBarDuration,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16, top: Gap.statusBarHeight(context)),
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.appTheme.background,
        border: Border(
          bottom: BorderSide(
              color: Colors.black.withOpacity(pixelsOffset > offsetTriggerShowBottomDivider ? 0.1 : 0.0),
              width: 2),
        ),
      ),
      child: child,
    );
  }
}

/// Use this class as the value for [CustomTabBar]'s argument
class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar({
    super.key,
    required this.backgroundColor,
    required this.innerChild,
    this.outerChild,
    this.height = kExtendedCustomTabBarHeight,
    this.outerChildHeight = kOuterChildHeight,
  });
  final Color backgroundColor;
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
            isGradient: true,
            color: backgroundColor,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.zero,
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: outerChild != null ? 12.0 : 0,
                top: Gap.statusBarHeight(context) + outerChildHeight / 2),
            elevation: 2,
            child: innerChild,
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: outerChild),
      ],
    );
  }
}
