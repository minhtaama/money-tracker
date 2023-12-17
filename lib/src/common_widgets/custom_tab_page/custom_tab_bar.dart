import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';
import '../card_item.dart';

class SmallTabBar extends StatelessWidget {
  const SmallTabBar({
    Key? key,
    required this.child,
    this.height = kCustomTabBarHeight,
    this.systemIconBrightness,
  }) : super(key: key);
  final Widget child;
  final double height;
  final Brightness? systemIconBrightness;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: Gap.statusBarHeight(context)),
          margin: EdgeInsets.zero,
          height: height + Gap.statusBarHeight(context),
          color: context.appTheme.background.withOpacity(context.appTheme.isDarkTheme ? 0.7 : 0.5),
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
    required this.child,
    this.height = kExtendedCustomTabBarHeight,
    this.outerChildHeight = kExtendedTabBarOuterChildHeight,
    this.systemIconBrightness,
  });
  final Color? backgroundColor;
  final Widget child;
  final double height;
  final double outerChildHeight;
  final Brightness? systemIconBrightness;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
