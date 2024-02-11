import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/base_model.dart';
import '../../../../persistent/realm_dto.dart';
import '../../transactions/domain/transaction_base.dart';

import 'statement/base_class/statement.dart';

part 'regular_account.dart';
part 'credit_account.dart';

@immutable
sealed class Account extends BaseModelWithIcon<AccountDb> {
  /// Already sorted by transactions dateTime when created
  abstract final List transactionsList;

  static CreditAccount _creditAccountFromDatabase(AccountDb accountDb) {
    final List<BaseCreditTransaction> transactionsList = accountDb.transactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<BaseCreditTransaction>((txn) => BaseTransaction.fromDatabase(txn) as BaseCreditTransaction)
        .toList(growable: false);

    final int statementDay = accountDb.creditDetails!.statementDay;
    final int paymentDueDay = accountDb.creditDetails!.paymentDueDay;

    final statementType = switch (accountDb.creditDetails!.statementType) {
      0 => StatementType.withAverageDailyBalance,
      _ => StatementType.payOnlyInGracePeriod,
    };

    DateTime? earliestPayableDate = transactionsList.isEmpty ? null : transactionsList.first.dateTime.onlyYearMonthDay;
    DateTime? latestTransactionDate = transactionsList.isEmpty ? null : transactionsList.last.dateTime.onlyYearMonthDay;

    // only year, month and day
    DateTime? earliestStatementDate;
    if (transactionsList.isNotEmpty && earliestPayableDate != null) {
      earliestStatementDate = DateTime(earliestPayableDate.year, earliestPayableDate.month - 1, statementDay);
    }

    // only year, month and day
    DateTime? latestStatementDate;
    if (transactionsList.isNotEmpty && latestTransactionDate != null) {
      if (statementDay > latestTransactionDate.day) {
        latestStatementDate = DateTime(latestTransactionDate.year, latestTransactionDate.month - 1, statementDay);
      }

      if (statementDay <= latestTransactionDate.day) {
        latestStatementDate = latestTransactionDate.copyWith(day: statementDay).onlyYearMonthDay;
      }
    }

    // ADD STATEMENTS
    var statementsList = <Statement>[];
    if (earliestStatementDate != null && latestStatementDate != null) {
      statementsList = CreditAccountExtension._buildStatementsList(
        statementDay,
        paymentDueDay,
        earliestStatementDate: earliestStatementDate,
        latestStatementDate: latestStatementDate,
        accountTransactionsList: transactionsList,
        apr: accountDb.creditDetails!.apr,
        statementType: statementType,
      );
    }

    return CreditAccount._(
      accountDb,
      name: accountDb.name,
      iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
      creditLimit: accountDb.creditDetails!.creditBalance,
      apr: accountDb.creditDetails!.apr,
      statementDay: accountDb.creditDetails!.statementDay,
      paymentDueDay: accountDb.creditDetails!.paymentDueDay,
      transactionsList: transactionsList,
      statementsList: statementsList,
      statementType: statementType,
      earliestStatementDate: earliestStatementDate,
      earliestPayableDate: earliestPayableDate,
    );
  }

  static RegularAccount _regularAccountFromDatabase(AccountDb accountDb) {
    final List<BaseRegularTransaction> transactionsList = accountDb.transactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<BaseRegularTransaction>((txn) => BaseTransaction.fromDatabase(txn) as BaseRegularTransaction)
        .toList(growable: false);

    final List<ITransferable> transferTransactionsList = accountDb.transferTransactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<ITransferable>((txn) => BaseTransaction.fromDatabase(txn) as ITransferable)
        .toList();

    return RegularAccount._(
      accountDb,
      name: accountDb.name,
      iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
      transactionsList: transactionsList,
      transferTransactionsList: transferTransactionsList,
    );
  }

  static Account? fromDatabase(AccountDb? accountDb) {
    if (accountDb == null) {
      return null;
    }

    // AccountType.regular
    if (accountDb.type == 0) {
      return _regularAccountFromDatabase(accountDb);
    }

    // AccountType.credit
    if (accountDb.type != 0) {
      return _creditAccountFromDatabase(accountDb);
    }

    return null;
  }

  static Account? fromDatabaseWithNoDetails(AccountDb? accountDb) {
    if (accountDb == null) {
      return null;
    }

    final statementType = switch (accountDb.creditDetails?.statementType) {
      null => null,
      0 => StatementType.withAverageDailyBalance,
      _ => StatementType.payOnlyInGracePeriod,
    };

    return switch (accountDb.type) {
      0 => RegularAccount._(
          accountDb,
          name: accountDb.name,
          iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
          transactionsList: const [],
          transferTransactionsList: const [],
        ),
      _ => CreditAccount._(
          accountDb,
          name: accountDb.name,
          iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
          creditLimit: accountDb.creditDetails!.creditBalance,
          apr: accountDb.creditDetails!.apr,
          statementDay: accountDb.creditDetails!.statementDay,
          paymentDueDay: accountDb.creditDetails!.paymentDueDay,
          transactionsList: const [],
          statementsList: const [],
          statementType: statementType!,
          earliestStatementDate: null,
          earliestPayableDate: null,
        ),
    };
  }

  const Account(
    super._isarObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
  });
}

extension CreditAccountExtension on Account {
  static List<Statement> _buildStatementsList(
    int statementDay,
    int paymentDueDay, {
    required double apr,
    required DateTime earliestStatementDate,
    required DateTime latestStatementDate,
    required List<BaseCreditTransaction> accountTransactionsList,
    required StatementType statementType,
  }) {
    final statementsList = <Statement>[];

    final installmentCountsMapToMutate = <CreditSpending, int>{};

    DateTime startDate = earliestStatementDate;

    // Loop each startDate to create statement
    while (!startDate.isAfter(latestStatementDate) || installmentCountsMapToMutate.isNotEmpty) {
      final endDate = startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;

      final dueDate = statementDay >= paymentDueDay
          ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
          : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

      final previousStatement = startDate != earliestStatementDate
          ? statementsList.last.bringToNextStatement
          : PreviousStatement.noData(
              dueDate: statementDay >= paymentDueDay
                  ? startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay
                  : startDate.copyWith(month: startDate.month, day: paymentDueDay).onlyYearMonthDay);

      Checkpoint? checkpoint;

      final installmentsToAddToStatement = <Installment>[
        for (final entry in installmentCountsMapToMutate.entries) Installment(entry.key, entry.value)
      ];

      // Loop each transaction to add to statement
      final txnsInGracePeriod = <BaseCreditTransaction>[];

      final txnsInBillingCycle = <BaseCreditTransaction>[];

      for (int i = 0; i <= accountTransactionsList.length - 1; i++) {
        final txn = accountTransactionsList[i];

        if (txn.dateTime.isBefore(startDate)) {
          continue;
        }

        if (txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
          break;
        }

        if (txn.dateTime.onlyYearMonthDay.isAfter(endDate)) {
          if (txn is CreditCheckpoint) {
            final x = _modifyInstallmentsAtCheckpoint(
              installmentsToAddToStatement: installmentsToAddToStatement,
              txn: txn,
              checkpointBalance: txn.amount,
              installmentCountsMapToMutate: installmentCountsMapToMutate,
            );

            checkpoint = Checkpoint(txn.amount, x);
          }

          txnsInGracePeriod.add(txn);

          continue;
        }

        if (txn is CreditCheckpoint) {
          continue;
        }

        // TODO: should let user choose when to start
        if (txn is CreditSpending && txn.hasInstallment) {
          installmentCountsMapToMutate[txn] = txn.monthsToPay!;
        }

        txnsInBillingCycle.add(txn);
      }

      Statement statement = Statement.create(
        statementType,
        previousStatement: previousStatement,
        checkpoint: checkpoint,
        startDate: startDate,
        endDate: endDate,
        dueDate: dueDate,
        apr: apr,
        installments: installmentsToAddToStatement,
        txnsInBillingCycle: txnsInBillingCycle,
        txnsInGracePeriod: txnsInGracePeriod,
      );

      statementsList.add(statement);

      installmentCountsMapToMutate.updateAll((txn, counts) => counts - 1);

      installmentCountsMapToMutate.removeWhere((txn, counts) => counts < 0);

      startDate = startDate.copyWith(month: startDate.month + 1);
    }

    return statementsList;
  }

  /// Returns total unpaid of installments and modify the `installmentCountsMapToMutate`
  /// to keep only installment transactions has unpaid amount lower than checkpoint balance
  static double _modifyInstallmentsAtCheckpoint(
      {required List<Installment> installmentsToAddToStatement,
      required CreditCheckpoint txn,
      required double checkpointBalance,
      required Map<CreditSpending, int> installmentCountsMapToMutate}) {
    double totalUnpaid = 0;

    for (CreditSpending spending in txn.finishedInstallments) {
      if (installmentsToAddToStatement.map((e) => e.txn).contains(spending)) {
        installmentsToAddToStatement.removeWhere((el) => el.txn.databaseObject.id == spending.databaseObject.id);
        installmentCountsMapToMutate.remove(spending);
      }
    }

    for (Installment inst in installmentsToAddToStatement) {
      totalUnpaid += inst.unpaidAmount;
    }

    // Then user might have full-paid all installments
    if (checkpointBalance < totalUnpaid) {
      return 0;
    } else {
      return totalUnpaid;
    }
  }
}

extension AccountGettersExtension on Account {
  double get availableAmount {
    switch (this) {
      case RegularAccount():
        double balance = 0;
        for (BaseRegularTransaction txn in transactionsList) {
          switch (txn) {
            case Expense() || Transfer():
              balance -= txn.amount;
              break;
            case Income():
              balance += txn.amount;
              break;
          }
        }
        for (ITransferable txn in (this as RegularAccount).transferTransactionsList) {
          if (txn is Transfer) {
            balance += txn.amount;
          }
          if (txn is CreditPayment) {
            balance -= txn.amount;
          }
        }
        return balance;

      case CreditAccount():
        final limit = (this as CreditAccount).creditLimit;
        try {
          final todayStatement = (this as CreditAccount).statementAt(DateTime.now(), upperGapAtDueDate: true);
          return limit - todayStatement!.balance - todayStatement.spent.inGracePeriod;
        } catch (_) {
          return limit;
        }
    }
  }
}
