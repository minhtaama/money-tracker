import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class DayCard extends ConsumerWidget {
  const DayCard({
    Key? key,
    required this.dateTime,
    required this.transactions,
  }) : super(key: key);

  final DateTime dateTime;
  final List<TransactionIsar> transactions;

  double get _calculateCashFlow {
    double cashFlow = 0;
    for (TransactionIsar transaction in transactions) {
      if (transaction.transactionType == TransactionType.income) {
        cashFlow += transaction.amount;
      } else if (transaction.transactionType == TransactionType.expense) {
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
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: dateTime.weekday == 6 || dateTime.weekday == 7
                        ? context.appTheme.accent
                        : context.appTheme.backgroundNegative,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    dateTime.day.toString(),
                    style: kHeader1TextStyle.copyWith(
                      fontSize: 20,
                      color: dateTime.weekday == 6 || dateTime.weekday == 7
                          ? context.appTheme.accentNegative
                          : context.appTheme.background,
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
                          color: dateTime.weekday == 6 || dateTime.weekday == 7
                              ? context.appTheme.accent.addDark(0.1)
                              : context.appTheme.backgroundNegative,
                          fontSize: 15),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${dateTime.monthString()} ${dateTime.year}',
                      style: kHeader4TextStyle.copyWith(
                          color: context.appTheme.backgroundNegative, fontSize: 11),
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
                          CalculatorService.formatCurrency(_calculateCashFlow.abs()),
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
                              color: true
                                  ? context.appTheme.positive
                                  : false
                                      ? context.appTheme.negative
                                      : AppColors.darkerGrey,
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
          DayCardTransactions(
            transactions: transactions,
            currencyCode: settingsRepo.currency.code,
          ),
        ],
      ),
    );
  }
}

class DayCardTransactions extends StatelessWidget {
  const DayCardTransactions({
    Key? key,
    required this.transactions,
    required this.currencyCode,
  }) : super(key: key);

  final List<TransactionIsar> transactions;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        final transaction = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat('00').format(transaction.dateTime.hour),
                      style: kHeader2TextStyle.copyWith(
                          color: context.appTheme.backgroundNegative, fontSize: 11, height: 1),
                    ),
                    Text(
                      NumberFormat('00').format(transaction.dateTime.minute),
                      style: kHeader4TextStyle.copyWith(
                          color: context.appTheme.backgroundNegative.withOpacity(0.5),
                          fontSize: 11,
                          height: 1),
                    ),
                  ],
                ),
              ),
              Gap.w8,
              // Category, Note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        transaction.category.value != null
                            ? SvgIcon(
                                AppIcons.fromCategoryAndIndex(transaction.category.value!.iconCategory,
                                    transaction.category.value!.iconIndex),
                                size: 20,
                                color: context.appTheme.backgroundNegative.withOpacity(0.5),
                              )
                            : Gap.noGap,
                        transaction.category.value != null ? Gap.w4 : const SizedBox(),
                        Text(
                          transaction.category.value != null
                              ? transaction.category.value!.name
                              : 'Account Create',
                          style: kHeader4TextStyle.copyWith(
                              color: context.appTheme.backgroundNegative.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                    // Note
                    transaction.note != null
                        ? Text(
                            transaction.note!,
                            style: kHeader4TextStyle.copyWith(
                                color: context.appTheme.backgroundNegative, fontSize: 14),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.account.value!.name,
                    style: kHeader4TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative.withOpacity(0.5), fontSize: 12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        CalculatorService.formatCurrency(transaction.amount),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: kHeader2TextStyle.copyWith(
                            color: transaction.transactionType == TransactionType.income
                                ? context.appTheme.positive
                                : transaction.transactionType == TransactionType.expense
                                    ? context.appTheme.negative
                                    : AppColors.darkerGrey,
                            fontSize: 15),
                      ),
                      Gap.w4,
                      Text(
                        currencyCode,
                        style: kHeader4TextStyle.copyWith(
                            color: transaction.transactionType == TransactionType.income
                                ? context.appTheme.positive
                                : transaction.transactionType == TransactionType.expense
                                    ? context.appTheme.negative
                                    : AppColors.darkerGrey,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}
