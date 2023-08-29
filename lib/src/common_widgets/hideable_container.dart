import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HideableContainer extends StatelessWidget {
  const HideableContainer({super.key, required this.hidden, required this.child});
  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: k150msDuration,
      width: double.infinity,
      margin: EdgeInsets.zero,
      child: AnimatedSize(
        duration: k150msDuration,
        child: !hidden ? child : Gap.noGap,
      ),
    );
  }
}
