import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_bar_chart_services.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_bar_chart.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/money_amount.dart';
import '../../../../utils/constants.dart';

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
        height: 180,
        child: CustomBarChart(
          values: map,
          titleDateTimes: weekDays,
          titleBuilder: (dateTime) => dateTime.weekdayToString(context, short: true),
          tooltipBuilder: (index) {
            final value = map.entries.toList()[index].value;
            final dateTime = weekDays[index];

            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.appTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dateTime.weekdayToString(context)}, ${dateTime.toLongDate(context)}',
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
            );
          },
        ),
      ),
    );
  }
}
