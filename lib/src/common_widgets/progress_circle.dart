import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';
import 'card_item.dart';
import 'custom_inkwell.dart';

class ProgressCircle extends ImplicitlyAnimatedWidget {
  const ProgressCircle({
    super.key,
    super.curve,
    required super.duration,
    super.onEnd,
    required this.completeColor,
    required this.currentProgress,
    this.strokeWidth = 5,
    required this.completeColors,
    this.onTap,
    this.child,
  });

  final Color completeColor;
  final double currentProgress;
  final double strokeWidth;
  final List<Color>? completeColors;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  ProgressCircleState createState() => ProgressCircleState();
}

class ProgressCircleState extends AnimatedWidgetBaseState<ProgressCircle> {
  Tween<double>? _tween;

  @override
  void forEachTween(visitor) {
    _tween = visitor(
      // The latest tween value. Can be `null`.
      _tween,
      // The value toward which we are animating.
      widget.currentProgress,
      // A function that takes a value and returns a tween beginning at that value.
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ProgressCirclePainter(
        context,
        currentProgress: _tween?.evaluate(animation) as double,
        completeColor: context.appTheme.negative,
        completeColors: widget.completeColors,
      ),
      child: CardItem(
        color: Colors.transparent,
        height: 55,
        width: 60,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: CustomInkWell(
          inkColor: context.appTheme.primary,
          onTap: () {
            HapticFeedback.vibrate();
            widget.onTap;
          },
          child: widget.child ?? Gap.noGap,
        ),
      ),
    );
  }
}

class ProgressCirclePainter extends CustomPainter {
  final BuildContext context;
  final Color completeColor;
  final double currentProgress;
  final double strokeWidth;
  final List<Color>? completeColors;

  ProgressCirclePainter(
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
      ..color = context.appTheme.onBackground.withOpacity(context.appTheme.isDarkTheme ? 0.15 : 0.1)
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
