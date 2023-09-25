import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../../../../persistent/isar_model.dart';
import '../../transactions/domain/transaction_base.dart';
import '../data/isar_dto/account_isar.dart';

part 'regular_account.dart';
part 'credit_account.dart';

@immutable
sealed class Account extends IsarModelWithIcon<AccountIsar> {
  List get transactionsList;

  static Account? fromIsar(AccountIsar? accountIsar) {
    if (accountIsar == null) {
      return null;
    }

    return switch (accountIsar.type) {
      AccountType.regular => RegularAccount._(
          accountIsar,
          name: accountIsar.name,
          color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
        ),
      AccountType.credit => CreditAccount._(accountIsar,
          name: accountIsar.name,
          color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
          creditBalance: accountIsar.creditDetailsIsar!.creditBalance,
          penaltyInterest: accountIsar.creditDetailsIsar!.apr,
          statementDay: accountIsar.creditDetailsIsar!.statementDay,
          paymentDueDay: accountIsar.creditDetailsIsar!.paymentDueDay)
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
