import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class ProgressCircle extends CustomPainter {
  final BuildContext context;
  final Color completeColor;
  final double currentProgress;

  ProgressCircle(
    this.context, {
    required this.currentProgress,
    required this.completeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //this is base circle
    Paint outerCircle = Paint()
      ..strokeWidth = 5
      ..color = context.appTheme.onBackground.withOpacity(0.15)
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = 5
      ..color = completeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 7;

    canvas.drawCircle(center, radius, outerCircle); // this draws main outer circle

    double angle = 2 * pi * currentProgress;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
