import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/transactions_list.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../transactions/domain/transaction.dart';

class DayCard extends ConsumerWidget {
  const DayCard({
    Key? key,
    required this.dateTime,
    required this.transactions,
    this.onTransactionTap,
  }) : super(key: key);

  final DateTime dateTime;
  final List<Transaction> transactions;
  final Function(Transaction)? onTransactionTap;

  double get _calculateCashFlow {
    double cashFlow = 0;
    for (Transaction transaction in transactions) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsRepo = ref.watch(settingsControllerProvider);

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
                        ? context.appTheme.accent
                        : AppColors.greyBgr(context),
                    borderRadius: BorderRadius.circular(8),
                    border: dateTime.year == DateTime.now().year &&
                            dateTime.month == DateTime.now().month &&
                            dateTime.day == DateTime.now().day
                        ? Border.all(color: context.appTheme.backgroundNegative)
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    dateTime.day.toString(),
                    style: kHeader1TextStyle.copyWith(
                      fontSize: 20,
                      color: dateTime.weekday == 6 || dateTime.weekday == 7
                          ? context.appTheme.accentNegative
                          : context.appTheme.backgroundNegative,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Gap.w8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTime.weekdayString(),
                      style: kHeader3TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      dateTime.getFormattedDate(type: DateTimeType.ddmmmmyyyy, hasDay: false),
                      style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 11),
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
                          color: context.appTheme.backgroundNegative.withOpacity(0.5), fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          CalService.formatCurrency(_calculateCashFlow.abs()),
                          style: kHeader1TextStyle.copyWith(
                              color: _calculateCashFlow > 0
                                  ? context.appTheme.positive
                                  : _calculateCashFlow < 0
                                      ? context.appTheme.negative
                                      : context.appTheme.backgroundNegative,
                              fontSize: 15),
                        ),
                        Gap.w4,
                        Text(
                          settingsRepo.currency.code,
                          style: kHeader4TextStyle.copyWith(
                              color: _calculateCashFlow > 0
                                  ? context.appTheme.positive
                                  : _calculateCashFlow < 0
                                      ? context.appTheme.negative
                                      : context.appTheme.backgroundNegative,
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
            currencyCode: settingsRepo.currency.code,
            onTransactionTap: onTransactionTap,
          ),
        ],
      ),
    );
  }
}
