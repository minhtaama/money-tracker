import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_line_chart_services.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
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
  CLCSpot(super.x, super.y, {required this.amount, this.checkpoint = false, this.dateTime});

  /// To store original amount of y-axis
  final double amount;

  /// To store original value (as DateTime) of x-axis.
  ///
  /// If null, use x-axis to represent bottom labels.
  final DateTime? dateTime;

  /// Is the spot where line turn from solid to dashed.
  ///
  /// Only works when type is [CustomLineType.solidToDashed]
  final bool checkpoint;
}

enum CustomLineType { dashed, solid, solidToDashed }

class CustomLineChart extends StatelessWidget {
  const CustomLineChart({
    super.key,
    required this.currentMonth,
    required this.data,
    this.offsetY = 0,
    this.extraLineY,
    this.extraLineText,
    this.isForCredit = false,
  });

  /// To determine value in x-axis (days in month)
  final DateTime currentMonth;

  final CLCData data;

  /// Offset chart but keep the bottom title at the same spot
  final double offsetY;

  final double? extraLineY;

  final String? extraLineText;

  final bool isForCredit;

  CustomLineType get _customLineType {
    final today = DateTime.now();
    final hasCheckpoint = data.spots.indexWhere((spot) => spot.checkpoint);

    if (hasCheckpoint >= 0) {
      return CustomLineType.solidToDashed;
    }

    if (currentMonth.isInMonthAfter(today)) {
      return CustomLineType.dashed;
    }

    if (currentMonth.isInMonthBefore(today)) {
      return CustomLineType.solid;
    }

    throw ErrorDescription('Whoop whoop');
  }

  @override
  Widget build(BuildContext context) {
    const maxY = 1.025;
    final minY = 0 - (offsetY * 1.4) / 100;

    final spots = data.spots;

    final cpIndex = spots.indexWhere((e) => e.checkpoint);

    final hasCp = cpIndex != -1;

    // 0.2 is added for step chart to display correctly
    final cpPercent = hasCp && _customLineType == CustomLineType.solidToDashed
        ? (spots[cpIndex].x - spots[0].x + 0.2) / (spots[spots.length - 1].x - spots[0].x)
        : 0.0;

    final optionalBarGradient = LinearGradient(
      colors: [context.appTheme.accent1, context.appTheme.accent1.withOpacity(0)],
      stops: [cpPercent, cpPercent + 0.00000001],
    );

    final lineBarsData = [
      // Main line.
      // Always shows, has BelowBarData, default is dashed,
      // will turns to solid if only type is `solid`.
      LineChartBarData(
        spots: spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 0,
        barWidth: _customLineType == CustomLineType.solid ? 3.5 : 2.5,
        dashArray: [12, _customLineType == CustomLineType.solid ? 0 : 8],
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
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              context.appTheme.accent1.withOpacity(0),
              context.appTheme.accent1.withOpacity(0.65),
            ],
            stops: const [0.15, 0.9],
          ),
        ),
        dotData: const FlDotData(show: false),
        isStepLineChart: isForCredit,
        lineChartStepData: const LineChartStepData(stepDirection: 0),
      ),

      // Optional solid line, as `barIndex == 1` and do not have BelowBarData
      // Only shows (logic by gradient) if there are both solid and dashed line.
      LineChartBarData(
        spots: spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 0,
        barWidth: 3.5,
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
        isStepLineChart: isForCredit,
        lineChartStepData: const LineChartStepData(stepDirection: 0),
      ),
    ];

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final today = DateTime.now();

      bool isToday = value == today.day && currentMonth.isSameMonthAs(today);

      final bottomLabels = currentMonth.daysInMonth == 31 || currentMonth.daysInMonth == 30
          ? [1, 8, 15, 23, currentMonth.daysInMonth]
          : [1, 7, 14, 21, currentMonth.daysInMonth];

      bool isShowTitle = bottomLabels.contains(value.toInt());

      final textStyle = isToday
          ? kHeader2TextStyle.copyWith(fontSize: 12, color: context.appTheme.onBackground)
          : kHeader4TextStyle.copyWith(fontSize: 12, color: context.appTheme.onBackground);

      return isShowTitle
          ? Transform.translate(
              offset: Offset(0, -(6 + offsetY)),
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

    Widget bottomTitleWidgetsForCredit(double value, TitleMeta meta) {
      final spot = spots.firstWhere((spot) => spot.x == value, orElse: () => CLCSpot(0, 0, amount: 0));

      final isShowTitle = (data as CLCDataForCredit).dateTimesToShow.contains(spot.dateTime);

      final icon =
          spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[2] ? AppIcons.handCoin : AppIcons.budgets;

      final crossAlignment = spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[0]
          ? CrossAxisAlignment.start
          : spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[2]
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center;

      final textStyle = kHeader2TextStyle.copyWith(fontSize: 12, color: context.appTheme.onBackground);

      return isShowTitle
          ? Transform.translate(
              offset: Offset(0, -(6 + offsetY)),
              child: SideTitleWidget(
                axisSide: AxisSide.bottom,
                space: 0,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true, distanceFromEdge: 9),
                child: FittedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: crossAlignment,
                    children: [
                      SvgIcon(
                        icon,
                        color: context.appTheme.onBackground,
                      ),
                      Text(
                        spot.dateTime!.getFormattedDate(hasYear: false),
                        style: textStyle,
                      ),
                    ],
                  ),
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

        final amount = spots[touchedSpot.spotIndex].amount;
        final dateTime =
            spots[touchedSpot.spotIndex].dateTime?.getFormattedDate(hasYear: false, format: DateTimeFormat.ddmmmyyyy) ??
                currentMonth
                    .copyWith(day: touchedSpot.x.toInt())
                    .getFormattedDate(hasYear: false, format: DateTimeFormat.ddmmmyyyy);

        items.add(LineTooltipItem(
          '${context.appSettings.currency.symbol} ${CalService.formatCurrency(context, amount)} \n',
          kHeader2TextStyle.copyWith(
            color: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.right,
          children: [
            TextSpan(
              text: dateTime,
              style: kHeader3TextStyle.copyWith(
                color: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
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
        bool isOptionalBar = barData.belowBarData.show == false;

        const flLine = FlLine(color: Colors.transparent);

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

    final titlesData = FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        drawBelowEverything: false,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: isForCredit ? 30 : 14,
          interval: 1,
          getTitlesWidget: isForCredit ? bottomTitleWidgetsForCredit : bottomTitleWidgets,
        ),
      ),
    );

    final extraLinesData = ExtraLinesData(
      horizontalLines: extraLineY != null
          ? [
              HorizontalLine(
                y: extraLineY!,
                strokeWidth: 1.5,
                dashArray: [12, 8],
                label: HorizontalLineLabel(
                  show: true,
                  style: kHeader2TextStyle.copyWith(
                    fontSize: 11,
                    color: extraLineY != null
                        ? context.appTheme.accent2.withOpacity(0.3)
                        : context.appTheme.accent2.withOpacity(0),
                  ),
                  alignment: extraLineY! < (maxY - minY) / 2 ? Alignment.topRight : Alignment.bottomRight,
                  labelResolver: (_) => extraLineText ?? '',
                ),
                color: extraLineY != null
                    ? context.appTheme.accent2.withOpacity(0.15)
                    : context.appTheme.accent2.withOpacity(0),
              ),
            ]
          : [],
    );

    return Transform.translate(
      offset: Offset(0, offsetY),
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: minY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: titlesData,
          lineTouchData: lineTouchData,
          lineBarsData: lineBarsData,
          extraLinesData: extraLinesData,
        ),
        duration: k550msDuration,
        curve: Curves.easeInOut,
      ),
    );
  }
}
