import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../../../../persistent/realm_dto.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';

part 'regular_transaction.dart';
part 'credit_transaction.dart';

abstract interface class ITransferable {
  final RegularAccountInfo? transferAccount;

  ITransferable(this.transferAccount);
}

@immutable
abstract interface class IBaseTransactionWithCategory {
  final Category? category;
  final CategoryTag? categoryTag;

  const IBaseTransactionWithCategory(
    this.category,
    this.categoryTag,
  );
}

@immutable
sealed class BaseTransaction extends BaseModel<TransactionDb> {
  final DateTime dateTime;
  final double amount;
  final String? note;
  final AccountInfo? account;

  const BaseTransaction(
    super._databaseObject,
    this.dateTime,
    this.amount,
    this.note,
    this.account,
  );

  factory BaseTransaction.fromDatabase(TransactionDb txn) {
    TransactionType type = TransactionType.fromDatabaseValue(txn.type);

    switch (type) {
      case TransactionType.expense:
        return Expense._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
        );

      case TransactionType.income:
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

      case TransactionType.transfer:
        return Transfer._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          transferAccount: Account.fromDatabaseWithNoDetails(txn.transferAccount) as RegularAccountInfo,
          fee: Fee._fromDatabase(txn),
        );

      case TransactionType.creditSpending:
        return CreditSpending._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          //payments: payments,
          monthsToPay: txn.creditInstallmentDetails?.monthsToPay,
          paymentAmount: txn.creditInstallmentDetails?.paymentAmount,
        );

      case TransactionType.creditPayment:
        return CreditPayment._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          transferAccount: Account.fromDatabaseWithNoDetails(txn.transferAccount) as RegularAccountInfo?,
          isFullPayment: txn.creditPaymentDetails!.isFullPayment,
          isAdjustToAPRChange: txn.creditPaymentDetails!.isAdjustToAPRChanges,
          adjustment: txn.creditPaymentDetails!.adjustment,
        );

      case TransactionType.creditCheckpoint:
        return CreditCheckpoint._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          finishedInstallments: [
            for (TransactionDb el in txn.creditCheckpointFinishedInstallments)
              BaseTransaction.fromDatabase(el) as CreditSpending
          ],
        );
      case TransactionType.installmentToPay:
        throw StateError('Can not return from this TransactionType');
    }
  }
}
