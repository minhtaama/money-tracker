import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_bar_chart_services.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_bar_chart.dart';

class WeeklyBarChartWidget extends ConsumerStatefulWidget {
  const WeeklyBarChartWidget({super.key});

  @override
  ConsumerState<WeeklyBarChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends ConsumerState<WeeklyBarChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final barServices = ref.watch(customBarChartServicesProvider);
    final map = barServices.getWeeklyReportData(DateTime.now());

    return SizedBox(
      height: 160,
      child: CustomBarChart(
        values: map,
      ),
    );
  }
}
