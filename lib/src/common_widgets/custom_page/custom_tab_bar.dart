import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';

class SmallTabBar extends StatelessWidget {
  const SmallTabBar({
    super.key,
    required this.firstChild,
    this.secondChild,
    this.showSecondChild = false,
    this.optional,
    this.height = kCustomTabBarHeight,
  });

  final Widget firstChild;
  final Widget? secondChild;
  final bool showSecondChild;

  final Widget? optional;

  final double height;

  factory SmallTabBar.empty() => SmallTabBar(
        firstChild: Gap.noGap,
        height: 0,
      );

  Widget _firstChild(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 12, right: 12, top: Gap.statusBarHeight(context)),
        child: firstChild,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height + Gap.statusBarHeight(context),
          child: Material(
            color: context.appTheme.background1,
            child: secondChild != null
                ? AnimatedCrossFade(
                    duration: k250msDuration,
                    sizeCurve: Curves.fastOutSlowIn,
                    firstCurve: Curves.easeOutExpo,
                    secondCurve: Curves.easeInExpo,
                    crossFadeState: showSecondChild ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: _firstChild(context),
                    secondChild: secondChild!,
                  )
                : _firstChild(context),
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
