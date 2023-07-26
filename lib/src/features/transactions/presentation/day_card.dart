import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
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
                        : AppColors.darkerGrey,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Time(transaction: transaction),
                  Gap.w8,
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              transaction.category.value != null
                                  ? _ExpandedCategory(transaction: transaction)
                                  : Gap.noGap,
                              _ExpandedAccount(transaction: transaction),
                            ],
                          ),
                        ),
                        Gap.w16,
                        _Amount(currencyCode: currencyCode, transaction: transaction),
                      ],
                    ),
                  ),
                ],
              ),
              Gap.h4,
              transaction.note != null ? _Note(transaction: transaction) : Gap.noGap,
            ],
          ),
        );
      }),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({Key? key, required this.transaction}) : super(key: key);

  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: context.appTheme.backgroundNegative, fontSize: 12, height: 1),
          ),
          Text(
            NumberFormat('00').format(transaction.dateTime.minute),
            style: kHeader4TextStyle.copyWith(
                color: context.appTheme.backgroundNegative.withOpacity(0.5), fontSize: 12, height: 1),
          ),
        ],
      ),
    );
  }
}

class _ExpandedCategory extends StatelessWidget {
  const _ExpandedCategory({Key? key, required this.transaction}) : super(key: key);

  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Icon
        transaction.category.value != null
            ? SvgIcon(
                AppIcons.fromCategoryAndIndex(
                    transaction.category.value!.iconCategory, transaction.category.value!.iconIndex),
                size: 20,
                color: context.appTheme.backgroundNegative,
              )
            : Gap.noGap,
        transaction.category.value != null ? Gap.w4 : Gap.noGap,
        // Category Name
        Expanded(
          child: Text(
            transaction.category.value != null ? transaction.category.value!.name : ' ',
            style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }
}

class _ExpandedAccount extends StatelessWidget {
  const _ExpandedAccount({Key? key, required this.transaction}) : super(key: key);

  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Icon
        transaction.account.value != null
            ? SvgIcon(
                AppIcons.fromCategoryAndIndex(
                    transaction.account.value!.iconCategory, transaction.account.value!.iconIndex),
                size: 20,
                color: context.appTheme.backgroundNegative,
              )
            : Gap.noGap,
        transaction.account.value != null ? Gap.w4 : Gap.noGap,
        // Category Name
        Expanded(
          child: Text(
            transaction.account.value != null ? transaction.account.value!.name : 'Account Create',
            style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({Key? key, required this.currencyCode, required this.transaction}) : super(key: key);

  final String currencyCode;
  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({Key? key, required this.transaction}) : super(key: key);

  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: ClipRect(
              child: CustomPaint(
                painter: _ShapePainter(context),
              ),
            ),
          ),
          Gap.w4,
          Expanded(
            child: CardItem(
              margin: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(12),
              elevation: 0,
              border: Border.all(color: context.appTheme.backgroundNegative.withOpacity(0.4)),
              child: Text(
                transaction.note!,
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.context);

  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.fromLTWH(13, -20, 35, 35);
    const startAngle = math.pi / 1.8;
    const sweepAngle = 1.6 * math.pi / 4;
    const useCenter = false;
    final paint = Paint()
      ..color = context.appTheme.backgroundNegative.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
