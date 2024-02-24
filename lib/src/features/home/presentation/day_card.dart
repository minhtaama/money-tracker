import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/home_transactions_list.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
            child: Row(
              children: [
                Gap.w4,
                Text(
                  NumberFormat('00').format(dateTime.day),
                  style: kHeader1TextStyle.copyWith(
                    fontSize: 23,
                    color: context.appTheme.onBackground,
                  ),
                  textAlign: TextAlign.left,
                ),
                Gap.w8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTime.weekdayString(),
                      style: kHeader3TextStyle.copyWith(
                        color: dateTime.weekday == 6 || dateTime.weekday == 7
                            ? context.appTheme.negative
                            : context.appTheme.onBackground,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      dateTime.getFormattedDate(format: DateTimeFormat.ddmmyyyy, hasDay: false),
                      style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 10),
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
          Gap.divider(context, indent: 10),
          HomeTransactionsList(
            transactions: transactions,
            currencyCode: context.appSettings.currency.code,
            onTransactionTap: onTransactionTap,
          ),
        ],
      ),
    );
  }
}
