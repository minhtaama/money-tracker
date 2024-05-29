import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'dart:math' as math;

import '../../../theme_and_ui/icons.dart';
import '../../charts_and_carousel/application/custom_bar_chart_services.dart';
import '../../charts_and_carousel/presentation/custom_bar_chart.dart';

class DailyReportWidget extends ConsumerStatefulWidget {
  const DailyReportWidget({super.key, required this.dateTimes});

  final List<DateTime> dateTimes;

  @override
  ConsumerState<DailyReportWidget> createState() => _DailyReportWidgetState();
}

class _DailyReportWidgetState extends ConsumerState<DailyReportWidget> {
  @override
  Widget build(BuildContext context) {
    final range = DateTimeRange(start: widget.dateTimes.first, end: widget.dateTimes.last);

    final barServices = ref.watch(customBarChartServicesProvider);

    final map = barServices.getReportData(range);

    final days = range.toList();

    return ReportWrapper(
      title: 'Daily Report'.hardcoded,
      collapsable: true,
      childHeight: days.length * 30 + 20,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
        child: CustomBarChart(
          horizontalChart: true,
          values: map,
          barRodWidth: 7,
          titleDateTimes: days,
          titleBuilder: (dateTime) => dateTime.toShortDate(context, noYear: true),
          titleReservedSize: 30,
          titleAngle: math.pi / 4,
          titleSize: 10,
          titleOffset: const Offset(-10, 5),
        ),
      ),
    );
  }
}
