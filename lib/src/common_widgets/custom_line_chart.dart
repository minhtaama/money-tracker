import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;

/// This class extends [FlSpot], which has `amount` property to store original amount
///
/// The X-axis represents day,
///
/// The Y-axis represents the ratio of the `amount` at that point to the highest `amount`
class LineChartSpot extends FlSpot {
  LineChartSpot(super.x, super.y, {required this.amount});

  final double amount;
}

class CustomLineChart extends ConsumerWidget {
  const CustomLineChart({
    super.key,
    required this.currentMonthView,
    required this.valuesBuilder,
    this.chartOffsetY = 0,
  });
  final List<LineChartSpot> Function(WidgetRef) valuesBuilder;
  final DateTime currentMonthView;
  final double chartOffsetY;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<LineChartSpot> data = valuesBuilder(ref);

    double minYSpot = double.maxFinite;

    for (LineChartSpot spot in data) {
      if (spot.y < minYSpot) {
        minYSpot = spot.y;
      }
    }

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      bool isShowTitle = data.map((e) => e.x).contains(value.toInt());

      return isShowTitle
          ? Transform.translate(
              offset: Offset(0, -(6 + chartOffsetY)),
              child: SideTitleWidget(
                axisSide: AxisSide.bottom,
                space: 0,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true),
                child: Text(
                  value.toInt().toString(),
                  style: kHeader3TextStyle.copyWith(fontSize: 12, color: context.appTheme.onAccent),
                ),
              ),
            )
          : Gap.noGap;
    }

    List<LineTooltipItem> lineTooltipItem(List<LineBarSpot> touchedSpots) {
      return touchedSpots.map((LineBarSpot touchedSpot) {
        return LineTooltipItem(
          '${context.currentSettings.currency.symbol} ${CalService.formatCurrency(context, data[touchedSpot.spotIndex].amount)} \n',
          kHeader2TextStyle.copyWith(
            color: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.right,
          children: [
            TextSpan(
              text: currentMonthView
                  .copyWith(day: touchedSpot.x.toInt())
                  .getFormattedDate(hasYear: false, format: DateTimeFormat.ddmmmyyyy),
              style: kHeader3TextStyle.copyWith(
                color: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
                fontSize: 11,
              ),
            ),
          ],
        );
      }).toList();
    }

    List<TouchedSpotIndicatorData> touchedIndicators(LineChartBarData barData, List<int> indicators) {
      return indicators.map((int index) {
        final x = barData.spots[index].x;

        /// Indicator Line
        const flLine = FlLine(color: Colors.transparent, strokeWidth: 0.0);

        final dotData = FlDotData(
          getDotPainter: (spot, percent, bar, _) => FlDotCirclePainter(
            radius: 8,
            color: context.appTheme.accent1.addDark(0.1),
            strokeColor: Colors.transparent,
          ),
        );

        return TouchedSpotIndicatorData(flLine, dotData);
      }).toList();
    }

    final lineTouchData = LineTouchData(
      enabled: true,
      touchSpotThreshold: 50,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        tooltipRoundedRadius: 12,
        tooltipHorizontalAlignment: FLHorizontalAlignment.center,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipBgColor: context.appTheme.isDarkTheme
            ? context.appTheme.background0.withOpacity(0.8)
            : context.appTheme.secondary2.withOpacity(0.8),
        getTooltipItems: lineTooltipItem,
      ),
      getTouchedSpotIndicator: touchedIndicators,
    );

    final lineChartBarData = [
      LineChartBarData(
        spots: data,
        isCurved: true,
        isStrokeCapRound: true,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 10,
        barWidth: 5,
        shadow: context.appTheme.isDarkTheme
            ? Shadow(
                color: context.appTheme.accent1,
                blurRadius: 50,
              )
            : const Shadow(color: Colors.transparent),
        color: context.appTheme.accent1,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              context.appTheme.accent1.withOpacity(0.65),
              context.appTheme.accent1.withOpacity(0.3),
            ],
            stops: const [0.3, 1],
          ),
        ),
        dotData: const FlDotData(show: false),
      )
    ];

    return Transform.translate(
      offset: Offset(0, chartOffsetY),
      child: LineChart(
        LineChartData(
          maxY: 1,
          minY: 0 - (chartOffsetY * 1.2) / 100,
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
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
          ),
          lineTouchData: lineTouchData,
          lineBarsData: lineChartBarData,
        ),
        duration: k550msDuration,
        curve: Curves.easeOutBack,
      ),
    );
  }
}
