import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/svg_icon.dart';

class CustomPieChart extends StatefulWidget {
  const CustomPieChart({
    super.key,
    required this.values,
    this.onChartTap,
    this.center,
  });

  final Map<BaseModelWithIcon, double> values;
  final Function(int)? onChartTap;
  final Widget? center;

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  double _startDegreeOffset = -90;
  double _scale = 0.3;
  double _opacity = 0;

  int _touchedIndex = -1;

  @override
  void didChangeDependencies() {
    Future.delayed(k1msDuration, () {
      if (mounted) {
        setState(() {
          _startDegreeOffset = -270;
          _scale = 1;
          _opacity = 1;
        });
      }
    });
    super.didChangeDependencies();
  }

  List<PieChartSectionData> getData(int touchedIndex, BuildContext context) {
    final dataList = widget.values.entries.toList()..sort((a, b) => (b.value - a.value).toInt());

    if (dataList.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: context.appTheme.onBackground.withOpacity(0.08),
          showTitle: false,
          radius: 33,
        ),
      ];
    }

    if (dataList.length - 1 >= 5) {
      final sumAll = dataList.map((e) => e.value).reduce((value, element) => value + element);
      double sumOfSmallest = 0;
      int i = dataList.length - 1;
      while (i >= 3) {
        final entry = dataList[i];

        sumOfSmallest += entry.value;

        if (sumOfSmallest >= sumAll * 0.15) {
          break;
        }

        i--;
      }

      if (i < dataList.length - 1) {
        final others = dataList.sublist(i, dataList.length).reduce(
            (value, element) => MapEntry(GeneralOtherModel(context), value.value + element.value));

        dataList.replaceRange(i, dataList.length, [others]);
      }

      //TODO: Don't know if this works
    }

    return dataList
        .map(
          (e) => PieChartSectionData(
            value: e.value,
            color: e.key.backgroundColor.withOpacity(0.8),
            showTitle: false,
            badgePositionPercentageOffset: 1,
            radius: dataList.indexOf(e) == touchedIndex ? 41 : 33,
            badgeWidget: AnimatedContainer(
              duration: k350msDuration,
              curve: Curves.fastOutSlowIn,
              height: dataList.indexOf(e) == touchedIndex ? 35 : 28,
              width: dataList.indexOf(e) == touchedIndex ? 35 : 28,
              padding: EdgeInsets.all(dataList.indexOf(e) == touchedIndex ? 6 : 5),
              decoration: BoxDecoration(
                color: e.key.backgroundColor,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: [
                  BoxShadow(
                    color: context.appTheme.background0.withOpacity(0.55),
                    blurRadius: 3,
                  )
                ],
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SvgIcon(
                  e.key.iconPath,
                  color: e.key.iconColor,
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: k350msDuration,
      curve: Curves.fastOutSlowIn,
      scale: _scale,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: k350msDuration,
        curve: Curves.fastOutSlowIn,
        child: Stack(
          alignment: Alignment.center,
          children: [
            widget.center ?? Gap.noGap,
            PieChart(
              PieChartData(
                sections: getData(_touchedIndex, context),
                sectionsSpace: 2,
                startDegreeOffset: _startDegreeOffset,
                centerSpaceRadius: 35,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    if (widget.values.entries.isNotEmpty) {
                      setState(() {
                        // if (!event.isInterestedForInteractions ||
                        //     pieTouchResponse == null ||
                        //     pieTouchResponse.touchedSection == null) {
                        //   _touchedIndex = -1;
                        //   return;
                        // }
                        if (event.isInterestedForInteractions &&
                            pieTouchResponse != null &&
                            event is FlTapDownEvent) {
                          if (pieTouchResponse.touchedSection!.touchedSectionIndex == _touchedIndex) {
                            _touchedIndex = -1;
                          } else {
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          }
                          widget.onChartTap?.call(_touchedIndex);
                        }
                      });
                    }
                  },
                ),
              ),
              swapAnimationDuration: k350msDuration,
              swapAnimationCurve: Curves.fastOutSlowIn,
            ),
          ],
        ),
      ),
    );
  }
}
