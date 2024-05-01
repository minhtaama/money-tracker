import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/transactions/data/recurrence_repo.dart';

class RecurrenceWidget extends ConsumerWidget {
  const RecurrenceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final list = recRepo.getAllUpcomingTransactionInMonth(context, DateTime.now());

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          children: list
              .map((e) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(e.toString()),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
