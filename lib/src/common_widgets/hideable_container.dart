import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HideableContainer extends StatelessWidget {
  const HideableContainer({super.key, required this.hidden, required this.child});
  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: k350msDuration,
      reverseDuration: k350msDuration,
      firstChild: Gap.noGap,
      secondChild: child,
      crossFadeState: hidden ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              key: bottomChildKey,
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomChild,
            ),
            Positioned(
              key: topChildKey,
              child: topChild,
            ),
          ],
        );
      },
    );
  }
}
