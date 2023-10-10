import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
part 'regular_transaction.dart';
part 'credit_transaction.dart';

@immutable
sealed class BaseTransaction extends BaseModel<TransactionDb> {
  final DateTime dateTime;
  final double amount;
  final String? note;
  final ObjectId? account;

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
          txn.dateTime,
          txn.amount,
          txn.note,
          txn.account?.id,
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          isInitialTransaction: txn.isInitialTransaction,
        );

      case 0:
        return Expense._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          txn.account?.id,
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
        );

      case 2:
        return Transfer._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          txn.account?.id,
          toAccount: Account.fromDatabase(txn.transferAccount) as RegularAccount?,
          fee: Fee._fromDatabase(txn),
        );

      case 3:
        return CreditSpending._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          txn.account?.id,
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          //payments: payments,
          installmentAmount: txn.installmentAmount,
        );

      default:
        return CreditPayment._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          txn.account?.id,
          fromRegularAccount: Account.fromDatabase(txn.transferAccount) as CreditAccount,
        );
    }
  }
}

@immutable
interface class BaseTransactionWithCategory {
  final Category? category;
  final CategoryTag? categoryTag;

  // TODO: Change all to ObjectID, prevent stack overflow, must get model from repository

  const BaseTransactionWithCategory(
    this.category,
    this.categoryTag,
  );
}
