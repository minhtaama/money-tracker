import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import '../../../../persistent/model_from_realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../transactions/domain/transaction_base.dart';

part 'regular_account.dart';
part 'credit_account.dart';

@immutable
sealed class Account extends BaseModelWithIcon<AccountDb> {
  List get transactionsList;

  static Account? fromDatabase(AccountDb? accountDb) {
    if (accountDb == null) {
      return null;
    }

    return switch (accountDb.type) {
      0 => RegularAccount._(
          accountDb,
          name: accountDb.name,
          color: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
        ),
      _ => CreditAccount._(accountDb,
          name: accountDb.name,
          color: AppColors.allColorsUserCanPick[accountDb.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountDb.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountDb.iconCategory, accountDb.iconIndex),
          creditBalance: accountDb.creditDetails!.creditBalance,
          penaltyInterest: accountDb.creditDetails!.apr,
          statementDay: accountDb.creditDetails!.statementDay,
          paymentDueDay: accountDb.creditDetails!.paymentDueDay)
    };
  }

  const Account(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
  });
}

extension Details on Account {
  double get currentBalance {
    switch (this) {
      case RegularAccount():
        double balance = 0;
        for (RegularTransaction txn in transactionsList) {
          switch (txn) {
            case Expense() || Transfer():
              balance -= txn.amount;
              break;
            case Income():
              balance += txn.amount;
              break;
          }
        }
        for (Transfer txn in (this as RegularAccount).transferTransactionsToThisAccountList) {
          balance += txn.amount;
        }
        return balance;
      case CreditAccount():
        double balance = (this as CreditAccount).creditBalance;
        for (CreditSpending txn in transactionsList) {
          if (!txn.isDone) {
            balance -= txn.amount - txn.paidAmount;
          }
        }
        return balance;
    }
  }
}
