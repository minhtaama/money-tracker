import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class ProgressCircle extends CustomPainter {
  final BuildContext context;
  final Color completeColor;
  final double currentProgress;
  final double strokeWidth;
  final List<Color>? completeColors;

  ProgressCircle(
    this.context, {
    required this.currentProgress,
    required this.completeColor,
    this.completeColors,
    this.strokeWidth = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double progress = currentProgress.clamp(0, 1);
    //final double progress = 0.85;

    //this is base circle
    Paint outerCircle = Paint()
      ..strokeWidth = strokeWidth
      ..color = context.appTheme.onBackground.withOpacity(0.15)
      ..style = PaintingStyle.stroke;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - strokeWidth - 2;

    Paint completeArc = Paint()
      ..strokeWidth = strokeWidth
      ..color = completeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius);

    if (completeColors != null && progress > 0.0) {
      final colorStops = [
        for (int i = 0; i < completeColors!.length; i++) 0 + (1 / (completeColors!.length - 1)) * i,
      ];

      final gradient = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        tileMode: TileMode.mirror,
        colors: completeColors!,
        stops: colorStops,
        transform: const GradientRotation(-pi / 2),
      );

      completeArc.shader = gradient.createShader(rect);
    }

    canvas.drawCircle(center, radius, outerCircle); // this draws main outer circle

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
