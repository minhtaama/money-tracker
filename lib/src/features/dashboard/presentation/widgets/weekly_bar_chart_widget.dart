import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_bar_chart_services.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_bar_chart.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

class WeeklyBarChartWidget extends ConsumerStatefulWidget {
  const WeeklyBarChartWidget({super.key});

  @override
  ConsumerState<WeeklyBarChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends ConsumerState<WeeklyBarChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final barServices = ref.watch(customBarChartServicesProvider);
    final map = barServices.getWeeklyReportData(context, today);

    final weekDays = today.weekRange(context).toList();

    return DashboardWidget(
      title: 'Weekly report'.hardcoded,
      child: SizedBox(
        height: 160,
        child: CustomBarChart(
          values: map,
          titleDateTimes: weekDays,
          titleBuilder: (dateTime) => dateTime.weekdayToString(context, short: true),
        ),
      ),
    );
  }
}
