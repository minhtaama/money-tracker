import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../recurrence/domain/recurrence.dart';
import '../../recurrence/presentation/transaction_data_tile.dart';

class PlannedTransactionsCard extends ConsumerWidget {
  const PlannedTransactionsCard({
    super.key,
    this.onPlannedTransactionTap,
  });

  final Function(TransactionData)? onPlannedTransactionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final recs = recRepo.getRecurrences();

    final today = DateTime.now().onlyYearMonthDay;

    return CardItem(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: Column(
        children: [
          for (Recurrence rec in recs)
            _tile(
              context,
              today,
              model: rec.transactionData,
              repeatOn: rec.getPlannedTransactionsInMonth(context, today).map((e) => e.dateTime!).toList(),
            )
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, DateTime today,
      {required TransactionData model, required List<DateTime> repeatOn}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: TransactionDataTile(
                  model: model,
                  withoutIconColor: true,
                ),
              ),
            ),
          ),
          Gap.w4,
          Text(
            '×',
            style: kHeader4TextStyle.copyWith(
              fontSize: 22,
              color: (model.type == TransactionType.income
                      ? context.appTheme.positive
                      : model.type == TransactionType.expense
                          ? context.appTheme.negative
                          : context.appTheme.onBackground)
                  .withOpacity(0.85),
            ),
          ),
          Gap.w4,
          Text(
            repeatOn.length.toString(),
            style: kHeader2TextStyle.copyWith(
              fontSize: 20,
              color: (model.type == TransactionType.income
                      ? context.appTheme.positive
                      : model.type == TransactionType.expense
                          ? context.appTheme.negative
                          : context.appTheme.onBackground)
                  .withOpacity(0.85),
            ),
          ),
          Gap.w4,
        ],
      ),
    );
  }
}
