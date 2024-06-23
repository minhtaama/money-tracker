import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/base_model.dart';
import '../../../../persistent/realm_dto.dart';
import '../../transactions/domain/transaction_base.dart';
import 'dart:math' as math;

import 'statement/base_class/statement.dart';

part 'regular_account.dart';
part 'credit_account.dart';
part 'saving_account.dart';

abstract class BaseAccount extends BaseModelWithIcon<AccountDb> {
  const BaseAccount(
    super._isarObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
  });
}

/// This class is used as a link from other domain
sealed class AccountInfo extends BaseAccount {
  final bool isNotExistInDatabase;

  /// This class is used as a link from other domain
  const AccountInfo(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    this.isNotExistInDatabase = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AccountInfo &&
          runtimeType == other.runtimeType &&
          databaseObject.id == other.databaseObject.id;

  @override
  int get hashCode => super.hashCode ^ databaseObject.id.hashCode;

  Account toAccount() {
    return Account.fromDatabase(databaseObject)!;
  }
}

class DeletedAccount extends AccountInfo {
  DeletedAccount()
      : super(
          AccountDb(ObjectId(), 0, '', 0, '', 0),
          name: 'Deleted account'.hardcoded,
          iconColor: AppColors.white,
          backgroundColor: AppColors.greyConst,
          iconPath: AppIcons.defaultIcon,
          isNotExistInDatabase: true,
        );
}

@immutable
sealed class Account extends BaseAccount {
  /// Already sorted by transactions dateTime when created
  abstract final List transactionsList;

  static CreditAccount _creditAccountFromDatabase(AccountDb accountDb) {
    final List<BaseCreditTransaction> transactionsList = accountDb.transactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<BaseCreditTransaction>((txn) => BaseTransaction.fromDatabase(txn) as BaseCreditTransaction)
        .toList(growable: false);

    final int statementDay = accountDb.creditDetails!.statementDay;
    final int paymentDueDay = accountDb.creditDetails!.paymentDueDay;

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
        statementType: StatementType.fromDatabaseValue(accountDb.creditDetails!.statementType),
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
      statementType: StatementType.fromDatabaseValue(accountDb.creditDetails!.statementType),
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

  static SavingAccount _savingAccountFromDatabase(AccountDb accountDb) {
    final List<Transfer> transactionsList = accountDb.transactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<Transfer>((txn) => BaseTransaction.fromDatabase(txn) as Transfer)
        .toList(growable: false);

    final List<Transfer> transferOutList = accountDb.transferTransactions
        .query('TRUEPREDICATE SORT(dateTime ASC)')
        .map<Transfer>((txn) => BaseTransaction.fromDatabase(txn) as Transfer)
        .toList();

    return SavingAccount._(
      accountDb,
      name: accountDb.name,
      iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
      transactionsList: transactionsList,
      transferInList: transferOutList,
      targetDate: accountDb.savingDetails!.targetDate,
      targetAmount: accountDb.savingDetails!.targetAmount,
    );
  }

  static Account? fromDatabase(AccountDb? accountDb) {
    if (accountDb == null) {
      return null;
    }

    final type = AccountType.fromDatabaseValue(accountDb.type);

    return switch (type) {
      AccountType.regular => _regularAccountFromDatabase(accountDb),
      AccountType.credit => _creditAccountFromDatabase(accountDb),
      AccountType.saving => _savingAccountFromDatabase(accountDb),
    };
  }

  static AccountInfo? fromDatabaseInfoOnly(AccountDb? accountDb) {
    if (accountDb == null) {
      return null;
    }

    final type = AccountType.fromDatabaseValue(accountDb.type);

    return switch (type) {
      AccountType.regular => RegularAccountInfo._(
          accountDb,
          name: accountDb.name,
          iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
        ),
      AccountType.credit => CreditAccountInfo._(
          accountDb,
          name: accountDb.name,
          iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
          creditLimit: accountDb.creditDetails!.creditBalance,
          apr: accountDb.creditDetails!.apr,
          statementDay: accountDb.creditDetails!.statementDay,
          paymentDueDay: accountDb.creditDetails!.paymentDueDay,
          statementType: StatementType.fromDatabaseValue(accountDb.creditDetails!.statementType),
        ),
      AccountType.saving => SavingAccountInfo._(
          accountDb,
          name: accountDb.name,
          iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
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
    // 1. Create list and map to mutate before the while...loop begins.
    final statementsList = <Statement>[];

    final installmentCountsMapToMutate = <CreditSpending, int>{};

    // 2. The initial startDate
    DateTime startDate = earliestStatementDate;

    // 3. Loop each startDate to create statement
    while (!startDate.isAfter(latestStatementDate) || installmentCountsMapToMutate.isNotEmpty) {
      // 3.1. For each while...loop, calculate dates and get previousStatement
      final endDate = startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;

      final dueDate = statementDay >= paymentDueDay
          ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
          : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

      final previousStatement = startDate != earliestStatementDate
          ? statementsList.last.bringToNextStatement
          : PreviousStatement.noData(
              dueDate: statementDay >= paymentDueDay
                  ? startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay
                  : startDate.copyWith(month: startDate.month, day: paymentDueDay).onlyYearMonthDay,
            );

      Checkpoint? checkpoint;

      // 3.2. For each while...loop, loop through `accountTransactionsList` to find CreditSpending that has
      // installment and allow to start payment from this statement.
      for (int i = 0; i <= accountTransactionsList.length - 1; i++) {
        final txn = accountTransactionsList[i];

        if (txn.dateTime.isBefore(startDate)) {
          continue;
        }

        if (txn.dateTime.isAfter(endDate.copyWith(day: endDate.day + 1))) {
          break;
        }

        if (txn is CreditSpending && txn.hasInstallment && !txn.paymentStartFromNextStatement) {
          installmentCountsMapToMutate[txn] = txn.monthsToPay! - 1;
        }
      }

      // 3.3. For each while...loop, this thing here is used as a temp list to not add installment-to-pay
      // in the same statement with the spending-registered-with-installment
      final installmentsToAddToStatement = <Installment>[
        for (final entry in installmentCountsMapToMutate.entries) Installment(entry.key, entry.value)
      ];

      // 3.4. For each while...loop, Create a list.
      final txnsInGracePeriod = <BaseCreditTransaction>[];
      final txnsInBillingCycle = <BaseCreditTransaction>[];

      // 3.5. For each while...loop, loop each transaction to add to statement
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
        if (txn is CreditSpending && txn.hasInstallment && txn.paymentStartFromNextStatement) {
          installmentCountsMapToMutate[txn] = txn.monthsToPay!;
        }

        txnsInBillingCycle.add(txn);
      }

      // 3.6. For each while...loop, Create statement after the loop in 3.4 is done.
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

      // 3.7. For each while...loop, add statement to list create in 1.
      statementsList.add(statement);

      // 3.8. For each while...loop, update `installmentCountsMapToMutate`
      installmentCountsMapToMutate.updateAll((txn, counts) => counts - 1);

      installmentCountsMapToMutate.removeWhere((txn, counts) => counts < 0);

      startDate = startDate.copyWith(month: startDate.month + 1);
    }

    // 4. Return the statement list
    return statementsList;
  }

  /// Returns total unpaid of installments and modify the `installmentCountsMapToMutate`
  /// to keep only installment transactions that user choose to keep
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

    for (MapEntry<CreditSpending, int> entry in installmentCountsMapToMutate.entries) {
      final txn = entry.key;
      final monthsLeft = entry.value;
      final unpaid = txn.monthsToPay! == monthsLeft ? txn.amount : (txn.paymentAmount! * monthsLeft);
      totalUnpaid += unpaid;
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
    if (this is RegularAccount || this is SavingAccount) {
      double balance = 0;

      for (int i = 0; i <= transactionsList.length - 1; i++) {
        final txn = transactionsList[i];

        switch (txn) {
          case Expense() || Transfer():
            balance -= txn.amount;
            break;
          case Income():
            balance += txn.amount;
            break;
        }
      }

      final transferTxnsList = this is RegularAccount
          ? (this as RegularAccount).transferTransactionsList
          : (this as SavingAccount).transferInList;

      for (int i = 0; i <= transferTxnsList.length - 1; i++) {
        final txn = transferTxnsList[i];

        if (txn is Transfer) {
          balance += txn.amount;
          continue;
        }
        if (txn is CreditPayment) {
          balance -= txn.amount;
          continue;
        }
      }

      return balance;
    }

    if (this is CreditAccount) {
      final limit = (this as CreditAccount).creditLimit;
      try {
        final todayStatement = (this as CreditAccount).statementAt(DateTime.now(), upperGapAtDueDate: true);
        return limit - todayStatement!.balance - todayStatement.spent.inGracePeriod;
      } catch (_) {
        return limit;
      }
    }

    throw StateError('Can only call this method in RegularAccount and CreditAccount.');
  }
}
