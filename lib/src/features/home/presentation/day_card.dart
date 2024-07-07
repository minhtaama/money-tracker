import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/recurrence/domain/recurrence.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/day_card_transactions_list.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
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

    return Column(
      children: [
        CardItem(
          margin: EdgeInsets.only(
              left: forModal ? 0 : 8, right: forModal ? 0 : 8, top: forModal ? 4 : 6, bottom: forModal ? 4 : 0),
          //margin: EdgeInsets.symmetric(horizontal: forModal ? 0 : 8, vertical: forModal ? 4 : 6),
          border: forModal && context.appTheme.isDarkTheme ? Border.all(color: AppColors.greyBorder(context)) : null,
          borderRadius: BorderRadius.only(
            topRight: const Radius.circular(8),
            topLeft: const Radius.circular(8),
            bottomLeft: Radius.circular(plannedTransactions.isEmpty ? 8 : 0),
            bottomRight: Radius.circular(plannedTransactions.isEmpty ? 8 : 0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    CardItem(
                      margin: EdgeInsets.zero,
                      padding: dateTime.isSameDayAs(today)
                          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                          : EdgeInsets.zero,
                      border: Border.all(
                        color: context.appTheme.onBackground.withOpacity(dateTime.isSameDayAs(today) ? 0.65 : 0),
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
              transactions.isNotEmpty
                  ? Gap.divider(context, indent: 0, color: context.appTheme.background1, thickness: 1)
                  : Gap.noGap,
              DayCardTransactionsList(
                transactions: transactions,
                onTransactionTap: onTransactionTap,
              ),
            ],
          ),
        ),
        HideableContainer(
          hide: plannedTransactions.isEmpty,
          initialAnimation: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 6),
            child: ClipRect(
              child: Stack(
                children: [
                  CardItem(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    border: forModal && context.appTheme.isDarkTheme
                        ? Border.all(color: AppColors.greyBorder(context))
                        : null,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(0),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: DayCardPlannedTransactionsList(
                      plannedTransactions: plannedTransactions,
                      onPlannedTransactionTap: onPlannedTransactionTap,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(-10, -5),
                      child: SvgIcon(
                        AppIcons.bookmarkBulk,
                        color: context.appTheme.accent1,
                        size: 23,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
