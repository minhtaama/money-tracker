import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../recurrence/domain/recurrence.dart';
import '../../../recurrence/presentation/transaction_data_tile.dart';

class UpcomingWidget extends ConsumerWidget {
  const UpcomingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final list = recRepo.getRecurrences();

    final today = DateTime.now();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (Recurrence rec in list)
              _tile(
                context,
                model: rec.transactionData,
                repeatOn:
                    rec.getPlannedTransactionsInMonth(context, today).map((e) => e.dateTime!).toList(),
              )
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context,
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
