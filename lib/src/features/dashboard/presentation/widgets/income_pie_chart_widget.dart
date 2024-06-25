import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_pie_chart_services.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_pie_chart.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/money_amount.dart';
import '../../../../utils/constants.dart';

class IncomePieChartWidget extends ConsumerStatefulWidget {
  const IncomePieChartWidget({super.key});

  @override
  ConsumerState<IncomePieChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends ConsumerState<IncomePieChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final pieServices = ref.watch(customPieChartServicesProvider);
    final list = pieServices.getIncomeData(context, dateTime: DateTime.now());
    final totalAmount = pieServices.getIncomeAmount(DateTime.now());

    List<Widget> labels(int index) {
      if (list.isEmpty) {
        return [
          Text(
            'No income this month'.hardcoded,
            style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.65)),
          ),
        ];
      }

      return list
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: SizedBox(
                height: 15,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'WixMadeforDisplay',
                          color: context.appTheme.onBackground,
                          fontSize: list.indexOf(e) == index ? 13 : 12,
                          fontWeight: list.indexOf(e) == index ? FontWeight.w900 : FontWeight.w100,
                        ),
                        duration: k250msDuration,
                        child: Text(
                          e.key.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList();
    }

    return DashboardWidget(
      title: 'Monthly income'.hardcoded,
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomPieChart<Category>(
                values: list,
                center: SvgIcon(
                  AppIcons.downloadLight,
                  color: context.appTheme.positive.withOpacity(0.65),
                  size: 25,
                ),
                onChartTap: (index) {
                  setState(() {
                    _touchedIndex = index;
                  });
                },
              ),
            ),
            Gap.w16,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: labels(_touchedIndex),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _touchedIndex == -1 ? 1 : 0,
                      duration: k250msDuration,
                      child: Text(
                        'TOTAL:',
                        style: kHeader1TextStyle.copyWith(
                            fontSize: 10, color: context.appTheme.onBackground.withOpacity(0.65)),
                      ),
                    ),
                    MoneyAmount(
                      amount: _touchedIndex == -1 ? totalAmount : list[_touchedIndex].value,
                      style:
                          kHeader1TextStyle.copyWith(color: context.appTheme.negative.withOpacity(0.8), fontSize: 23),
                      symbolStyle:
                          kHeader3TextStyle.copyWith(color: context.appTheme.negative.withOpacity(0.8), fontSize: 20),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    ),
                    Gap.h8,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
