import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

class CLCData {
  CLCData({required this.day, required this.amount});
  final int day;
  final double amount;
}

class CustomLineChart extends StatefulWidget {
  const CustomLineChart({
    super.key,
    required this.currentMonthView,
    this.beginValue,
    this.endValue,
    required this.valuesBetween,
  });
  final double? beginValue;
  final double? endValue;
  final List<CLCData> valuesBetween;
  final DateTime currentMonthView;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late double _endX = widget.currentMonthView.daysInMonth.toDouble() + 1;
  late double _lowestAmount;
  late double _highestAmount;

  void findLowestAndHighestAmount() {
    double lowTemp = double.infinity;
    double highTemp = double.negativeInfinity;
    for (CLCData data in widget.valuesBetween) {
      if (data.amount < lowTemp) {
        lowTemp = data.amount;
      }
      if (data.amount > highTemp) {
        highTemp = data.amount;
      }
    }
    _lowestAmount = lowTemp;
    _highestAmount = highTemp;
  }

  @override
  void initState() {
    findLowestAndHighestAmount();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomLineChart oldWidget) {
    if (widget.currentMonthView != oldWidget.currentMonthView) {
      setState(() {
        _endX = widget.currentMonthView.daysInMonth.toDouble() + 1;
      });
    }
    if (widget.valuesBetween != oldWidget.valuesBetween) {
      setState(() {
        findLowestAndHighestAmount();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    bool isShowTitle = widget.valuesBetween.map((e) => e.day).contains(value.toInt());

    return isShowTitle
        ? Transform.translate(
            offset: const Offset(0, -73),
            child: SideTitleWidget(
              axisSide: AxisSide.bottom,
              space: 0,
              fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: false),
              child: Text(
                value.toInt().toString(),
                style: kHeader3TextStyle.copyWith(fontSize: 12, color: context.appTheme.accentNegative),
              ),
            ),
          )
        : Gap.noGap;
  }

  List<LineTooltipItem> _lineTooltipItem(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      return LineTooltipItem(
        '${context.currentSettings.currency.symbol ?? context.currentSettings.currency.code} ${CalService.formatCurrency(context, touchedSpot.y)}',
        touchedSpot.x == 0 || touchedSpot.x == _endX
            ? kHeaderTransparent
            : kHeader2TextStyle.copyWith(
                color: context.appTheme.isDarkTheme
                    ? context.appTheme.backgroundNegative
                    : context.appTheme.primaryNegative,
                shadows: [
                  Shadow(
                      color: context.appTheme.isDarkTheme
                          ? context.appTheme.backgroundNegative.withOpacity(0.7)
                          : context.appTheme.primaryNegative.withOpacity(0.5),
                      blurRadius: 20)
                ],
                fontSize: 16,
              ),
      );
    }).toList();
  }

  List<TouchedSpotIndicatorData> _touchedIndicators(
    LineChartBarData barData,
    List<int> indicators,
  ) {
    return indicators.map((int index) {
      final x = barData.spots[index].x;

      /// Indicator Line
      const flLine = FlLine(color: Colors.transparent, strokeWidth: 0.0);

      final dotData = FlDotData(
        getDotPainter: (spot, percent, bar, _) => FlDotCirclePainter(
          radius: 8,
          color: x == 0 || x == _endX ? Colors.transparent : context.appTheme.accent.addDark(0.1),
          strokeColor: Colors.transparent,
        ),
      );

      return TouchedSpotIndicatorData(flLine, dotData);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 50),
      child: LineChart(
        LineChartData(
          maxY: _highestAmount * 0.9,
          minY: _lowestAmount - _highestAmount / 1.5,
          baselineY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              drawBelowEverything: false,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 14,
                interval: 1,
                getTitlesWidget: _bottomTitleWidgets,
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchSpotThreshold: 50,
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              tooltipBgColor: Colors.transparent,
              getTooltipItems: _lineTooltipItem,
            ),
            getTouchedSpotIndicator: _touchedIndicators,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, widget.beginValue ?? widget.valuesBetween.first.amount),
                ...widget.valuesBetween.map((e) => FlSpot(e.day.toDouble(), e.amount)),
                FlSpot(_endX, widget.endValue ?? widget.valuesBetween.last.amount),
              ],
              isCurved: true,
              isStrokeCapRound: true,
              barWidth: 4.5,
              dotData: const FlDotData(
                show: false,
              ),
              shadow: context.appTheme.isDarkTheme
                  ? Shadow(
                      color: context.appTheme.accent,
                      blurRadius: 50,
                    )
                  : const Shadow(color: Colors.transparent),
              color: context.appTheme.accent,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    context.appTheme.accent.withOpacity(0.65),
                    context.appTheme.accent.withOpacity(0.3),
                  ],
                  stops: const [0.3, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
