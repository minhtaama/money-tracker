import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_line_chart.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../common_widgets/custom_inkwell.dart';
import '../../../common_widgets/modal_and_dialog.dart';
import '../../../common_widgets/money_amount.dart';
import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../charts_and_carousel/application/custom_line_chart_services.dart';
import '../../charts_and_carousel/application/custom_pie_chart_services.dart';
import '../../charts_and_carousel/presentation/custom_pie_chart.dart';

class AccountsReportWidget extends ConsumerStatefulWidget {
  const AccountsReportWidget({super.key, required this.dateTimes});

  final List<DateTime> dateTimes;

  @override
  ConsumerState<AccountsReportWidget> createState() => _AssetReportWidgetState();
}

class _AssetReportWidgetState extends ConsumerState<AccountsReportWidget> {
  // int _touchedIndexExpense = -1;

  Widget _accountLabel(RegularAccount account) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            color: account.backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Gap.w4,
        Text(
          account.name,
          style: kHeader4TextStyle.copyWith(
            color: context.appTheme.onBackground,
            fontSize: 12,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    final chartServices = ref.watch(customLineChartServicesProvider);

    final accountList = accountRepo.getList(AccountType.regular).whereType<RegularAccount>().toList();

    return ReportWrapperSwitcher(
      title: 'Assets'.hardcoded,
      firstChild: SizedBox(
        height: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, 12),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 60),
                child: Wrap(
                  runSpacing: 4,
                  spacing: 8,
                  children: accountList.map((e) => _accountLabel(e)).toList(),
                ),
              ),
            ),
            Expanded(
              child: CustomLineChart2(
                data: chartServices.getCLCDataForReportScreenOnRegularAccount(
                  accountList,
                  widget.dateTimes.first,
                  widget.dateTimes.last,
                ),
              ),
            ),
          ],
        ),
      ),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: accountList
            .map(
              (account) => SizedBox(
                height: 230,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgIcon(
                            account.iconPath,
                            color: context.appTheme.onBackground,
                            size: 20,
                          ),
                          Gap.w4,
                          Flexible(
                            child: Text(
                              account.name,
                              style: kHeader3TextStyle.copyWith(
                                color: context.appTheme.onBackground,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Gap.w8,
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomLineChart2(
                        data: chartServices.getCLCDataForReportScreenOnRegularAccount(
                          [account],
                          widget.dateTimes.first,
                          widget.dateTimes.last,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
