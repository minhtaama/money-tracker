import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_line_chart_services.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../theme_and_ui/colors.dart';

enum _CustomLineType { dashed, solid, solidToDashed }

class CustomLineChart extends StatelessWidget {
  const CustomLineChart({
    super.key,
    required this.currentMonth,
    required this.data,
    this.offsetY = 0,
    this.extraLineY,
    this.extraLineText,
    this.isForCredit = false,
    this.color,
  });

  /// To determine value in x-axis (days in month)
  final DateTime currentMonth;

  final CLCData data;

  /// Offset chart but keep the bottom title at the same spot
  final double offsetY;

  final double? extraLineY;

  final String? extraLineText;

  final bool isForCredit;

  final Color? color;

  _CustomLineType get _customLineType {
    final today = DateTime.now();
    final hasToday = data.spots.indexWhere((spot) => spot.isToday);

    if (hasToday >= 0) {
      return _CustomLineType.solidToDashed;
    }

    if (currentMonth.isInMonthAfter(today)) {
      return _CustomLineType.dashed;
    }

    if (currentMonth.isInMonthBefore(today)) {
      return _CustomLineType.solid;
    }

    throw ErrorDescription('Whoop whoop');
  }

  @override
  Widget build(BuildContext context) {
    const maxY = 1.025;
    final minY = 0 - (offsetY * 1.4) / 100;

    final spots = data.spots;

    final todayIndex = spots.indexWhere((e) => e.isToday);
    final hasToday = todayIndex != -1;

    // 0.2 is added for step chart to display correctly
    final todayPercent = hasToday && _customLineType == _CustomLineType.solidToDashed
        ? (spots[todayIndex].x - spots[0].x + 0.2) / (spots[spots.length - 1].x - spots[0].x)
        : 0.0;

    final optionalBarGradient = LinearGradient(
      colors: [color ?? context.appTheme.accent1, color?.withOpacity(0) ?? context.appTheme.accent1.withOpacity(0)],
      stops: [todayPercent, todayPercent + 0.00000001],
    );

    final statementIndex = isForCredit ? spots.indexWhere((e) => (e as CLCSpotForCredit).isStatementDay) : -1;

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
        barWidth: _customLineType == _CustomLineType.solid ? 3 : 1,
        dashArray: [12, _customLineType == _CustomLineType.solid ? 0 : 8],
        shadow: context.appTheme.isDarkTheme
            ? Shadow(
                color: context.appTheme.accent1,
                blurRadius: 50,
              )
            : const Shadow(color: Colors.transparent),
        color: color ?? context.appTheme.accent1,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color?.withOpacity(0) ?? context.appTheme.accent1.withOpacity(0),
              color?.withOpacity(0.55) ?? context.appTheme.accent1.withOpacity(0.55),
            ],
            stops: const [0.15, 0.9],
          ),
        ),
        dotData: FlDotData(
          show: isForCredit,
          checkToShowDot: (spot, barData) {
            return isForCredit && barData.spots.indexOf(spot) == statementIndex;
          },
          getDotPainter: (spot, percent, bar, index) {
            return FlDotCirclePainter(
              radius: 3.5,
              color: color ?? context.appTheme.accent1,
              strokeColor: Colors.transparent,
            );
          },
        ),
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
        barWidth: 3,
        gradient: optionalBarGradient,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return hasToday && barData.spots.indexOf(spot) == todayIndex;
          },
          getDotPainter: (spot, percent, bar, index) {
            return FlDotCirclePainter(
              radius: 3.5,
              color: color ?? context.appTheme.accent1,
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
          ? kHeader2TextStyle.copyWith(fontSize: 12, color: color ?? context.appTheme.onBackground)
          : kHeader4TextStyle.copyWith(fontSize: 12, color: color ?? context.appTheme.onBackground);

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
      final spot = spots.firstWhere((spot) => spot.x == value,
          orElse: () => CLCSpotForCredit(0, 0, amount: 0, isStatementDay: false));

      final isShowTitle = (data as CLCDataForCredit).dateTimesToShow.contains(spot.dateTime);

      final icon = spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[1] ||
              spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[3]
          ? AppIcons.handCoin
          : AppIcons.budgets;

      final crossAlignment = spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[0]
          ? CrossAxisAlignment.start
          : spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[3]
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center;

      final textStyle = kHeader2TextStyle.copyWith(fontSize: 12, color: color ?? context.appTheme.onBackground);

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
                        color: color ?? context.appTheme.onBackground,
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
      final lum = color?.computeLuminance();

      // loop through EACH touchedSpot of a bar
      for (int i = 0; i < touchedSpots.length; i++) {
        final touchedSpot = touchedSpots[i];

        // if touchedSpot is of optional bar (the second one in the list)
        if (touchedSpot.barIndex == 1) {
          items.add(null);
          continue;
        }

        final spot = spots[touchedSpot.spotIndex];
        final symbol = context.appSettings.currency.symbol;
        final dateTime = spot.dateTime?.getFormattedDate(hasYear: false, format: DateTimeFormat.ddmmmyyyy) ??
            currentMonth
                .copyWith(day: touchedSpot.x.toInt())
                .getFormattedDate(hasYear: false, format: DateTimeFormat.ddmmmyyyy);

        final line1 = isForCredit ? '$dateTime\n' : '$symbol${CalService.formatCurrency(context, spot.amount)} \n';

        String line2() {
          if (isForCredit) {
            if (spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[0]) {
              return 'Billing cycle start\n(Previous statement date)\n'.hardcoded;
            }
            if (spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[1]) {
              return 'Previous due date\n'.hardcoded;
            }
            if (spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[2]) {
              return 'Statement date\n'.hardcoded;
            }
            if (spot.dateTime == (data as CLCDataForCredit).dateTimesToShow[3]) {
              return 'Due date\n'.hardcoded;
            }
            if (spot.dateTime!.isAfter((data as CLCDataForCredit).dateTimesToShow[2])) {
              return 'In grace period\n(Next statement billing cycle)\n'.hardcoded;
            }
            if (spot.dateTime!.isBefore((data as CLCDataForCredit).dateTimesToShow[1])) {
              return 'In billing cycle\n(Previous grace period)\n'.hardcoded;
            }
            if (spot.dateTime!.isAfter((data as CLCDataForCredit).dateTimesToShow[1])) {
              return 'In billing cycle\n'.hardcoded;
            }
          }

          return '';
        }

        final line3 = isForCredit
            ? 'Oustd. Bal: $symbol${CalService.formatCurrency(context, (data as CLCDataForCredit).maxAmount - spot.amount)}\n'
            : dateTime;

        final line4 = isForCredit ? 'Credit left: $symbol${CalService.formatCurrency(context, spot.amount)}' : '';

        items.add(LineTooltipItem(
          line1,
          kHeader2TextStyle.copyWith(
            color: lum == null
                ? (context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary)
                : lum > 0.5
                    ? AppColors.black
                    : AppColors.white,
            fontSize: isForCredit ? 11 : 13,
          ),
          textAlign: isForCredit ? TextAlign.left : TextAlign.right,
          children: [
            TextSpan(
              text: line2(),
              style: kHeader2TextStyle.copyWith(
                color: lum == null
                    ? (context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary)
                    : lum > 0.5
                        ? AppColors.black
                        : AppColors.white,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: line3,
              style: kHeader3TextStyle.copyWith(
                color: lum == null
                    ? (context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary)
                    : lum > 0.5
                        ? AppColors.black
                        : AppColors.white,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: line4,
              style: kHeader3TextStyle.copyWith(
                color: lum == null
                    ? (context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary)
                    : lum > 0.5
                        ? AppColors.black
                        : AppColors.white,
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
              radius: isOptionalBar ? 0 : 5,
              color: color?.addDark(0.1) ?? context.appTheme.accent1.addDark(0.1),
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
        maxContentWidth: 500,
        tooltipHorizontalAlignment: FLHorizontalAlignment.center,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipBgColor: color?.withOpacity(0.9) ??
            (context.appTheme.isDarkTheme
                ? context.appTheme.background0.withOpacity(0.9)
                : context.appTheme.secondary2.withOpacity(0.8)),
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
                strokeWidth: 0.7,
                dashArray: [12, 8],
                label: HorizontalLineLabel(
                  show: true,
                  style: kHeader3TextStyle.copyWith(
                    fontSize: 11,
                    color: extraLineY != null
                        ? color?.withOpacity(0.3) ??
                            (context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground.withOpacity(0.3)
                                : context.appTheme.onSecondary.withOpacity(0.3))
                        : color?.withOpacity(0) ??
                            (context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground.withOpacity(0)
                                : context.appTheme.onSecondary.withOpacity(0)),
                  ),
                  alignment: extraLineY! < (maxY - minY) / 2 ? Alignment.topRight : Alignment.bottomRight,
                  labelResolver: (_) => extraLineText ?? '',
                ),
                color: extraLineY != null
                    ? color?.withOpacity(0.3) ??
                        (context.appTheme.isDarkTheme
                            ? context.appTheme.onBackground.withOpacity(0.3)
                            : context.appTheme.onSecondary.withOpacity(0.3))
                    : color?.withOpacity(0) ??
                        (context.appTheme.isDarkTheme
                            ? context.appTheme.onBackground.withOpacity(0)
                            : context.appTheme.onSecondary.withOpacity(0)),
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
