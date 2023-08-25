import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/credit_transaction_isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';
import '../../../utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// https://www.hsbc.com.vn/en-vn/credit-cards/understanding-your-credit-card-statement/
part 'account_isar.g.dart';

@Collection()
class AccountIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late AccountType type;

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;

  /// All regular transactions of this account. Only for [AccountType.onHand]
  @Backlink(to: 'accountLink')
  final txnOfThisAccountBacklinks = IsarLinks<TransactionIsar>();

  /// Only for on-hand account transfers. Need for calculating total money of this account.
  @Backlink(to: 'toAccountLink')
  final txnToThisAccountBacklinks = IsarLinks<TransactionIsar>();

  /// All credit spending of this account. Only for [AccountType.credit]
  @Backlink(to: 'accountLink')
  final creditSpendingTxnBacklinks = IsarLinks<CreditSpendingIsar>();

  /// Only specify this property if type is [AccountType.credit]
  CreditAccountDetails? creditAccountDetails;

  @Ignore()
  double get currentBalance {
    if (type == AccountType.onHand) {
      double balance = 0;
      final txnList = txnOfThisAccountBacklinks.toList();
      for (TransactionIsar txn in txnList) {
        if (txn.transactionType == TransactionType.income) {
          balance += txn.amount;
        } else {
          balance -= txn.amount;
        }
      }
      final txnToThisAccountList = txnToThisAccountBacklinks.toList();
      for (TransactionIsar txn in txnToThisAccountList) {
        balance += txn.amount;
      }
      return balance;
    } else {
      double balance = creditAccountDetails!.creditBalance;
      final txnList = creditSpendingTxnBacklinks.toList();
      for (CreditSpendingIsar txn in txnList) {
        if (!txn.isDone) {
          balance -= txn.amount - txn.paidAmount;
        }
      }
      return balance;
    }
  }
}

@Embedded()
class CreditAccountDetails {
  late double creditBalance;

  late DateTime statementDate;

  late DateTime paymentDueDate;
}
