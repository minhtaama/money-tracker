import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

class CLCSpot extends FlSpot {
  /// Custom Line Chart Spot, use with [CustomLineChart]. This class extends [FlSpot],
  /// which has additional `amount` and `checkpoint` property.
  ///
  /// The X-axis represents day,
  ///
  /// The Y-axis represents the ratio of the `amount` at that point to the highest `amount`
  CLCSpot(super.x, super.y, {required this.amount, this.checkpoint = false});

  /// To store original amount
  final double amount;

  /// Is the spot where line turn from solid to dashed.
  ///
  /// Only works when type is [CustomLineType.solidThenDashed]
  final bool checkpoint;
}

class CustomLineChart extends ConsumerWidget {
  const CustomLineChart({
    super.key,
    this.primaryLineType = CustomLineType.solidThenDashed,
    this.chartDataType = ChartDataType.cashflow,
    required this.currentMonth,
    required this.valuesBuilder,
    this.chartOffsetY = 0,
  });

  final CustomLineType primaryLineType;
  final ChartDataType chartDataType;

  /// To determine value in x-axis (days in month)
  final DateTime currentMonth;

  final List<CLCSpot> Function(WidgetRef) valuesBuilder;

  /// Offset chart but keep the bottom title at the same spot
  final double chartOffsetY;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = valuesBuilder(ref);

    final cpIndex = spots.indexWhere((e) => e.checkpoint);

    final hasCp = cpIndex != -1;

    final cpPercent = hasCp && primaryLineType == CustomLineType.solidThenDashed
        ? (spots[cpIndex].x - 1) / spots[spots.length - 1].x
        : 0.0;

    final optionalBarGradient = LinearGradient(
      colors: [context.appTheme.accent1, context.appTheme.accent1.withOpacity(0)],
      stops: [cpPercent, cpPercent + 0.00000001],
    );

    final lineBarsData = [
      // Main line.
      // Always shows, default is dashed,
      // will turns to solid if type is `solid`.
      LineChartBarData(
        spots: spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
        dashArray: [
          15,
          primaryLineType == CustomLineType.solid ||
                  primaryLineType == CustomLineType.solidThenDashed && !hasCp
              ? 0
              : 12,
        ],
        barWidth: primaryLineType == CustomLineType.solid ? 5 : 3,
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.appTheme.accent1.withOpacity(0.15),
              context.appTheme.accent1.withOpacity(0.65),
            ],
            stops: const [0, 1],
          ),
        ),
        dotData: const FlDotData(show: false),
      ),

      // Optional solid line, as `barIndex == 1`.
      // Only shows (logic by gradient) if there are both solid and dashed line.
      LineChartBarData(
        spots: spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
        barWidth: 5,
        gradient: optionalBarGradient,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return hasCp && barData.spots.indexOf(spot) == cpIndex;
          },
          getDotPainter: (spot, percent, bar, index) {
            return FlDotCirclePainter(
              radius: 6.5,
              color: context.appTheme.accent1,
              strokeColor: Colors.transparent,
            );
          },
        ),
      ),
    ];

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final today = DateTime.now();
      bool isShowTitle = spots.map((e) => e.x).contains(value.toInt());
      bool isToday = value == today.day && currentMonth.isSameMonthAs(today);

      final textStyle = isToday
          ? kHeader2TextStyle.copyWith(fontSize: 12, color: context.appTheme.onAccent)
          : kHeader4TextStyle.copyWith(fontSize: 12, color: context.appTheme.onAccent);

      return isShowTitle
          ? Transform.translate(
              offset: Offset(0, -(6 + chartOffsetY)),
              child: SideTitleWidget(
                axisSide: AxisSide.bottom,
                space: 0,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true),
                child: Text(
                  value.toInt().toString(),
                  style: textStyle,
                ),
              ),
            )
          : Gap.noGap;
    }

    List<LineTooltipItem?> lineTooltipItem(List<LineBarSpot> touchedSpots) {
      List<LineTooltipItem?> items = [];

      // loop through EACH touchedSpot of a bar
      for (int i = 0; i < touchedSpots.length; i++) {
        final touchedSpot = touchedSpots[i];

        // if touchedSpot is of optional bar (the second one in the list)
        if (touchedSpot.barIndex == 1) {
          items.add(null);
          continue;
        }

        items.add(LineTooltipItem(
          '${context.appSettings.currency.symbol} ${CalService.formatCurrency(context, spots[touchedSpot.spotIndex].amount)} \n',
          kHeader2TextStyle.copyWith(
            color: context.appTheme.isDarkTheme
                ? context.appTheme.onBackground
                : context.appTheme.onSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.right,
          children: [
            TextSpan(
              text: currentMonth
                  .copyWith(day: touchedSpot.x.toInt())
                  .getFormattedDate(hasYear: false, format: DateTimeFormat.ddmmmyyyy),
              style: kHeader3TextStyle.copyWith(
                color: context.appTheme.isDarkTheme
                    ? context.appTheme.onBackground
                    : context.appTheme.onSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ));
      }

      return items;
    }

    List<TouchedSpotIndicatorData?> touchedIndicators(LineChartBarData barData, List<int> spotIndex) {
      return spotIndex.map((int index) {
        bool isOptionalBar = barData.dashArray == null;

        final flLine = FlLine(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              context.appTheme.accent1.withOpacity(0.35),
              context.appTheme.accent1.withOpacity(0.0)
            ],
            stops: const [0.46, 0.95],
          ),
          strokeWidth: isOptionalBar ? 0 : 50,
        );

        final dotData = FlDotData(
          getDotPainter: (spot, percent, bar, index) {
            //print(bar.barWidth);
            return FlDotCirclePainter(
              radius: isOptionalBar ? 0 : 8,
              color: context.appTheme.accent1.addDark(0.1),
              strokeColor: Colors.transparent,
            );
          },
        );

        return TouchedSpotIndicatorData(flLine, dotData);
      }).toList();
    }

    final lineTouchData = LineTouchData(
      touchSpotThreshold: 50,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        tooltipRoundedRadius: 12,
        tooltipHorizontalAlignment: FLHorizontalAlignment.center,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipBgColor: context.appTheme.isDarkTheme
            ? context.appTheme.background0.withOpacity(0.9)
            : context.appTheme.secondary2.withOpacity(0.8),
        getTooltipItems: lineTooltipItem,
      ),
      getTouchedSpotIndicator: touchedIndicators,
    );

    return Transform.translate(
      offset: Offset(0, chartOffsetY),
      child: LineChart(
        LineChartData(
          maxY: 1,
          minY: 0 - (chartOffsetY * 1.4) / 100,
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
          lineBarsData: lineBarsData,
        ),
        duration: k950msDuration,
        curve: Curves.easeOutBack,
      ),
    );
  }
}

enum CustomLineType { dashed, solid, solidThenDashed }
