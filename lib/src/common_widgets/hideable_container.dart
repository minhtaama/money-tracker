import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HideableContainer extends StatelessWidget {
  const HideableContainer({super.key, required this.hidden, required this.child});
  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: k250msDuration,
        child: hidden ? Gap.noGap : child,
      ),
    );
  }
}
