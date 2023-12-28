import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class CustomBox extends StatelessWidget {
  const CustomBox({super.key, required this.child, this.constraints, this.padding});

  final Widget child;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: k150msDuration,
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.appTheme.isDarkTheme ? context.appTheme.background400 : context.appTheme.background500,
        border: Border.all(
          color: context.appTheme.onBackground.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSize(
        duration: k150msDuration,
        child: ConstrainedBox(
          constraints: constraints ?? const BoxConstraints.tightForFinite(),
          child: child,
        ),
      ),
    );
  }
}
