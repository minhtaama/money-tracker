import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;

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
  /// Only works when type is [CustomLineType.solidToDashed]
  final bool checkpoint;
}

class CustomLineChart extends StatefulWidget {
  const CustomLineChart({
    super.key,
    this.controller,
    this.primaryLineType = CustomLineType.solidToDashed,
    required this.currentMonth,
    required this.spots,
    this.chartOffsetY = 0,
    this.extraLineY,
    this.showExtraLine = false,
    this.extraLineText,
  });

  final ScrollController? controller;

  final CustomLineType primaryLineType;

  /// To determine value in x-axis (days in month)
  final DateTime currentMonth;

  final List<CLCSpot> spots;

  /// Offset chart but keep the bottom title at the same spot
  final double chartOffsetY;

  final double? extraLineY;

  final bool showExtraLine;

  final String? extraLineText;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  final maxY = 1.025;
  late final minY = 0 - (widget.chartOffsetY * 1.4) / 100;

  late double _chartFullWidth =
      math.max(kDayColumnLineChartWidth * widget.spots.length, Gap.screenWidth(context));

  bool _ignoreChart = false;

  @override
  Widget build(BuildContext context) {
    final cpIndex = widget.spots.indexWhere((e) => e.checkpoint);

    final hasCp = cpIndex != -1;

    final cpPercent = hasCp && widget.primaryLineType == CustomLineType.solidToDashed
        ? (widget.spots[cpIndex].x - widget.spots[0].x) /
            (widget.spots[widget.spots.length - 1].x - widget.spots[0].x)
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
        spots: widget.spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
        barWidth: widget.primaryLineType == CustomLineType.solid ? 3.5 : 2.5,
        dashArray: [12, widget.primaryLineType == CustomLineType.solid ? 0 : 8],
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

      // Optional solid line, as `barIndex == 1` and do not have BelowBarData
      // Only shows (logic by gradient) if there are both solid and dashed line.
      LineChartBarData(
        spots: widget.spots,
        isCurved: true,
        isStrokeCapRound: false,
        preventCurveOverShooting: true,
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
      ),
    ];

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final today = DateTime.now();
      bool isShowTitle = widget.spots.map((e) => e.x).contains(value.toInt());
      bool isToday = value == today.day && widget.currentMonth.isSameMonthAs(today);

      final textStyle = isToday
          ? kHeader2TextStyle.copyWith(fontSize: 12, color: context.appTheme.onAccent)
          : kHeader4TextStyle.copyWith(fontSize: 12, color: context.appTheme.onAccent);

      return isShowTitle
          ? Transform.translate(
              offset: Offset(0, -(6 + widget.chartOffsetY)),
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
          '${context.appSettings.currency.symbol} ${CalService.formatCurrency(context, widget.spots[touchedSpot.spotIndex].amount)} \n',
          kHeader2TextStyle.copyWith(
            color: context.appTheme.isDarkTheme
                ? context.appTheme.onBackground
                : context.appTheme.onSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.right,
          children: [
            TextSpan(
              text: widget.currentMonth
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
        bool isOptionalBar = barData.belowBarData.show == false;

        final flLine = FlLine(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              context.appTheme.accent1.withOpacity(0.35),
              context.appTheme.accent1.withOpacity(0.0)
            ],
            stops: const [0.46, 0.8],
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

    final titlesData = FlTitlesData(
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
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () {
        setState(() {
          _chartFullWidth += 50;
        });
      },
      onScaleStart: (details) {},
      onScaleUpdate: (details) {
        //print(details.pointerCount);
        if (details.pointerCount == 2 && details.scale != 0) {
          setState(() {
            _chartFullWidth = _chartFullWidth * details.scale;
          });
          print(details.scale);
        }
      },
      child: SingleChildScrollView(
        controller: widget.controller,
        physics: NeverScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        primary: false,
        child: Transform.translate(
          offset: Offset(0, widget.chartOffsetY),
          child: AnimatedContainer(
            duration: k1msDuration,
            width: _chartFullWidth,
            child: IgnorePointer(
              ignoring: true,
              child: LineChart(
                LineChartData(
                  maxY: maxY,
                  minY: minY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: titlesData,
                  lineTouchData: lineTouchData,
                  lineBarsData: lineBarsData,
                  extraLinesData: ExtraLinesData(
                    horizontalLines: widget.extraLineY != null
                        ? [
                            HorizontalLine(
                              y: widget.extraLineY!,
                              strokeWidth: 1.5,
                              dashArray: [15, 10],
                              label: HorizontalLineLabel(
                                show: true,
                                style: kHeader2TextStyle.copyWith(
                                  fontSize: 11,
                                  color: widget.showExtraLine
                                      ? context.appTheme.accent2.withOpacity(0.6)
                                      : context.appTheme.accent2.withOpacity(0),
                                ),
                                alignment: widget.extraLineY! < (maxY - minY) / 2
                                    ? Alignment.topRight
                                    : Alignment.bottomRight,
                                labelResolver: (_) => widget.extraLineText ?? '',
                              ),
                              color: widget.showExtraLine
                                  ? context.appTheme.accent2.withOpacity(0.15)
                                  : context.appTheme.accent2.withOpacity(0),
                            ),
                          ]
                        : [],
                  ),
                ),
                duration: k550msDuration,
                curve: Curves.easeInOutCubic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum CustomLineType { dashed, solid, solidToDashed }
