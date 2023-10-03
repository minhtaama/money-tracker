import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';

// TODO: Change to realm
import '../../category/domain/category_x.dart';
import '../../category/domain/category_tag_x.dart';
import '../data/isar_dto/transaction_isar.dart';

part 'regular_transaction.dart';
part 'credit_payment_transaction.dart';
part 'credit_spending_transaction.dart';

@immutable
sealed class Transaction extends IsarModel<TransactionIsar> {
  final DateTime dateTime;
  final double amount;
  final String? note;
  abstract final Account? account;

  const Transaction(
    super._isarObject,
    this.dateTime,
    this.amount,
    this.note,
  );

  factory Transaction.fromIsar(TransactionIsar txn) {
    switch (txn.transactionType) {
      case TransactionType.income:
        return Income._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          Account.fromIsar(txn.accountLink.value) as RegularAccount?,
          Category.fromIsar(txn.categoryLink.value),
          CategoryTag.fromIsar(txn.categoryTagLink.value),
          isInitialTransaction: txn.isInitialTransaction,
        );

      case TransactionType.expense:
        return Expense._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          Account.fromIsar(txn.accountLink.value) as RegularAccount?,
          Category.fromIsar(txn.categoryLink.value),
          CategoryTag.fromIsar(txn.categoryTagLink.value),
        );

      case TransactionType.transfer:
        return Transfer._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          Account.fromIsar(txn.accountLink.value) as RegularAccount?,
          toAccount: Account.fromIsar(txn.toAccountLink.value) as RegularAccount?,
          fee: Fee._fromIsar(txn),
        );

      case TransactionType.creditSpending:
        return CreditSpending._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          Category.fromIsar(txn.categoryLink.value),
          CategoryTag.fromIsar(txn.categoryTagLink.value),
          account: Account.fromIsar(txn.accountLink.value) as CreditAccount?,
          //payments: payments,
          installmentAmount: txn.installmentAmount,
        );

      case TransactionType.creditPayment:
        return CreditPayment._(
          txn,
          txn.dateTime,
          txn.amount,
          txn.note,
          account: Account.fromIsar(txn.accountLink.value),
          toCreditAccount: Account.fromIsar(txn.toAccountLink.value) as CreditAccount,
        );
    }
  }
}

@immutable
interface class TransactionWithCategory {
  final Category? category;
  final CategoryTag? categoryTag;

  const TransactionWithCategory(
    this.category,
    this.categoryTag,
  );
}
