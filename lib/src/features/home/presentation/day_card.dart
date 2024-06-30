import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/recurrence/domain/recurrence.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/day_card_transactions_list.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../transactions/domain/transaction_base.dart';
import '../../transactions/presentation/components/day_card_planned_transactions_list.dart';

class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.dateTime,
    required this.transactions,
    this.onTransactionTap,
    required this.plannedTransactions,
    this.onPlannedTransactionTap,
    this.forModal = false,
  });

  final DateTime dateTime;
  final List<BaseTransaction> transactions;
  final List<TransactionData> plannedTransactions;
  final Function(BaseTransaction)? onTransactionTap;
  final Function(TransactionData)? onPlannedTransactionTap;

  final bool forModal;

  double get _calculateCashFlow {
    double cashFlow = 0;
    for (BaseTransaction transaction in transactions) {
      if (transaction is Income) {
        cashFlow += transaction.amount;
      }
      if (transaction is Expense || transaction is CreditPayment) {
        cashFlow -= transaction.amount;
      }
    }
    return cashFlow;
  }

  String get _symbol {
    if (_calculateCashFlow > 0) {
      return '+';
    }
    if (_calculateCashFlow < 0) {
      return '-';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().onlyYearMonthDay;

    return CardItem(
      margin: EdgeInsets.symmetric(horizontal: forModal ? 0 : 8, vertical: forModal ? 4 : 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      border: forModal && context.appTheme.isDarkTheme
          ? Border.all(color: AppColors.greyBorder(context))
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
            child: Row(
              children: [
                Gap.w4,
                CardItem(
                  margin: EdgeInsets.zero,
                  padding: dateTime.isSameDayAs(today)
                      ? const EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                      : EdgeInsets.zero,
                  border: Border.all(
                    color: context.appTheme.onBackground
                        .withOpacity(dateTime.isSameDayAs(today) ? 0.65 : 0),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  child: Text(
                    NumberFormat('00').format(dateTime.day),
                    style: kHeader1TextStyle.copyWith(
                      fontSize: dateTime.isSameDayAs(today) ? 19 : 23,
                      color: context.appTheme.onBackground,
                      height: 0.99,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Gap.w8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTime.weekdayToString(context),
                      style: kHeader3TextStyle.copyWith(
                        color: dateTime.weekday == 6 || dateTime.weekday == 7
                            ? context.appTheme.negative
                            : context.appTheme.onBackground,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      dateTime.toLongDate(context, noDay: true),
                      style:
                          kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 10),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Gap.expanded,
                Text(
                  '$_symbol${CalService.formatCurrency(context, _calculateCashFlow.abs())}',
                  style: kHeader3TextStyle.copyWith(
                      color: _calculateCashFlow > 0
                          ? context.appTheme.positive
                          : _calculateCashFlow < 0
                              ? context.appTheme.negative
                              : context.appTheme.onBackground,
                      fontSize: 13),
                )
              ],
            ),
          ),
          transactions.isNotEmpty ? Gap.divider(context, indent: 10) : Gap.noGap,
          DayCardTransactionsList(
            transactions: transactions,
            onTransactionTap: onTransactionTap,
          ),
          plannedTransactions.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Gap.divider(context, indent: 0),
                      ),
                      Gap.w8,
                      Text(
                        context.loc.plannedTransactions,
                        style: kHeader4TextStyle.copyWith(
                          color: context.appTheme.onBackground.withOpacity(0.65),
                          fontSize: 12,
                        ),
                      ),
                      Gap.w12,
                    ],
                  ),
                )
              : Gap.noGap,
          DayCardPlannedTransactionsList(
            plannedTransactions: plannedTransactions,
            onPlannedTransactionTap: onPlannedTransactionTap,
          ),
        ],
      ),
    );
  }
}
