import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/recurrence/presentation/transaction_data_tile.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../data/recurrence_repo.dart';

class RecurrenceScreen extends ConsumerWidget {
  const RecurrenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final list = recRepo.getRecurrences();

    return CustomPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          isTopLevelOfNavigationRail: true,
          title: context.loc.recurrence,
        ),
      ),
      children: list
          .map((e) => Column(
                children: [
                  Text(recurrenceExpression(context, e)),
                  TransactionDataTile(model: e.transactionData),
                ],
              ))
          .toList(),
    );
  }
}
