import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'dart:math' as math;

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
          tooltipBuilder: (index) {
            final value = map.entries.toList()[index].value;
            final dateTime = days[index];

            return IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.appTheme.primary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTime.toLongDate(context),
                      style: kHeader2TextStyle.copyWith(color: context.appTheme.onPrimary, fontSize: 12),
                    ),
                    Gap.h4,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.loc.expense,
                                style: kHeader3TextStyle.copyWith(
                                    color: context.appTheme.onPrimary.withOpacity(0.65), fontSize: 12),
                              ),
                              MoneyAmount(
                                amount: value.spending,
                                style: kHeader2TextStyle.copyWith(color: context.appTheme.onPrimary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.loc.income,
                                style: kHeader3TextStyle.copyWith(
                                    color: context.appTheme.onPrimary.withOpacity(0.65), fontSize: 12),
                              ),
                              MoneyAmount(
                                amount: value.income,
                                style: kHeader2TextStyle.copyWith(color: context.appTheme.onPrimary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
