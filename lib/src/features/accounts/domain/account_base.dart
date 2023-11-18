import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/base_model.dart';
import '../../../../persistent/realm_dto.dart';
import '../../transactions/domain/transaction_base.dart';

import 'statement/statement.dart';

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

    DateTime? earliestPayableDate =
        transactionsList.isEmpty ? null : transactionsList.first.dateTime.onlyYearMonthDay;
    DateTime? latestTransactionDate =
        transactionsList.isEmpty ? null : transactionsList.last.dateTime.onlyYearMonthDay;

    // only year, month and day
    DateTime? earliestStatementDate;
    if (transactionsList.isNotEmpty && earliestPayableDate != null) {
      if (statementDay > earliestPayableDate.day) {
        earliestStatementDate =
            DateTime(earliestPayableDate.year, earliestPayableDate.month - 1, statementDay);
      }

      if (statementDay <= earliestPayableDate.day) {
        earliestStatementDate = earliestPayableDate.copyWith(day: statementDay).onlyYearMonthDay;
      }
    }

    // only year, month and day
    DateTime? latestStatementDate;
    if (transactionsList.isNotEmpty && latestTransactionDate != null) {
      if (statementDay > latestTransactionDate.day) {
        latestStatementDate =
            DateTime(latestTransactionDate.year, latestTransactionDate.month - 1, statementDay);
      }

      if (statementDay <= latestTransactionDate.day) {
        latestStatementDate = latestTransactionDate.copyWith(day: statementDay).onlyYearMonthDay;
      }
    }

    // ADD STATEMENTS
    var statementsList = <Statement>[];
    if (earliestStatementDate != null && latestStatementDate != null) {
      statementsList = _CreditAccountExtension.buildStatementsList(
        statementDay,
        paymentDueDay,
        earliestStatementDate: earliestStatementDate,
        latestStatementDate: latestStatementDate,
        accountTransactionsList: transactionsList,
        apr: accountDb.creditDetails!.apr,
      );
    }

    return CreditAccount._(
      accountDb,
      name: accountDb.name,
      iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
      creditBalance: accountDb.creditDetails!.creditBalance,
      apr: accountDb.creditDetails!.apr,
      statementDay: accountDb.creditDetails!.statementDay,
      paymentDueDay: accountDb.creditDetails!.paymentDueDay,
      transactionsList: transactionsList,
      statementsList: statementsList,
      earliestStatementDate: earliestStatementDate,
      earliestPayableDate: earliestPayableDate,
    );
  }

  static RegularAccount _regularAccountFromDatabase(AccountDb accountDb) {
    final List<BaseRegularTransaction> transactionsList = accountDb.transactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<BaseRegularTransaction>(
            (txn) => BaseTransaction.fromDatabase(txn) as BaseRegularTransaction)
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
          creditBalance: accountDb.creditDetails!.creditBalance,
          apr: accountDb.creditDetails!.apr,
          statementDay: accountDb.creditDetails!.statementDay,
          paymentDueDay: accountDb.creditDetails!.paymentDueDay,
          transactionsList: const [],
          statementsList: const [],
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

extension _CreditAccountExtension on Account {
  static List<Statement> buildStatementsList(
    int statementDay,
    int paymentDueDay, {
    required double apr,
    //required List<CheckpointDb> checkpoints,
    required DateTime earliestStatementDate,
    required DateTime latestStatementDate,
    required List<BaseCreditTransaction> accountTransactionsList,
  }) {
    //final checkpointsMap = _buildCheckpointsMap(checkpoints);

    final statementsList = <Statement>[];

    final installmentCountsMap = <CreditSpending, int>{};

    DateTime startDate = earliestStatementDate;

    while (!startDate.isAfter(latestStatementDate) || installmentCountsMap.isNotEmpty) {
      final endDate =
          startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;

      final dueDate = statementDay >= paymentDueDay
          ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
          : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

      // TODO: Continue here, balance trong checkpoint sẽ bao gồm toàn bộ giá trị, trừ giá trị installment

      final previousStatement = startDate != earliestStatementDate
          ? statementsList.last.carryToNextStatement
          : PreviousStatement.noData();

      //final checkpointOutstandingBalance = checkpointsMap.containsKey(startDate) ? checkpointsMap[startDate] : null;

      // TODO: Hey, installment should start right at current statement, should let user choose when to start
      final installmentCounts = <InstallmentCount>[];
      for (final entry in installmentCountsMap.entries) {
        installmentCounts.add(InstallmentCount(entry.key, entry.value));
      }

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
          txnsInGracePeriod.add(txn);
        } else {
          txnsInBillingCycle.add(txn);

          // TODO: Hey, installment should start right at current statement, should let user choose when to start
          if (txn is CreditSpending && txn.hasInstallment) {
            installmentCountsMap[txn] = txn.monthsToPay!;
          }
        }
      }

      Statement statement = Statement.create(
        StatementType.withAverageDailyBalance,
        previousStatement: previousStatement,
        checkpointOutstandingBalance: null,
        startDate: startDate,
        endDate: endDate,
        dueDate: dueDate,
        apr: apr,
        installmentTxnsToPayCounts: installmentCounts,
        txnsInBillingCycle: txnsInBillingCycle,
        txnsInGracePeriod: txnsInGracePeriod,
      );

      statementsList.add(statement);

      installmentCountsMap.updateAll((txn, counts) => counts - 1);

      installmentCountsMap.removeWhere((txn, counts) => counts < 0);

      startDate = startDate.copyWith(month: startDate.month + 1);
    }

    return statementsList;
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
        double balance = (this as CreditAccount).creditBalance;
        //TODO: Calculate credit balance
        // for (BaseCreditTransaction txn in transactionsList) {
        //
        //   if (!txn.isDone) {
        //     balance -= txn.amount - txn.paidAmount;
        //   }
        // }
        return balance;
    }
  }
}
