import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class CustomBox extends StatelessWidget {
  const CustomBox({
    super.key,
    required this.child,
    this.constraints,
    this.padding,
    this.margin,
    this.color,
    this.hide = false,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxConstraints? constraints;
  final Color? color;
  final bool hide;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: k150msDuration,
      margin: hide ? EdgeInsets.zero : margin ?? const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      padding:
          hide ? EdgeInsets.zero : padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        border: Border.all(
          color: context.appTheme.onBackground.withOpacity(hide ? 0.0 : 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ConstrainedBox(
          constraints: constraints ?? const BoxConstraints.tightForFinite(),
          child: child,
        ),
      ),
    );
  }
}
