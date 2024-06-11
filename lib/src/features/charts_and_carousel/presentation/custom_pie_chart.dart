import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/colors.dart';

class CustomPieChart<T extends BaseModelWithIcon> extends StatefulWidget {
  const CustomPieChart({
    super.key,
    required this.values,
    this.onChartTap,
    this.center,
    this.touchedIndex,
  });

  final List<MapEntry<T, double>> values;
  final Function(int)? onChartTap;
  final Widget? center;

  /// -2 means low opacity all
  ///
  /// If this property is specified, will disable the default pie touch setting
  final int? touchedIndex;

  @override
  State<CustomPieChart<T>> createState() => _CustomPieChartState<T>();
}

class _CustomPieChartState<T extends BaseModelWithIcon> extends State<CustomPieChart<T>> {
  double _startDegreeOffset = -90;
  double _scale = 0.3;
  double _opacity = 0;

  late int _touchedIndex = widget.touchedIndex ?? -1;

  late List<MapEntry<T, double>> _dataList = widget.values;

  @override
  void didUpdateWidget(covariant CustomPieChart<T> oldWidget) {
    if (widget.values != oldWidget.values && mounted) {
      setState(() {
        _dataList = widget.values;
      });
    }

    if (widget.touchedIndex != oldWidget.touchedIndex && widget.touchedIndex != null) {
      setState(() {
        _touchedIndex = widget.touchedIndex!;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

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
    if (_dataList.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: context.appTheme.onBackground.withOpacity(0.08),
          showTitle: false,
          radius: 28,
        ),
        PieChartSectionData(
          value: 1,
          color: context.appTheme.onBackground.withOpacity(0.08),
          showTitle: false,
          radius: 28,
        ),
      ];
    }

    return _dataList
        .map(
          (e) => PieChartSectionData(
            value: e.value,
            color: e.key.backgroundColor.withOpacity(
              touchedIndex == -1 || _dataList.indexOf(e) == touchedIndex ? 1 : 0.0,
            ),
            borderSide: BorderSide(
                color: e.key.backgroundColor.withOpacity(
              touchedIndex == -1 || _dataList.indexOf(e) == touchedIndex ? 1 : 0.5,
            )),
            showTitle: false,
            badgePositionPercentageOffset: 0.8,
            radius: 28,
            badgeWidget: AnimatedOpacity(
              duration: k150msDuration,
              curve: Curves.easeOut,
              opacity: touchedIndex == -1 || _dataList.indexOf(e) == touchedIndex ? 1 : 0,
              child: Container(
                height: 28,
                width: 28,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: e.key.backgroundColor,
                  borderRadius: BorderRadius.circular(1000),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.55),
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
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: AnimatedScale(
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
                  centerSpaceColor: Colors.transparent,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                      if (widget.values.isNotEmpty && widget.onChartTap != null) {
                        if (event.isInterestedForInteractions && pieTouchResponse != null && event is FlTapDownEvent) {
                          if (widget.touchedIndex == null) {
                            if (pieTouchResponse.touchedSection!.touchedSectionIndex == _touchedIndex) {
                              setState(() {
                                _touchedIndex = -1;
                              });
                            } else {
                              setState(() {
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            }
                            widget.onChartTap?.call(_touchedIndex);
                          } else {
                            widget.onChartTap?.call(pieTouchResponse.touchedSection!.touchedSectionIndex);
                          }
                        }
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
      ),
    );
  }
}
