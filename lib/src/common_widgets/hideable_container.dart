import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../utils/constants.dart';

class HideableContainer extends StatefulWidget {
  const HideableContainer(
      {super.key, required this.hide, this.axis = Axis.vertical, this.initialAnimation = true, required this.child});
  final bool hide;
  final Axis axis;
  final bool initialAnimation;
  final Widget child;

  @override
  State<HideableContainer> createState() => _HideableContainerState();
}

class _HideableContainerState extends State<HideableContainer> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runHideCheckInitial();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(vsync: this, duration: k350msDuration);
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runHideCheckInitial() {
    if (!widget.hide) {
      if (widget.initialAnimation) {
        expandController.forward();
      } else {
        expandController.value = 1;
      }
    } else {
      if (widget.initialAnimation) {
        expandController.reverse();
      } else {
        expandController.value = 0;
      }
    }
  }

  void _runHideCheck() {
    if (!widget.hide) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(HideableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runHideCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(axisAlignment: 1.0, sizeFactor: animation, axis: widget.axis, child: widget.child);
  }
}
