import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_pie_chart_services.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class CustomPieChart extends ConsumerWidget {
  const CustomPieChart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(customPieChartServicesProvider);
    final value = service.getExpenseData(Calendar.minDate, Calendar.maxDate);

    return PieChart(
      PieChartData(
        sections: value,
      ),
      swapAnimationDuration: k550msDuration,
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}
