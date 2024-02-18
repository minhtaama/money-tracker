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
    this.offsetLabelUp = 0,
    this.extraLineY,
    this.extraLineText,
    this.isForCredit = false,
    this.color,
    this.todayDotColor,
  });

  /// To determine value in x-axis (days in month)
  final DateTime currentMonth;

  final CLCData data;

  /// Offset chart but keep the bottom title at the same spot
  final double offsetLabelUp;

  final double? extraLineY;

  final String? extraLineText;

  final bool isForCredit;

  final Color? color;

  final Color? todayDotColor;

  _CustomLineType get _customLineType {
    final today = DateTime.now();
    final hasToday = data.spots.indexWhere((spot) => spot.isToday);

    if (hasToday >= 0) {
      return _CustomLineType.solidToDashed;
    }

    if (currentMonth.isInMonthAfter(today)) {
      return _CustomLineType.dashed;
    }

    return _CustomLineType.solid;
  }

  @override
  Widget build(BuildContext context) {
    const maxY = 1.025;
    final minY = 0 - (offsetLabelUp * 1.4) / 100;

    final spots = data.spots;

    final todayIndex = spots.indexWhere((e) => e.isToday);
    final hasToday = todayIndex != -1;

    final statementDayIndex = isForCredit ? spots.indexWhere((e) => (e as CLCSpotForCredit).isStatementDay) : -1;
    final previousDueDayIndex = isForCredit ? spots.indexWhere((e) => (e as CLCSpotForCredit).isPreviousDueDay) : -1;

    // 0.2 is added for step chart to display correctly
    final todayPercent = hasToday && _customLineType == _CustomLineType.solidToDashed
        ? (spots[todayIndex].x - spots[0].x + 0.2) / (spots[spots.length - 1].x - spots[0].x)
        : 0.0;

    final optionalLineGradient = LinearGradient(
      colors: [color ?? context.appTheme.accent1, color?.withOpacity(0) ?? context.appTheme.accent1.withOpacity(0)],
      stops: [todayPercent, todayPercent + 0.00000001],
    );

    Gradient mainBelowLineGradient() {
      bool isDashed = _customLineType == _CustomLineType.dashed;
      bool isDarkTheme = context.appTheme.isDarkTheme;
      double opaTop = isDarkTheme ? (isDashed ? 0.25 : 0.35) : (isDashed ? 0.2 : 0.35);
      double opaBottom = isDarkTheme ? 0.15 : 0;

      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color?.withOpacity(opaTop) ?? context.appTheme.accent1.withOpacity(opaTop),
          color?.withOpacity(opaBottom) ?? context.appTheme.accent1.withOpacity(opaBottom),
        ],
        stops: const [0, 0.7],
      );
    }

    Alignment extraLineLabelAlignment() {
      if (extraLineY == null) {
        return Alignment.topRight;
      }

      bool isLeft = false;

      double avgYBegin = 0;
      double avgYEnd = 0;

      for (int i = 0; i <= spots.length / 2; i++) {
        avgYBegin += spots[i].y;
      }
      for (int i = spots.length - 1; i >= spots.length / 2; i--) {
        avgYEnd += spots[i].y;
      }

      avgYBegin = (avgYBegin / (spots.length / 2)).clamp(0, 1);
      avgYEnd = (avgYEnd / (spots.length / 2)).clamp(0, 1);

      if (todayIndex >= spots.length / 2) {
        isLeft = true;
      }

      if (isLeft) {
        return avgYBegin > extraLineY! ? Alignment.bottomLeft : Alignment.topLeft;
      } else {
        return avgYEnd > extraLineY! ? Alignment.bottomRight : Alignment.topRight;
      }
    }

    final lineBarsData = [
      // Main line.
      // Always shows, has BelowBarData, default is dashed,
      // will turns to solid if only type is `solid`.
      LineChartBarData(
        spots: spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
        barWidth: _customLineType == _CustomLineType.solid ? 3 : 1.5,
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
          gradient: mainBelowLineGradient(),
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
        barWidth: 3,
        gradient: optionalLineGradient,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return hasToday && barData.spots.indexOf(spot) == todayIndex ||
                isForCredit && barData.spots.indexOf(spot) == statementDayIndex ||
                isForCredit && barData.spots.indexOf(spot) == previousDueDayIndex;
          },
          getDotPainter: (spot, percent, bar, index) {
            if (hasToday && index == todayIndex) {
              bool boxUnderDot = false;
              if (index >= (spots.length - 1) - 3) {
                if (spots[index].y > spots[index - 1].y) {
                  boxUnderDot = true;
                }
              } else {
                if (spots[index + 1].y > spots[index].y) {
                  boxUnderDot = true;
                }
              }

              //TODO: add some more when index + 2 is higher...

              return FlDotTodayPainter(
                context,
                color: color ?? context.appTheme.accent1,
                dotColor: todayDotColor ??
                    (context.appTheme.isDarkTheme ? context.appTheme.background2 : context.appTheme.secondary1),
                boxUnderDot: boxUnderDot,
              );
            }
            return FlDotCirclePainter(
              radius: 4,
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
          : kNormalTextStyle.copyWith(fontSize: 12, color: color ?? context.appTheme.onBackground);

      return isShowTitle
          ? Transform.translate(
              offset: Offset(0, -(6 + offsetLabelUp)),
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
          orElse: () => CLCSpotForCredit(0, 0, amount: 0, isStatementDay: false, isPreviousDueDay: false));

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
              offset: Offset(0, -(6 + offsetLabelUp)),
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
                        ? color?.withOpacity(0.2) ??
                            (context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground.withOpacity(0.2)
                                : context.appTheme.onSecondary.withOpacity(0.2))
                        : color?.withOpacity(0) ??
                            (context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground.withOpacity(0)
                                : context.appTheme.onSecondary.withOpacity(0)),
                  ),
                  alignment: extraLineLabelAlignment(),
                  labelResolver: (_) => extraLineText ?? '',
                ),
                color: extraLineY != null
                    ? color?.withOpacity(0.1) ??
                        (context.appTheme.isDarkTheme
                            ? context.appTheme.onBackground.withOpacity(0.1)
                            : context.appTheme.onSecondary.withOpacity(0.1))
                    : color?.withOpacity(0) ??
                        (context.appTheme.isDarkTheme
                            ? context.appTheme.onBackground.withOpacity(0)
                            : context.appTheme.onSecondary.withOpacity(0)),
              ),
            ]
          : [],
    );

    return Transform.translate(
      offset: Offset(0, isForCredit ? 30 : 14),
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

class FlDotTodayPainter extends FlDotPainter {
  /// This class is an implementation of a [FlDotPainter] that draws
  /// a circled shape and a "today" indicator
  FlDotTodayPainter(
    this.context, {
    required this.color,
    this.dotRadius = 4.0,
    this.cornerRadius = 6.0,
    this.dotColor,
    this.dotStrokeWidth = 2.5,
    this.textPadding = const EdgeInsets.all(4),
    this.boxUnderDot = false,
    this.boxAtLeft = false,
  });

  BuildContext context;

  Color color;

  double dotRadius;

  /// Optional color for dot color
  Color? dotColor;

  /// The stroke width to use for the circle
  double dotStrokeWidth;

  EdgeInsets textPadding;

  double cornerRadius;

  bool boxUnderDot;

  bool boxAtLeft;

  double get _colorLum => color.computeLuminance();

  void _drawDot(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    if (dotStrokeWidth != 0.0) {
      canvas.drawCircle(
        offsetInCanvas,
        dotRadius + (dotStrokeWidth / 2),
        Paint()
          ..color = color
          ..strokeWidth = dotStrokeWidth
          ..style = PaintingStyle.stroke,
      );
    }

    canvas.drawCircle(
      offsetInCanvas,
      dotRadius,
      Paint()
        ..color = dotColor ?? color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawText(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final textSpan = TextSpan(
      text: 'Today'.hardcoded,
      style: kHeader3TextStyle.copyWith(
        color: _colorLum < 0.5 ? AppColors.white : AppColors.black,
        fontSize: 10,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(
        minWidth: 0,
        maxWidth: 150,
      );

    bool isBoxAtLeft = false;

    final offsetFromDot = Offset((textPainter.width + textPadding.horizontal) / 2, boxUnderDot ? 12 : -32);

    // Offset to center with the dot
    Offset textOffset = Offset(
      offsetInCanvas.dx + offsetFromDot.dx - (textPainter.width / 2),
      offsetInCanvas.dy + offsetFromDot.dy + textPadding.top,
    );

    // Re-calculate the offset with screen width
    if (textOffset.dx + textPainter.width + textPadding.horizontal > Gap.screenWidth(context) || boxAtLeft) {
      textOffset = Offset(
        offsetInCanvas.dx - textPainter.width - (textPadding.horizontal / 2) - dotRadius,
        textOffset.dy,
      );

      isBoxAtLeft = true;
    }

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        textOffset.dx - textPadding.left,
        textOffset.dy - textPadding.top,
        textOffset.dx + textPainter.width + textPadding.right,
        textOffset.dy + textPainter.height + textPadding.bottom,
        topLeft: Radius.circular(!isBoxAtLeft && boxUnderDot ? 0 : cornerRadius),
        topRight: Radius.circular(isBoxAtLeft && boxUnderDot ? 0 : cornerRadius),
        bottomRight: Radius.circular(isBoxAtLeft && !boxUnderDot ? 0 : cornerRadius),
        bottomLeft: Radius.circular(!isBoxAtLeft && !boxUnderDot ? 0 : cornerRadius),
      ),
      Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );

    textPainter.paint(canvas, textOffset);
  }

  /// Implementation of the parent class to draw the circle
  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    _drawDot(canvas, spot, offsetInCanvas);

    _drawText(canvas, spot, offsetInCanvas);
  }

  /// Implementation of the parent class to get the size of the circle
  @override
  Size getSize(FlSpot spot) {
    return Size(dotRadius * 2, dotRadius * 2);
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        color,
        dotRadius,
        dotColor,
        dotStrokeWidth,
      ];
}
