import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/colors.dart';

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
    Future.delayed(
        k1msDuration,
        () => setState(() {
              _startDegreeOffset = -270;
              _scale = 1;
              _opacity = 1;
            }));
    super.didChangeDependencies();
  }

  List<PieChartSectionData> getData(int touchedIndex) {
    final dataList = widget.values.entries.toList();

    return dataList
        .map(
          (e) => PieChartSectionData(
            value: e.value,
            color: e.key.backgroundColor.withOpacity(0.95),
            showTitle: false,
            badgePositionPercentageOffset: 1,
            radius: dataList.indexOf(e) == touchedIndex ? 41 : 33,
            badgeWidget: AnimatedContainer(
              duration: k550msDuration,
              curve: Curves.fastOutSlowIn,
              height: dataList.indexOf(e) == touchedIndex ? 35 : 28,
              width: dataList.indexOf(e) == touchedIndex ? 35 : 28,
              padding: EdgeInsets.all(dataList.indexOf(e) == touchedIndex ? 6 : 5),
              decoration: BoxDecoration(
                color: e.key.backgroundColor,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.45),
                    blurRadius: 6,
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
      duration: k550msDuration,
      curve: Curves.fastOutSlowIn,
      scale: _scale,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: k550msDuration,
        curve: Curves.fastOutSlowIn,
        child: Stack(
          alignment: Alignment.center,
          children: [
            widget.center ?? Gap.noGap,
            PieChart(
              PieChartData(
                sections: getData(_touchedIndex),
                sectionsSpace: 0,
                startDegreeOffset: _startDegreeOffset,
                centerSpaceRadius: 35,
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
                        widget.onChartTap?.call(_touchedIndex);
                      }
                    });
                  },
                ),
              ),
              swapAnimationDuration: k550msDuration,
              swapAnimationCurve: Curves.fastOutSlowIn,
            ),
          ],
        ),
      ),
    );
  }
}
