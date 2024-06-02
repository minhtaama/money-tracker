import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    final chartServices = ref.watch(customLineChartServicesProvider);

    final dataList = accountRepo
        .getList(AccountType.regular)
        .whereType<RegularAccount>()
        .map((account) => chartServices.getCLCDataForReportScreenOnRegularAccount(
              account,
              widget.dateTimes.first,
              widget.dateTimes.last,
            ))
        .toList();

    return ReportWrapper(
      title: 'Assets'.hardcoded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dataList
            .map(
              (clcData) => SizedBox(
                height: 210,
                child: CustomLineChart2(
                  data: clcData,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
