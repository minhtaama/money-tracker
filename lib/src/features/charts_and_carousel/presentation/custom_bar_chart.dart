import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../theme_and_ui/colors.dart';

class CustomBarChart extends StatefulWidget {
  const CustomBarChart({
    super.key,
    required this.values,
    required this.titleDateTimes,
    required this.titleBuilder,
    this.horizontalChart = false,
    this.titleAngle = 0,
    this.titleReservedSize = 30,
    this.titleSize = 12,
    this.titleOffset = Offset.zero,
    this.barRodWidth = 14,
    this.tooltipBuilder,
    this.onChartTap,
  });

  /// Must have same entry length with [titleDateTimes] length
  final Map<int, ({double spending, double income, double ySpending, double yIncome})> values;

  /// Must have same length with [values.entries]
  final List<DateTime> titleDateTimes;

  final String Function(DateTime) titleBuilder;

  final bool horizontalChart;

  final double titleAngle;

  final double titleReservedSize;

  final double titleSize;

  final Offset titleOffset;

  final double barRodWidth;

  final Widget Function(int index)? tooltipBuilder;

  final void Function(int index)? onChartTap;

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  final _touchThreshold = 20.0;

  late Map<int, ({double spending, double income, double ySpending, double yIncome})> _values = {
    for (var item in widget.values.entries) item.key: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01)
  };

  final _chartKey = GlobalKey();
  final _toolTipKey = GlobalKey();
  double _chartWidth = 1;
  double _chartHeight = 1;
  double _toolTipWidth = 1;

  int _touchedGroupIndex = -1;
  Offset _tooltipLocalPosition = const Offset(0, 0);

  Duration _duration = k1msDuration;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _chartWidth = _chartKey.currentContext!.size!.width;
        _chartHeight = _chartKey.currentContext!.size!.height;
        _toolTipWidth = _toolTipKey.currentContext!.size!.width;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomBarChart oldWidget) {
    if (widget.values != oldWidget.values) {
      setState(() {
        _values = widget.values;
        _touchedGroupIndex = -1;
      });
    }

    if (widget.tooltipBuilder != oldWidget.tooltipBuilder) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _toolTipWidth = _toolTipKey.currentContext!.size!.width;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    Future.delayed(
        k1msDuration,
        () => setState(() {
              _values = widget.values;
            }));
    super.didChangeDependencies();
  }

  List<BarChartGroupData> _buildBarGroups() {
    final list = _values.entries;
    return list
        .map((e) => BarChartGroupData(
              barsSpace: 2,
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.ySpending,
                  color: context.appTheme.negative,
                  width: widget.barRodWidth,
                  borderRadius: BorderRadius.circular(0),
                  backDrawRodData: BackgroundBarChartRodData(fromY: 0, toY: 1, color: Colors.transparent),
                ),
                BarChartRodData(
                  toY: e.value.yIncome,
                  color: context.appTheme.positive,
                  width: widget.barRodWidth,
                  borderRadius: BorderRadius.circular(0),
                  backDrawRodData: BackgroundBarChartRodData(fromY: 0, toY: 1, color: Colors.transparent),
                ),
              ],
            ))
        .toList();
  }

  void _touchCallback(FlTouchEvent event, BarTouchResponse? response) {
    if (response != null && response.spot != null) {
      if (event is FlTapDownEvent) {
        bool isTouchInThreshold = (_tooltipLocalPosition.dx - event.localPosition.dx).abs() < _touchThreshold &&
            (_tooltipLocalPosition.dy - event.localPosition.dy).abs() < _touchThreshold;

        if (isTouchInThreshold) {
          setState(() {
            _touchedGroupIndex = -1;
            _tooltipLocalPosition = const Offset(0, 0);
          });
          return;
        }
      }

      if (response.spot!.touchedBarGroupIndex != -1 &&
          (event is FlTapDownEvent || event is FlLongPressMoveUpdate || event is FlPanUpdateEvent)) {
        setState(() {
          if (event is FlTapDownEvent && _touchedGroupIndex != -1) {
            _duration = k250msDuration;
          } else {
            _duration = Duration.zero;
          }
          _touchedGroupIndex = response.spot!.touchedBarGroupIndex;
          _tooltipLocalPosition = event.localPosition!;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              _toolTipWidth = _toolTipKey.currentContext!.size!.width;
            });
          });
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.values.entries.length == widget.titleDateTimes.length);

    final double topTooltipPos = widget.horizontalChart ? _tooltipLocalPosition.dx : _tooltipLocalPosition.dy;
    final double leftTooltipPos =
        widget.horizontalChart ? _chartHeight - _tooltipLocalPosition.dy : _tooltipLocalPosition.dx;

    final double horizontalTooltipOverflow = widget.horizontalChart
        ? (leftTooltipPos + _toolTipWidth - _chartHeight).clamp(0, double.infinity)
        : (leftTooltipPos + _toolTipWidth - _chartWidth).clamp(0, double.infinity);

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        RotatedBox(
          quarterTurns: widget.horizontalChart ? 1 : 0,
          child: BarChart(
            key: _chartKey,
            BarChartData(
              maxY: 1.02,
              alignment: BarChartAlignment.spaceAround,
              barGroups: _buildBarGroups(),
              barTouchData: BarTouchData(
                allowTouchBarBackDraw: true,
                handleBuiltInTouches: false,
                touchCallback: _touchCallback,
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => bottomTitles(context, value, meta),
                    reservedSize: widget.titleReservedSize,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1 / 3,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (double value) {
                  final color = context.appTheme.onBackground.withOpacity(0.2);
                  return FlLine(
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [color.withOpacity(0), color, color, color.withOpacity(0)],
                      stops: const [0.03, 0.07, 0.93, 0.97],
                    ),
                  );
                },
              ),
            ),
            swapAnimationDuration: k550msDuration,
            swapAnimationCurve: Curves.fastOutSlowIn,
          ),
        ),
        AnimatedPositioned(
          duration: _duration,
          curve: Curves.fastOutSlowIn,
          top: topTooltipPos,
          left: leftTooltipPos - horizontalTooltipOverflow,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Gap.screenWidth(context) - 150, maxHeight: 300),
            child: SizedBox(
              key: _toolTipKey,
              child: _touchedGroupIndex != -1 ? widget.tooltipBuilder?.call(_touchedGroupIndex) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitles(BuildContext context, double value, TitleMeta meta) {
    final dateTime = widget.titleDateTimes[value.toInt()];

    final Widget text = Container(
      padding: const EdgeInsets.only(bottom: 2),
      decoration: dateTime.isSameDayAs(DateTime.now())
          ? BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: dateTime.weekday == 7 ? context.appTheme.negative : AppColors.grey(context))),
            )
          : null,
      child: Text(
        widget.titleBuilder(dateTime),
        style: kHeader4TextStyle.copyWith(
          color: dateTime.weekday == 7 ? context.appTheme.negative : AppColors.grey(context),
          fontSize: widget.titleSize,
          height: 1,
        ),
      ),
    );

    return Transform.translate(
      offset: widget.titleOffset,
      child: SideTitleWidget(
        axisSide: meta.axisSide,
        angle: (widget.horizontalChart ? (3 * math.pi / 2) : 0) + widget.titleAngle,
        space: 8,
        child: text,
      ),
    );
  }
}
