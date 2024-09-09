import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
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
    for (var item in widget.values.entries)
      item.key: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01)
  };

  final _chartKey = GlobalKey();
  final _toolTipKey = GlobalKey();
  double _chartWidth = 1;

  Size _toolTipSize = Size.zero;
  Offset _tooltipLocalPosition = const Offset(-1000, -1000);

  Duration _duration = k1msDuration;

  int _touchedGroupIndex = -1;

  @override
  void initState() {
    _updateAllSize();
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
      _updateTooltipSize();
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

  void _updateTooltipSize() => WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _toolTipSize = _toolTipKey.currentContext!.size!;
        });
      });

  void _updateAllSize() => WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _chartWidth = widget.horizontalChart
              ? _chartKey.currentContext!.size!.height
              : _chartKey.currentContext!.size!.width;

          _toolTipSize = _toolTipKey.currentContext!.size!;
        });
      });

  List<BarChartGroupData> _buildBarGroups() {
    final list = _values.entries.toList();
    return list
        .map((e) => BarChartGroupData(
              barsSpace: 2,
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.ySpending,
                  color: context.appTheme.negative,
                  width: list.indexOf(e) == _touchedGroupIndex
                      ? widget.barRodWidth * 1.65
                      : widget.barRodWidth,
                  borderRadius: BorderRadius.circular(widget.barRodWidth / 5),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    fromY: 0,
                    toY: 1,
                    color: context.appTheme.primary
                        .withOpacity(list.indexOf(e) == _touchedGroupIndex ? 0.1 : 0.0),
                  ),
                ),
                BarChartRodData(
                  toY: e.value.yIncome,
                  color: context.appTheme.positive,
                  width: list.indexOf(e) == _touchedGroupIndex
                      ? widget.barRodWidth * 1.65
                      : widget.barRodWidth,
                  borderRadius: BorderRadius.circular(widget.barRodWidth / 5),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    fromY: 0,
                    toY: 1,
                    color: context.appTheme.primary
                        .withOpacity(list.indexOf(e) == _touchedGroupIndex ? 0.1 : 0.0),
                  ),
                ),
              ],
            ))
        .toList();
  }

  void _touchCallback(FlTouchEvent event, BarTouchResponse? response) {
    if (response != null && response.spot != null) {
      if (event is FlTapDownEvent) {
        bool isTouchInThreshold =
            (_tooltipLocalPosition.dx - event.localPosition.dx).abs() < _touchThreshold &&
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

          if (_touchedGroupIndex != response.spot!.touchedBarGroupIndex) {
            _touchedGroupIndex = response.spot!.touchedBarGroupIndex;
            _updateTooltipSize();
          }

          _tooltipLocalPosition = event.localPosition!;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.values.entries.length == widget.titleDateTimes.length);

    final touchOffsetY = widget.horizontalChart ? _tooltipLocalPosition.dx : _tooltipLocalPosition.dy;
    final touchOffsetX =
        widget.horizontalChart ? _chartWidth - _tooltipLocalPosition.dy : _tooltipLocalPosition.dx;

    final double topTooltipPos = touchOffsetY - _toolTipSize.height;

    final double leftTooltipPos = touchOffsetX - _toolTipSize.width / 2;

    final double horizontalTooltipOverflow =
        math.max(0, leftTooltipPos + _toolTipSize.width - _chartWidth);

    // print('==============================');
    // print('touchOffsetY: $touchOffsetY');
    // print('touchOffsetX: $touchOffsetX');
    // print('_toolTipSize: $_toolTipSize');
    // print('topTooltipPos: $topTooltipPos');
    // print('leftTooltipPos: $leftTooltipPos');

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _updateAllSize();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            RotatedBox(
              quarterTurns: widget.horizontalChart ? 1 : 0,
              child: BarChart(
                key: _chartKey,
                swapAnimationDuration: k150msDuration,
                swapAnimationCurve: Curves.fastOutSlowIn,
                BarChartData(
                  maxY: 1.02,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _buildBarGroups(),
                  barTouchData: BarTouchData(
                    allowTouchBarBackDraw: true,
                    handleBuiltInTouches: false,
                    touchCallback: _touchCallback,
                    touchExtraThreshold: const EdgeInsets.only(left: 14, right: 10),
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
              ),
            ),
            AnimatedPositioned(
              duration: _duration,
              curve: Curves.fastOutSlowIn,
              top: topTooltipPos - 20,
              left: math.max(0, leftTooltipPos - horizontalTooltipOverflow),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: (_chartWidth - 100).clamp(0, double.infinity), maxHeight: 300),
                child: SizedBox(
                  key: _toolTipKey,
                  child: _touchedGroupIndex != -1
                      ? widget.tooltipBuilder?.call(_touchedGroupIndex)
                      : SizedBox(
                          width: (_chartWidth - 100).clamp(0, double.infinity),
                          height: 300,
                        ),
                ),
              ),
            ),
            _touchedGroupIndex != -1
                ? AnimatedPositioned(
                    duration: _duration,
                    curve: Curves.fastOutSlowIn,
                    top: touchOffsetY - 5,
                    left: touchOffsetX - 5,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: context.appTheme.background0,
                              blurRadius: 5,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: SvgIcon(
                          AppIcons.addLight,
                          size: 20,
                          color: context.appTheme.accent2.lerpWithOnBg(context, 0.5),
                        ),
                      ),
                    ),
                  )
                : Gap.noGap,
          ],
        ),
      ),
    );
  }

  Widget bottomTitles(BuildContext context, double value, TitleMeta meta) {
    final dateTime = widget.titleDateTimes[value.toInt()];

    final Widget text = Container(
      padding: const EdgeInsets.only(bottom: 2),
      decoration: dateTime.isSameDayAs(DateTime.now())
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color:
                          dateTime.weekday == 7 ? context.appTheme.negative : AppColors.grey(context))),
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
