import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  });

  /// Must have same entry length with [titleDateTimes] length
  final Map<int, ({double spending, double income, double ySpending, double yIncome})> values;

  /// Must have same length with [values.entries]
  final List<DateTime> titleDateTimes;

  final String Function(DateTime) titleBuilder;

  final bool horizontalChart;

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  Map<int, ({double spending, double income, double ySpending, double yIncome})> _values = {
    0: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
    1: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
    2: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
    3: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
    4: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
    5: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
    6: (spending: 0, income: 0, ySpending: 0.01, yIncome: 0.01),
  };

  final double _barRodWidth = 14;

  int _touchedGroupIndex = -1;

  @override
  void didChangeDependencies() {
    Future.delayed(
        k1msDuration,
        () => setState(() {
              _values = widget.values;
            }));
    super.didChangeDependencies();
  }

  List<BarChartGroupData> buildBarGroups() {
    final list = _values.entries;
    return list
        .map((e) => BarChartGroupData(
              barsSpace: 2,
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.ySpending,
                  color: context.appTheme.negative,
                  width: _barRodWidth,
                  borderRadius: BorderRadius.circular(0),
                ),
                BarChartRodData(
                  toY: e.value.yIncome,
                  color: context.appTheme.positive,
                  width: _barRodWidth,
                  borderRadius: BorderRadius.circular(0),
                ),
              ],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.values.entries.length == widget.titleDateTimes.length);

    return RotatedBox(
      quarterTurns: widget.horizontalChart ? 1 : 0,
      child: BarChart(
        BarChartData(
          maxY: 1.02,
          barGroups: buildBarGroups(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.grey,
              getTooltipItem: (a, b, c, d) => null,
            ),
            touchCallback: (FlTouchEvent event, response) {
              // if (response == null || response.spot == null) {
              //   setState(() {
              //     _touchedGroupIndex = -1;
              //     showingBarGroups = List.of(rawBarGroups);
              //   });
              //   return;
              // }
              //
              // _touchedGroupIndex = response.spot!.touchedBarGroupIndex;
              //
              // setState(() {
              //   if (!event.isInterestedForInteractions) {
              //     _touchedGroupIndex = -1;
              //     showingBarGroups = List.of(rawBarGroups);
              //     return;
              //   }
              //   showingBarGroups = List.of(rawBarGroups);
              //   if (_touchedGroupIndex != -1) {
              //     var sum = 0.0;
              //     for (final rod in showingBarGroups[_touchedGroupIndex].barRods) {
              //       sum += rod.toY;
              //     }
              //     final avg = sum / showingBarGroups[_touchedGroupIndex].barRods.length;
              //
              //     showingBarGroups[_touchedGroupIndex] = showingBarGroups[_touchedGroupIndex].copyWith(
              //       barRods: showingBarGroups[_touchedGroupIndex].barRods.map((rod) {
              //         return rod.copyWith(toY: avg, color: AppColors.white);
              //       }).toList(),
              //     );
              //   }
              // });
            },
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
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
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
    );
  }

  Widget bottomTitles(BuildContext context, double value, TitleMeta meta) {
    final dateTime = widget.titleDateTimes[value.toInt()];

    final Widget text = Container(
      padding: const EdgeInsets.all(3),
      decoration: dateTime.isSameDayAs(DateTime.now())
          ? BoxDecoration(
              border: Border.all(color: dateTime.weekday == 7 ? context.appTheme.negative : AppColors.grey(context)),
              borderRadius: BorderRadius.circular(5),
            )
          : null,
      child: Text(
        widget.titleBuilder(dateTime),
        style: kHeader4TextStyle.copyWith(
          color: dateTime.weekday == 7 ? context.appTheme.negative : AppColors.grey(context),
          fontSize: 12,
          height: 1,
        ),
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: widget.horizontalChart ? (3 * math.pi / 2) : 0,
      space: 8, //margin top
      child: text,
    );
  }
}
