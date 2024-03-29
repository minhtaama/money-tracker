import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/credit/edit_modal.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../../common_widgets/modal_and_dialog.dart';
import '../../../../../../common_widgets/rounded_icon_button.dart';
import '../../../../../charts_and_carousel/application/custom_line_chart_services.dart';
import '../../../../../charts_and_carousel/presentation/custom_line_chart.dart';
import '../../../../../transactions/data/transaction_repo.dart';
import '../../../../domain/account_base.dart';

class ExtendedCreditAccountTab extends ConsumerWidget {
  const ExtendedCreditAccountTab({
    super.key,
    required this.account,
    required this.displayDate,
  });
  final CreditAccount account;
  final DateTime displayDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartServices = ref.watch(customLineChartServicesProvider);

    CLCData data = chartServices.getCreditCLCData(account, displayDate);

    ref.listen(transactionsChangesStreamProvider, (_, __) {
      data = chartServices.getCreditCLCData(account, displayDate);
    });

    final extraLineY = (data as CLCDataForCredit).extraLineY;
    final extraLineText =
        'Payment required: ${CalService.formatCurrency(context, (data as CLCDataForCredit).balanceRemaining)} ${context.appSettings.currency.code}'
            .hardcoded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(account: account),
        Gap.h16,
        Expanded(
          child: CustomLineChart(
            currentMonth: displayDate,
            color: account.iconColor,
            todayDotColor: account.backgroundColor,
            data: data,
            offsetLabelUp: 47,
            isForCredit: true,
            extraLineY: extraLineY,
            extraLineText: extraLineText,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, required this.account});

  final CreditAccount account;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedIconButton(
            onTap: () => context.pop(),
            backgroundColor: Colors.transparent,
            iconColor: account.iconColor,
            iconPath: AppIcons.back,
          ),
          Gap.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: kHeader2TextStyle.copyWith(
                    color: account.iconColor,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'Credit account'.hardcoded,
                  style: kHeader3TextStyle.copyWith(
                    color: account.iconColor,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          RoundedIconButton(
            onTap: () => showCustomModalBottomSheet(
              context: context,
              child: EditCreditAccountModalScreen(account),
            ),
            backgroundColor: Colors.transparent,
            iconColor: account.iconColor,
            iconPath: AppIcons.edit,
          ),
        ],
      ),
    );
  }
}
