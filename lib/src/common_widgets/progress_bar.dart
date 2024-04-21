import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../theme_and_ui/colors.dart';
import '../utils/constants.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({
    super.key,
    required this.color,
    required this.percentage,
    this.secondaryPercentage,
    this.secondaryColor,
  });

  final double percentage;
  final double? secondaryPercentage;
  final Color color;
  final Color? secondaryColor;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
  );

  late AnimationController? _secondaryController;

  @override
  void initState() {
    _secondaryController = widget.secondaryPercentage != null
        ? AnimationController(
            vsync: this,
          )
        : null;

    Future.delayed(k1msDuration, () {
      setState(() {
        _controller.animateTo(widget.percentage, duration: k350msDuration, curve: Curves.easeOut);
        _secondaryController?.animateTo(widget.secondaryPercentage!, duration: k350msDuration, curve: Curves.easeOut);
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProgressBar oldWidget) {
    if (oldWidget.secondaryPercentage != widget.secondaryPercentage) {
      _secondaryController = widget.secondaryPercentage != null
          ? AnimationController(
              vsync: this,
            )
          : null;
    }

    Future.delayed(k1msDuration, () {
      if (oldWidget.percentage != widget.percentage) {
        setState(() {
          _controller.animateTo(widget.percentage, duration: k350msDuration, curve: Curves.easeOut);
        });
      }

      if (oldWidget.secondaryPercentage != widget.secondaryPercentage) {
        setState(() {
          _secondaryController?.animateTo(widget.secondaryPercentage!, duration: k350msDuration, curve: Curves.easeOut);
        });
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondaryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 18,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: context.appTheme.onBackground.withOpacity(0.1),
          ),
        ),
        widget.secondaryPercentage != null
            ? SizeTransition(
                sizeFactor: _secondaryController!,
                axis: Axis.horizontal,
                axisAlignment: -1.0,
                child: Container(
                  width: double.infinity,
                  height: 18,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: widget.secondaryColor,
                  ),
                ),
              )
            : Gap.noGap,
        SizeTransition(
          sizeFactor: _controller,
          axis: Axis.horizontal,
          axisAlignment: -1.0,
          child: Container(
            width: double.infinity,
            height: 18,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: widget.color,
            ),
          ),
        ),
      ],
    );
  }
}
