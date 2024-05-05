import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../recurrence/domain/recurrence.dart';
import '../../recurrence/presentation/transaction_data_tile.dart';

class PlannedTransactionsCard extends ConsumerWidget {
  const PlannedTransactionsCard({
    super.key,
    required this.dateTime,
    this.onPlannedTransactionTap,
  });

  final DateTime dateTime;
  final Function(TransactionData)? onPlannedTransactionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final plannedTxns = recRepo.getPlannedTransactionsInMonth(context, dateTime);
    final today = DateTime.now().onlyYearMonthDay;

    return CardItem(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      constraints: const BoxConstraints(maxHeight: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildDays(context, plannedTxns),
      ),
    );
  }

  List<Widget> _buildDays(BuildContext context, List<TransactionData> plannedTransactions) {
    final result = <Widget>[];

    for (int i = dateTime.daysInMonth; i >= 1; i--) {
      final date = dateTime.copyWith(day: i).onlyYearMonthDay;
      final txnsInDate = plannedTransactions.where((txn) => txn.dateTime!.isSameDayAs(date)).toList();
      if (txnsInDate.isNotEmpty) {
        result.add(_Day(dateTime: date, transactionData: txnsInDate));
      }
    }

    return result;
  }
}

class _Day extends StatelessWidget {
  const _Day({super.key, required this.dateTime, required this.transactionData});

  final DateTime dateTime;
  final List<TransactionData> transactionData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DateTime(dateTime: dateTime),
        Gap.w8,
        Expanded(
          child: Column(
            children: transactionData.map((e) => _transactionData(context, e)).toList(),
          ),
        )
      ],
    );
  }

  Widget _transactionData(BuildContext context, TransactionData model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: CardItem(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        border: Border.all(
          color: (model.type == TransactionType.income
                  ? context.appTheme.positive
                  : model.type == TransactionType.expense
                      ? context.appTheme.negative
                      : context.appTheme.onBackground)
              .withOpacity(0.65),
        ),
        color: (model.type == TransactionType.income
                ? context.appTheme.positive
                : model.type == TransactionType.expense
                    ? context.appTheme.negative
                    : context.appTheme.onBackground)
            .withOpacity(0.075),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: TransactionDataTile(
            model: model,
            withoutIconColor: true,
            smaller: true,
          ),
        ),
      ),
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({this.dateTime, this.backgroundColor, this.color, this.noMonth = true});

  final DateTime? dateTime;
  final bool noMonth;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return dateTime != null
        ? Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.greyBorder(context),
              borderRadius: BorderRadius.circular(8),
              // border: dateTime!.onlyYearMonthDay.isAtSameMomentAs(DateTime.now().onlyYearMonthDay)
              //     ? Border.all()
              //     : null
            ),
            width: 26,
            constraints: const BoxConstraints(minHeight: 18),
            padding: const EdgeInsets.all(3),
            child: Center(
              child: Column(
                children: [
                  Text(
                    dateTime!.day.toString(),
                    style: kHeader2TextStyle.copyWith(
                        color: color ?? context.appTheme.onBackground, fontSize: 12, height: 1),
                  ),
                  noMonth
                      ? Gap.noGap
                      : Text(
                          dateTime!.monthToString(context, short: true),
                          style: kHeader3TextStyle.copyWith(
                              color: color ?? context.appTheme.onBackground, fontSize: 7, height: 1),
                        ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 7.5, right: 8.5),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.greyBorder(context),
                borderRadius: BorderRadius.circular(1000),
              ),
              height: 10,
              width: 10,
            ),
          );
  }
}
