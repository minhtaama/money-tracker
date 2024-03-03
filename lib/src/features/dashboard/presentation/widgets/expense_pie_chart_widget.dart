import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_pie_chart_services.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_pie_chart.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../../utils/constants.dart';

class ExpensePieChartWidget extends ConsumerWidget {
  const ExpensePieChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieServices = ref.watch(customPieChartServicesProvider);
    final values = pieServices.getMonthlyExpenseData(DateTime.now(), context);

    List<Widget> label() {
      return values.entries
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: e.key.backgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Gap.w4,
                    Text(
                      e.key.name,
                      style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 12),
                    ),
                  ],
                ),
              ))
          .toList();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          width: 170,
          child: CustomPieChart(
            values: values,
          ),
        ),
        Gap.w24,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: label(),
            ),
          ),
        ),
      ],
    );
  }
}
