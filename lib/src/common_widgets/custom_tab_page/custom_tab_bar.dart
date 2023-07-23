import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../utils/constants.dart';
import '../card_item.dart';

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
            ignoring: extendedChildOpacity > 0.9 ? false : true,
            child: extendedTabBar ?? const SizedBox(),
          ),
        ),
        AnimatedOpacity(
          opacity: childOpacity > 0.9 ? 1 : 0,
          duration: k150msDuration,
          child: IgnorePointer(
            ignoring: childOpacity > 0.9 ? false : true,
            child: smallTabBar ?? const SizedBox(),
          ),
        ),
      ],
    );
  }

  bool _isShowDivider(double pixelsOffset) {
    if (extendedTabBar != null && smallTabBar != null) {
      return pixelsOffset > extendedTabBar!.height - smallTabBar!.height + 15;
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
          duration: k150msDuration,
          decoration: BoxDecoration(
            border: Border(
              bottom: _isShowDivider(pixelOffset) && !context.appTheme.isDarkTheme
                  ? BorderSide(color: Colors.grey.shade400, width: 2)
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
    this.outerChildHeight = kExtendedTabBarOuterChildHeight,
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
