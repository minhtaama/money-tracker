import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../theme_and_ui/colors.dart';

class CLCData {
  CLCData({required this.day, required this.amount});
  final int day;
  final double amount;
}

class CustomLineChart extends StatefulWidget {
  const CustomLineChart({
    super.key,
    required this.currentMonthView,
    required this.values,
  });
  final List<CLCData> values;
  final DateTime currentMonthView;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late double _lowestAmount;
  late double _highestAmount;

  void findLowestAndHighestAmount() {
    double lowTemp = double.infinity;
    double highTemp = double.negativeInfinity;
    for (CLCData data in widget.values) {
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
    if (widget.values != oldWidget.values) {
      setState(() {
        findLowestAndHighestAmount();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    bool isShowTitle = widget.values.map((e) => e.day).contains(value.toInt());

    return isShowTitle
        ? Transform.translate(
            offset: const Offset(0, -40),
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

  List<LineTooltipItem> _lineTooltipItem(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      return LineTooltipItem(
        '${context.currentSettings.currency.symbol} ${CalService.formatCurrency(context, touchedSpot.y)} \n',
        kHeader2TextStyle.copyWith(
          color: context.appTheme.isDarkTheme
              ? context.appTheme.onBackground
              : context.appTheme.onSecondary,
          fontSize: 13,
        ),
        textAlign: TextAlign.right,
        children: [
          TextSpan(
            text: widget.currentMonthView
                .copyWith(day: touchedSpot.x.toInt())
                .getFormattedDate(hasYear: false, type: DateTimeType.ddmmmyyyy),
            style: kHeader3TextStyle.copyWith(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.onBackground
                  : context.appTheme.onSecondary,
              fontSize: 11,
            ),
          ),
        ],
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
          color: context.appTheme.accent1.addDark(0.1),
          strokeColor: Colors.transparent,
        ),
      );

      return TouchedSpotIndicatorData(flLine, dotData);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        getTooltipItems: _lineTooltipItem,
      ),
      getTouchedSpotIndicator: _touchedIndicators,
    );

    final lineChartBarData = [
      LineChartBarData(
        spots: widget.values.map((e) => FlSpot(e.day.toDouble(), e.amount)).toList(),
        isCurved: true,
        isStrokeCapRound: true,
        barWidth: 4.5,
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
      offset: const Offset(0, 32),
      child: LineChart(
        LineChartData(
          maxY: _highestAmount,
          minY: _lowestAmount - _highestAmount / 3,
          minX: 1,
          maxX: widget.values.last.day.toDouble(),
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
          lineTouchData: lineTouchData,
          lineBarsData: lineChartBarData,
        ),
      ),
    );
  }
}
