import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class AnimatedSwipeTile extends StatefulWidget {
  const AnimatedSwipeTile({super.key, required this.child, required this.buttons});

  final Widget child;
  final List<Widget> buttons;

  @override
  State<AnimatedSwipeTile> createState() => _AnimatedSwipeTileState();
}

class _AnimatedSwipeTileState extends State<AnimatedSwipeTile> with SingleTickerProviderStateMixin {
  final _buttonsKey = GlobalKey();
  double _buttonsGap = 0;

  double _childOffset = 0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    lowerBound: -1,
    upperBound: 0,
    value: 0,
    duration: k150msDuration,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _buttonsGap = _buttonsKey.currentContext!.size!.width + 30;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapOutSide(PointerDownEvent event) {
    _controller.animateTo(0, duration: k150msDuration, curve: Curves.easeOut);
    _childOffset = 0;
  }

  void _handlePanUpdate(DragUpdateDetails event) {
    _childOffset += event.delta.dx;
    _controller.value = _childOffset / _buttonsGap;
  }

  void _handlePanEnd(DragEndDetails event) {
    if (_controller.value <= -0.5) {
      _controller.animateTo(-1, duration: k150msDuration, curve: Curves.easeOut);
      _childOffset = -_buttonsGap;
    } else {
      _controller.animateTo(0, duration: k150msDuration, curve: Curves.easeOut);
      _childOffset = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return TapRegion(
            onTapOutside: _handleTapOutSide,
            child: GestureDetector(
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Stack(
                children: [
                  Positioned.fill(
                    right: 10,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Transform.scale(
                        scale: -_controller.value,
                        alignment: Alignment.centerRight,
                        child: Row(
                          key: _buttonsKey,
                          mainAxisSize: MainAxisSize.min,
                          children: widget.buttons,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(_buttonsGap * _controller.value, 0),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
