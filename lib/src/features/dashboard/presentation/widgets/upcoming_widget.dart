import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../recurrence/domain/recurrence.dart';
import '../../../recurrence/presentation/transaction_data_tile.dart';

class UpcomingWidget extends ConsumerWidget {
  const UpcomingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final list = recRepo.getAllRecurrenceTransactionInMonth(context, DateTime.now());

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          children: list
              .map((e) => Column(
                    children: [
                      Text(e.dateTime!.toString()),
                      _tile(context, e),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, TransactionData model) {
    return CardItem(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      border: context.appTheme.isDarkTheme ? Border.all(color: AppColors.greyBorder(context)) : null,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        onTap: () {
          //
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
          child: TransactionDataTile(
            model: model,
          ),
        ),
      ),
    );
  }
}
