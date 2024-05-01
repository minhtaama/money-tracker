import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/budget/application/budget_services.dart';

class RecurrenceWidget extends ConsumerWidget {
  const RecurrenceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetService = ref.watch(budgetServicesProvider);
    final list = budgetService.getBudgetDetails(context, DateTime.now());

    return SizedBox(
      height: 130,
    );
  }
}
