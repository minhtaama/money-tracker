import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import '../../../../persistent/realm_dto.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
part 'regular_transaction.dart';
part 'credit_transaction.dart';

abstract interface class ITransferable {
  final RegularAccount? transferAccount;

  ITransferable(this.transferAccount);
}

@immutable
sealed class BaseTransaction extends BaseModel<TransactionDb> {
  final DateTime dateTime;
  final double amount;
  final String? note;
  final Account? account;

  const BaseTransaction(
    super._databaseObject,
    this.dateTime,
    this.amount,
    this.note,
    this.account,
  );

  factory BaseTransaction.fromDatabase(TransactionDb txn) {
    switch (txn.type) {
      case 1:
        return Income._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          isInitialTransaction: txn.isInitialTransaction,
        );

      case 0:
        return Expense._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
        );

      case 2:
        return Transfer._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          transferAccount: Account.fromDatabaseWithNoDetails(txn.transferAccount) as RegularAccount,
          fee: Fee._fromDatabase(txn),
        );

      case 3:
        return CreditSpending._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          //payments: payments,
          monthsToPay: txn.creditPaymentDetails?.monthsToPay,
          paymentAmount: txn.creditPaymentDetails?.paymentAmount,
        );

      case 4:
        return CreditPayment._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          transferAccount: Account.fromDatabaseWithNoDetails(txn.transferAccount) as RegularAccount,
        );

      default:
        return CreditCheckpoint._(txn, txn.dateTime.toLocal(), txn.amount, txn.note,
            Account.fromDatabaseWithNoDetails(txn.account),
            finishedInstallments: [
              for (TransactionDb el in txn.creditCheckpointFinishedInstallments)
                BaseTransaction.fromDatabase(el) as CreditSpending
            ]);
    }
  }
}

@immutable
interface class BaseTransactionWithCategory {
  final Category? category;
  final CategoryTag? categoryTag;

  const BaseTransactionWithCategory(
    this.category,
    this.categoryTag,
  );
}
