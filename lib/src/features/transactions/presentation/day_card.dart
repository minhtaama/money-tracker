import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
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
    this.onTransactionTap,
  }) : super(key: key);

  final DateTime dateTime;
  final List<TransactionIsar> transactions;
  final Function(TransactionIsar)? onTransactionTap;

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
                    color:
                        dateTime.weekday == 6 || dateTime.weekday == 7 ? context.appTheme.accent : AppColors.darkerGrey,
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
            onTap: onTransactionTap,
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
    this.onTap,
  }) : super(key: key);

  final List<TransactionIsar> transactions;
  final String currencyCode;
  final Function(TransactionIsar)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        final transaction = transactions[index];

        return CustomInkWell(
          inkColor: AppColors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap?.call(transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // _Time(transaction: transaction),
                    _Dot(transaction: transaction),
                    Gap.w8,
                    Expanded(
                      child: Row(
                        children: [
                          transaction.transactionType == TransactionType.transfer
                              ? const _TransferLine(width: 14, adjustY: 1, height: 27)
                              : Gap.noGap,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                transaction.transactionType != TransactionType.transfer
                                    ? _ExpandedCategory(transaction: transaction)
                                    : Gap.noGap,
                                _ExpandedAccount(transaction: transaction),
                                transaction.transactionType == TransactionType.transfer ? Gap.h4 : Gap.noGap,
                                transaction.transactionType == TransactionType.transfer
                                    ? _ExpandedToAccount(transaction: transaction)
                                    : Gap.noGap,
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
                transaction.note != null || transaction.tag.value != null ? _Note(transaction: transaction) : Gap.noGap,
              ],
            ),
          ),
        );
      }),
    );
  }
}

///////////////////////////////////////////

// class _Time extends StatelessWidget {
//   const _Time({Key? key, required this.transaction}) : super(key: key);
//
//   final TransactionIsar transaction;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.grey,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             NumberFormat('00').format(transaction.dateTime.hour),
//             style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12, height: 1),
//           ),
//           Text(
//             NumberFormat('00').format(transaction.dateTime.minute),
//             style: kHeader4TextStyle.copyWith(
//                 color: context.appTheme.backgroundNegative.withOpacity(0.5), fontSize: 12, height: 1),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _Dot extends StatelessWidget {
  const _Dot({Key? key, required this.transaction}) : super(key: key);

  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: 6,
      decoration: BoxDecoration(
        color: transaction.transactionType == TransactionType.transfer
            ? AppColors.darkerGrey
            : transaction.transactionType == TransactionType.expense
                ? context.appTheme.negative
                : context.appTheme.positive,
        borderRadius: BorderRadius.circular(100),
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
        SvgIcon(
          !transaction.isInitialTransaction
              ? AppIcons.fromCategoryAndIndex(
                  transaction.category.value!.iconCategory, transaction.category.value!.iconIndex)
              : AppIcons.add,
          size: 20,
          color: context.appTheme.backgroundNegative.withOpacity(transaction.category.value != null ? 1 : 0.5),
        ),
        Gap.w4,
        // Category Name
        Expanded(
          child: Text(
            !transaction.isInitialTransaction ? transaction.category.value!.name : 'Initial Balance',
            style: kHeader3TextStyle.copyWith(
                color: context.appTheme.backgroundNegative.withOpacity(transaction.category.value != null ? 1 : 0.5),
                fontSize: 12),
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
        transaction.account.value != null && transaction.transactionType != TransactionType.transfer
            ? SvgIcon(
                transaction.isInitialTransaction || transaction.transactionType == TransactionType.transfer
                    ? AppIcons.download
                    : transaction.transactionType == TransactionType.income
                        ? AppIcons.download
                        : AppIcons.upload,
                size: 20,
                color: context.appTheme.backgroundNegative,
              )
            : Gap.noGap,
        transaction.account.value != null ? Gap.w4 : Gap.noGap,
        // Category Name
        Expanded(
          child: Text(
            transaction.account.value != null ? transaction.account.value!.name : ' ',
            style: kHeader3TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }
}

class _ExpandedToAccount extends StatelessWidget {
  const _ExpandedToAccount({Key? key, required this.transaction}) : super(key: key);

  final TransactionIsar transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Icon
        transaction.toAccount.value != null && transaction.transactionType != TransactionType.transfer
            ? SvgIcon(
                AppIcons.fromCategoryAndIndex(
                    transaction.toAccount.value!.iconCategory, transaction.toAccount.value!.iconIndex),
                size: 20,
                color: context.appTheme.backgroundNegative,
              )
            : Gap.noGap,
        transaction.toAccount.value != null ? Gap.w4 : Gap.noGap,
        // Category Name
        Expanded(
          child: Text(
            transaction.toAccount.value != null ? transaction.toAccount.value!.name : ' ',
            style: kHeader3TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
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
                      : AppColors.darkerGrey.withOpacity(0.85),
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
                      : AppColors.darkerGrey.withOpacity(0.85),
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
    return Container(
      margin: const EdgeInsets.only(left: 2, top: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: context.appTheme.backgroundNegative.withOpacity(0.3), width: 1.5)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        constraints: const BoxConstraints(minHeight: 32),
        decoration: BoxDecoration(
          color: context.appTheme.backgroundNegative.withOpacity(0.05),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            transaction.tag.value != null
                ? Text(
                    '# ${transaction.tag.value!.name}',
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  )
                : Gap.noGap,
            transaction.tag.value != null && transaction.note != null ? Gap.h4 : Gap.noGap,
            transaction.note != null
                ? Text(
                    transaction.note!,
                    style: kHeader4TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  )
                : Gap.noGap,
          ],
        ),
      ),
    );
  }
}

class _TransferLine extends StatelessWidget {
  const _TransferLine({Key? key, this.height = 30, this.width = 10, this.adjustY = 0}) : super(key: key);

  final double height;
  final double adjustY;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRect(
        child: CustomPaint(
          painter: _TransferLinePainter(context, height: height, width: width, adjustY: adjustY),
        ),
      ),
    );
  }
}

///////////////////////////////////////

class _TransferLinePainter extends CustomPainter {
  _TransferLinePainter(this.context, {this.height = 30, required this.width, required this.adjustY});

  final BuildContext context;
  final double height;
  final double width;
  final double adjustY;

  @override
  void paint(Canvas canvas, Size size) {
    double arrowXOffset = 3;
    double arrowYOffset = 3;

    double cornerSize = 14;

    ///// DO NOT CHANGE ANYTHING UNDER THIS LINE /////

    double startX = 1;
    double startY = arrowYOffset + adjustY;
    double endX = width - 1;
    double endY = height - arrowYOffset - adjustY;

    Offset arrowHead = Offset(endX, endY);
    Offset upperTail = Offset(arrowHead.dx - arrowXOffset, arrowHead.dy - arrowYOffset);
    Offset lowerTail = Offset(arrowHead.dx - arrowXOffset, arrowHead.dy + arrowYOffset);

    Offset lineTopBegin = Offset(startX + cornerSize / 2, startY);
    Offset lineTopEnd = Offset(endX - 1, startY);
    Offset lineMiddleBegin = Offset(startX, startY + cornerSize / 2);
    Offset lineMiddleEnd = Offset(startX, endY - cornerSize / 2);
    Offset lineBottomBegin = Offset(startX + cornerSize / 2, endY);
    Offset lineBottomEnd = Offset(endX - 1, endY);

    final corner1 = Rect.fromLTWH(startX, startY, cornerSize, cornerSize);
    final corner2 = Rect.fromLTWH(startX, endY - cornerSize, cornerSize, cornerSize);
    const startAngle1 = math.pi;
    const startAngle2 = math.pi / 2;
    const sweepAngle = math.pi / 2;
    const useCenter = false;

    final paint = Paint()
      ..color = context.appTheme.backgroundNegative.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawArc(corner1, startAngle1, sweepAngle, useCenter, paint);
    canvas.drawArc(corner2, startAngle2, sweepAngle, useCenter, paint);

    canvas.drawLine(lineTopBegin, lineTopEnd, paint);
    canvas.drawLine(lineMiddleBegin, lineMiddleEnd, paint);
    canvas.drawLine(lineBottomBegin, lineBottomEnd, paint);

    canvas.drawLine(arrowHead, upperTail, paint);
    canvas.drawLine(arrowHead, lowerTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
