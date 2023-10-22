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

  static Account? fromDatabase(AccountDb? accountDb) {
    if (accountDb == null) {
      return null;
    }

    final RealmResults<TransactionDb> transactionListQuery =
        accountDb.transactions.query('TRUEPREDICATE SORT(dateTime ASC)');
    final RealmResults<TransactionDb> transferTransactionsQuery =
        accountDb.transferTransactions.query('TRUEPREDICATE SORT(dateTime ASC)');

    final statementsList = <Statement>[];

    // if(accountDb.type != 0) {
    //   final List<Statement> list = List.empty(growable: true);
    //
    //   if (earliestStatementDate == null || latestStatementDate == null) {
    //     return list;
    //   }
    //
    //   for (DateTime begin = earliestStatementDate!;
    //   begin.compareTo(latestStatementDate!) <= 0;
    //   begin = begin.copyWith(month: begin.month + 1)) {
    //     PreviousStatement lastStatementDetails = PreviousStatement.noData();
    //     if (begin != earliestStatementDate!) {
    //       lastStatementDetails = list[list.length - 1].carryToNextStatement;
    //     }
    //     Statement statement = Statement.create(StatementType.withAverageDailyBalance, this,
    //         previousStatement: lastStatementDetails, startDate: begin);
    //     list.add(statement);
    //   }
    //
    //   return list;
    // }

    return switch (accountDb.type) {
      0 => RegularAccount._(
          accountDb,
          name: accountDb.name,
          iconColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
          transactionsList: transactionListQuery
              .map<BaseRegularTransaction>(
                  (txn) => BaseTransaction.fromDatabase(txn) as BaseRegularTransaction)
              .toList(growable: false),
          transferTransactionsList: transferTransactionsQuery
              .map<ITransferable>((txn) => BaseTransaction.fromDatabase(txn) as ITransferable)
              .toList(),
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
          transactionsList: transactionListQuery
              .map<BaseCreditTransaction>(
                  (txn) => BaseTransaction.fromDatabase(txn) as BaseCreditTransaction)
              .toList(),
          statementsList: const [],
        ),
    };
  }

  static Account? fromDatabaseWithNoTransactionsList(AccountDb? accountDb) {
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

extension AccountDetails on Account {
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
