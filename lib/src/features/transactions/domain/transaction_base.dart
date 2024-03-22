import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../persistent/realm_dto.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';

part 'regular_transaction.dart';
part 'credit_transaction.dart';

abstract interface class ITransferable {
  final AccountInfo transferAccount;

  ITransferable(this.transferAccount);
}

@immutable
abstract interface class IBaseTransactionWithCategory {
  final Category? _category;
  final CategoryTag? categoryTag;

  Category get category => _category != null ? _category! : DeletedCategory();

  const IBaseTransactionWithCategory(
    this._category,
    this.categoryTag,
  );
}

@immutable
sealed class BaseTransaction extends BaseModel<TransactionDb> {
  final DateTime dateTime;
  final double amount;
  final String? note;

  final AccountInfo? _account;

  AccountInfo get account => _account != null ? _account! : DeletedAccount();

  const BaseTransaction(
    super._databaseObject,
    this.dateTime,
    this.amount,
    this.note,
    this._account,
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
          Account.fromDatabaseInfoOnly(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
        );

      case TransactionType.income:
        return Income._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseInfoOnly(txn.account),
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
          Account.fromDatabaseInfoOnly(txn.account),
          transferAccount: Account.fromDatabaseInfoOnly(txn.transferAccount) as RegularAccountInfo?,
          fee: Fee._fromDatabase(txn),
        );

      case TransactionType.creditSpending:
        return CreditSpending._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseInfoOnly(txn.account),
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
          Account.fromDatabaseInfoOnly(txn.account),
          transferAccount: Account.fromDatabaseInfoOnly(txn.transferAccount) as RegularAccountInfo?,
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
          Account.fromDatabaseInfoOnly(txn.account),
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
