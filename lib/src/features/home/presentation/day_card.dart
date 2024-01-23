import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/transactions_list.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/txn_components.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../transactions/domain/transaction_base.dart';

class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.dateTime,
    required this.transactions,
    this.onTransactionTap,
  });

  final DateTime dateTime;
  final List<BaseTransaction> transactions;
  final Function(BaseTransaction)? onTransactionTap;

  double get _calculateCashFlow {
    double cashFlow = 0;
    for (BaseTransaction transaction in transactions) {
      if (transaction is Income) {
        cashFlow += transaction.amount;
      }
      if (transaction is Expense) {
        cashFlow -= transaction.amount;
      }
    }
    return cashFlow;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().onlyYearMonthDay;

    return CardItem(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: dateTime.weekday == 6 || dateTime.weekday == 7
                        ? context.appTheme.negative.withOpacity(0.7)
                        : AppColors.greyBgr(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    NumberFormat('00').format(dateTime.day),
                    style: kHeader1TextStyle.copyWith(
                      fontSize: 20,
                      color: dateTime.weekday == 6 || dateTime.weekday == 7
                          ? context.appTheme.onNegative
                          : context.appTheme.onBackground,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Gap.w8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dateTime.weekdayString(),
                          style: kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Gap.w8,
                        dateTime.onlyYearMonthDay.isAtSameMomentAs(today)
                            ? TxnInfo('Today'.hardcoded, color: context.appTheme.accent2)
                            : Gap.noGap,
                      ],
                    ),
                    Gap.h2,
                    Text(
                      dateTime.getFormattedDate(format: DateTimeFormat.ddmmmmyyyy, hasDay: false),
                      style:
                          kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Gap.expanded,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cash flow',
                      style: kHeader4TextStyle.copyWith(
                          color: context.appTheme.onBackground.withOpacity(0.5), fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          CalService.formatCurrency(context, _calculateCashFlow.abs()),
                          style: kHeader1TextStyle.copyWith(
                              color: _calculateCashFlow > 0
                                  ? context.appTheme.positive
                                  : _calculateCashFlow < 0
                                      ? context.appTheme.negative
                                      : context.appTheme.onBackground,
                              fontSize: 15),
                        ),
                        Gap.w4,
                        Text(
                          context.appSettings.currency.code,
                          style: kHeader4TextStyle.copyWith(
                              color: _calculateCashFlow > 0
                                  ? context.appTheme.positive
                                  : _calculateCashFlow < 0
                                      ? context.appTheme.negative
                                      : context.appTheme.onBackground,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Gap.divider(context),
          TransactionsList(
            transactions: transactions,
            currencyCode: context.appSettings.currency.code,
            onTransactionTap: onTransactionTap,
          ),
        ],
      ),
    );
  }
}
