import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';

class SmallTabBar extends StatelessWidget {
  const SmallTabBar({
    super.key,
    required this.child,
    this.height = kCustomTabBarHeight,
    this.systemIconBrightness,
  });
  final Widget child;
  final double height;
  final Brightness? systemIconBrightness;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: Gap.statusBarHeight(context)),
        margin: EdgeInsets.zero,
        height: height + Gap.statusBarHeight(context),
        color: context.appTheme.background500,
        child: child,
      ),
    );
  }
}

class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar({
    super.key,
    this.backgroundColor,
    required this.child,
    this.height = kExtendedCustomTabBarHeight + 20,
    this.systemIconBrightness,
  });
  final Color? backgroundColor;
  final Widget child;
  final double height;
  final Brightness? systemIconBrightness;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
