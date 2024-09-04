import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';

class SmallTabBar extends StatelessWidget {
  const SmallTabBar({
    super.key,
    required this.child,
    this.height = kCustomTabBarHeight,
    this.optional,
  });
  final Widget child;
  final double height;

  final Widget? optional;

  factory SmallTabBar.empty() => SmallTabBar(
        child: Gap.noGap,
        height: 0,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height + Gap.statusBarHeight(context),
          color: context.appTheme.background1,
          child: Material(
            color: context.appTheme.background1,
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, top: Gap.statusBarHeight(context)),
              child: child,
            ),
          ),
        ),
        optional ?? Gap.noGap,
      ],
    );
  }
}

class ExtendedTabBar extends StatelessWidget {
  const ExtendedTabBar({
    super.key,
    this.backgroundColor,
    this.overlayColor,
    this.height = kExtendedCustomTabBarHeight + 30,
    required this.child,
  });
  final Color? backgroundColor;

  /// For the background color below extended tab bar of scrollable sheet
  final Color? overlayColor;

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
