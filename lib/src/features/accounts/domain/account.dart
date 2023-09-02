import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import '../../../../persistent/isar_domain.dart';
import '../../../utils/enums.dart';
import '../../transactions/domain/transaction.dart';
import '../data/isar_dto/account_isar.dart';

@immutable
class Account extends IsarDomain {
  final AccountType type;

  final String name;
  final Color color;
  final Color backgroundColor;
  final String iconPath;

  final List<Transaction> txnOfThisAccount;
  final List<Transaction> txnToThisAccount;
  final CreditDetails? creditDetails;

  static Account? fromIsar(AccountIsar? accountIsar) {
    if (accountIsar == null) {
      return null;
    }

    final txnOfThisAccount =
        accountIsar.txnOfThisAccountBacklinks.map((txn) => Transaction.fromIsar(txn)).toList();
    final txnToThisAccount =
        accountIsar.txnToThisAccountBacklinks.map((txn) => Transaction.fromIsar(txn)).toList();

    return Account._(
      accountIsar.id,
      type: accountIsar.type,
      name: accountIsar.name,
      color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
      txnOfThisAccount: txnOfThisAccount,
      txnToThisAccount: txnToThisAccount,
      creditDetails: CreditDetails.fromIsar(accountIsar),
    );
  }

  const Account._(
    super.id, {
    required this.type,
    required this.name,
    required this.color,
    required this.backgroundColor,
    required this.iconPath,
    required this.txnOfThisAccount,
    required this.txnToThisAccount,
    required this.creditDetails,
  });
}

@immutable
class CreditDetails {
  final double creditBalance;

  /// As in percent.
  final double interestRate;

  final int statementDay;

  final int paymentDueDay;

  static CreditDetails? fromIsar(AccountIsar accountIsar) {
    if (accountIsar.creditDetailsIsar == null) {
      return null;
    } else {
      return CreditDetails._(
          creditBalance: accountIsar.creditDetailsIsar!.creditBalance,
          interestRate: accountIsar.creditDetailsIsar!.interestRate,
          statementDay: accountIsar.creditDetailsIsar!.statementDay,
          paymentDueDay: accountIsar.creditDetailsIsar!.paymentDueDay);
    }
  }

  const CreditDetails._({
    required this.creditBalance,
    required this.interestRate,
    required this.statementDay,
    required this.paymentDueDay,
  });
}

extension AccountBalance on Account {
  double get currentBalance {
    switch (type) {
      case AccountType.regular:
        double balance = 0;
        for (Transaction txn in txnOfThisAccount) {
          if (txn is Income) {
            balance += txn.amount;
          } else {
            balance -= txn.amount;
          }
        }
        for (Transaction txn in txnToThisAccount) {
          balance += txn.amount;
        }
        return balance;

      case AccountType.credit:
        double balance = creditDetails!.creditBalance;
        for (Transaction txn in txnOfThisAccount) {
          if (txn is CreditSpending) {
            if (!txn.isDone) {
              balance -= txn.amount - txn.paidAmount;
            }
          }
        }
        return balance;
    }
  }
}

extension CreditInfo on Account {
  double get totalPendingCreditPayment {
    if (type == AccountType.regular) {
      throw ErrorDescription('Can not use this getter on type `AccountType.onHand`');
    }
    double pending = 0;
    for (Transaction txn in txnOfThisAccount) {
      if (txn is CreditSpending) {
        if (!txn.isDone) {
          pending += txn.pendingPayment;
        }
      }
    }
    return pending;
  }
}
