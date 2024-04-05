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
    return Container(
      height: height + Gap.statusBarHeight(context),
      color: context.appTheme.background1,
      child: Material(
        color: context.appTheme.background1,
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: Gap.statusBarHeight(context)),
          child: child,
        ),
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
