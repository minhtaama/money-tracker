import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/budget/data/budget_repo.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';

class BudgetServices {
  BudgetServices(this.transactionRepo, this.budgetRepo);

  final TransactionRepositoryRealmDb transactionRepo;
  final BudgetsRepositoryRealmDb budgetRepo;

  List<BudgetDetail> getAllBudgetDetails(BuildContext context, DateTime currentDateTime) {
    final budgetsList = budgetRepo.getList();
    final result = <BudgetDetail>[];

    for (int i = 0; i < budgetsList.length; i++) {
      final budget = budgetsList[i];

      final range = switch (budget.periodType) {
        BudgetPeriodType.daily => currentDateTime.dayRange,
        BudgetPeriodType.weekly => currentDateTime.weekRange(context),
        BudgetPeriodType.monthly => currentDateTime.monthRange,
        BudgetPeriodType.yearly => currentDateTime.yearRange,
      };

      List<BaseTransaction> txns = transactionRepo.getTransactions(range.start, range.end);

      if (budget is AccountBudget) {
        txns = txns
            .where((txn) => budget.accounts.contains(txn.account) && (txn is CreditSpending || txn is Expense))
            .toList();
      }

      if (budget is CategoryBudget) {
        txns = txns.whereType<Expense>().where((txn) => budget.categories.contains(txn.category)).toList();
      }

      final currentAmount = txns.isEmpty ? 0.0 : txns.map((e) => e.amount).reduce((value, element) => value + element);

      result.add(BudgetDetail(currentAmount: currentAmount, budget: budget, range: range));
    }

    return result;
  }

  BudgetDetail getBudgetDetail(BuildContext context, BaseBudget budget, DateTime dateTime) {
    final range = switch (budget.periodType) {
      BudgetPeriodType.daily => dateTime.dayRange,
      BudgetPeriodType.weekly => dateTime.weekRange(context),
      BudgetPeriodType.monthly => dateTime.monthRange,
      BudgetPeriodType.yearly => dateTime.yearRange,
    };

    List<BaseTransaction> txns = transactionRepo.getTransactions(range.start, range.end);

    if (budget is AccountBudget) {
      txns = txns
          .where((txn) => budget.accounts.contains(txn.account) && (txn is CreditSpending || txn is Expense))
          .toList();
    }

    if (budget is CategoryBudget) {
      txns = txns.whereType<Expense>().where((txn) => budget.categories.contains(txn.category)).toList();
    }

    final currentAmount = txns.isEmpty ? 0.0 : txns.map((e) => e.amount).reduce((value, element) => value + element);

    return BudgetDetail(currentAmount: currentAmount, budget: budget, range: range);
  }
}

/////////////////// PROVIDERS //////////////////////////

final budgetServicesProvider = Provider<BudgetServices>(
  (ref) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    final budgetRepo = ref.watch(budgetsRepositoryRealmProvider);

    return BudgetServices(transactionRepo, budgetRepo);
  },
);

@immutable
class BudgetDetail {
  final double currentAmount;
  final BaseBudget budget;
  final DateTimeRange range;

  const BudgetDetail({
    required this.currentAmount,
    required this.budget,
    required this.range,
  });
}
