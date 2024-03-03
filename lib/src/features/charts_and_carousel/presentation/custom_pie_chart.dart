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
  });

  final Map<BaseModelWithIcon, double> values;

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  double _startDegreeOffset = 0;
  double _scale = 0.3;

  int _touchedIndex = -1;

  @override
  void didChangeDependencies() {
    Future.delayed(
        k1msDuration,
        () => setState(() {
              _startDegreeOffset = -90;
              _scale = 1;
            }));
    super.didChangeDependencies();
  }

  List<PieChartSectionData> getData(int touchedIndex) {
    final dataList = widget.values.entries.toList();

    return dataList
        .map(
          (e) => PieChartSectionData(
            value: e.value,
            color: e.key.backgroundColor.withOpacity(0.9),
            showTitle: false,
            badgePositionPercentageOffset: 1,
            radius: dataList.indexOf(e) == touchedIndex ? 40 : 30,
            badgeWidget: AnimatedContainer(
              duration: k550msDuration,
              curve: Curves.fastOutSlowIn,
              height: dataList.indexOf(e) == touchedIndex ? 35 : 28,
              width: dataList.indexOf(e) == touchedIndex ? 35 : 28,
              padding: EdgeInsets.all(dataList.indexOf(e) == touchedIndex ? 6 : 5),
              decoration: BoxDecoration(
                color: context.appTheme.background0,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: [
                  BoxShadow(
                    color: context.appTheme.onBackground.withOpacity(0.2),
                    blurRadius: 5,
                  )
                ],
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SvgIcon(
                  e.key.iconPath,
                  color: context.appTheme.onBackground,
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
      duration: k550msDuration,
      curve: Curves.fastOutSlowIn,
      scale: _scale,
      child: PieChart(
        PieChartData(
          sections: getData(_touchedIndex),
          sectionsSpace: 0,
          startDegreeOffset: _startDegreeOffset,
          centerSpaceRadius: 40,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                // if (!event.isInterestedForInteractions ||
                //     pieTouchResponse == null ||
                //     pieTouchResponse.touchedSection == null) {
                //   _touchedIndex = -1;
                //   return;
                // }
                if (event.isInterestedForInteractions && pieTouchResponse != null && event is FlTapDownEvent) {
                  if (pieTouchResponse.touchedSection!.touchedSectionIndex == _touchedIndex) {
                    _touchedIndex = -1;
                  } else {
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  }
                }
              });
            },
          ),
        ),
        swapAnimationDuration: k550msDuration,
        swapAnimationCurve: Curves.fastOutSlowIn,
      ),
    );
  }
}
