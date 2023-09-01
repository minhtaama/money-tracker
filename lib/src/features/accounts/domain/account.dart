import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import '../../../../persistent/isar_domain.dart';
import '../../../utils/enums.dart';
import '../../transactions/domain/transaction.dart';

@immutable
class Account extends IsarDomain {
  final AccountType type;

  final String name;
  final Color color;
  final SvgIcon icon;

  final List<Transaction> txnOfThisAccount;
  final List<Transaction> txnToThisAccount;
  final CreditDetails? creditDetails;

  // factory Account.fromIsar(AccountIsar accountIsar) {
  //   return Account
  // }

  Account._(
    super.id, {
    required this.type,
    required this.name,
    required this.color,
    required this.icon,
    required this.txnOfThisAccount,
    required this.txnToThisAccount,
    required this.creditDetails,
  });
}

class CreditDetails {
  final double creditBalance;

  /// As in percent.
  final double interestRate;

  final int statementDay;

  final int paymentDueDay;

  CreditDetails({
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
