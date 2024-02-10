import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';

class SmallTabBar extends StatelessWidget {
  const SmallTabBar({
    super.key,
    required this.child,
    this.height = kCustomTabBarHeight,
  });
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: Gap.statusBarHeight(context)),
        margin: EdgeInsets.zero,
        height: height + Gap.statusBarHeight(context),
        color: context.appTheme.background1,
        child: child,
      ),
    );
  }
}

class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar({
    super.key,
    this.backgroundColor,
    this.height = kExtendedCustomTabBarHeight + 30,
    required this.child,
  });
  final Color? backgroundColor;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _ExtendedToolBar extends StatelessWidget {
  const _ExtendedToolBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Container(
        width: Gap.screenWidth(context),
        padding: const EdgeInsets.only(top: 10, bottom: 30),
        decoration: BoxDecoration(
          color: context.appTheme.background1.addDark(0.04),
          boxShadow: context.appTheme.isDarkTheme
              ? []
              : [
                  BoxShadow(
                    color: context.appTheme.onBackground.withOpacity(0.3),
                    blurRadius: 12,
                  )
                ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: child,
      ),
    );
  }
}
