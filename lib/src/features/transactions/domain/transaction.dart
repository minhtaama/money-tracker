import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../data/isar_dto/transaction_isar.dart';

@immutable
sealed class Transaction extends IsarModel<TransactionIsar> {
  final DateTime dateTime;
  final double amount;
  final String? note;
  final Account? account;

  const Transaction(
    super._isarObject,
    this.dateTime,
    this.amount,
    this.account,
    this.note,
  );

  factory Transaction.fromIsar(TransactionIsar txn) {
    switch (txn.transactionType) {
      case TransactionType.income:
        return Income._(
          txn,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          Category.fromIsar(txn.categoryLink.value),
          CategoryTag.fromIsar(txn.categoryTagLink.value),
          isInitialTransaction: txn.isInitialTransaction,
        );

      case TransactionType.expense:
        return Expense._(
          txn,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          Category.fromIsar(txn.categoryLink.value),
          CategoryTag.fromIsar(txn.categoryTagLink.value),
        );

      case TransactionType.transfer:
        return Transfer._(
          txn,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          toAccount: Account.fromIsar(txn.toAccountLink.value),
          fee: Fee._fromIsar(txn),
        );

      case TransactionType.creditSpending:
        final payments = <CreditPayment>[];
        for (TransactionIsar txn in txn.paymentTxnBacklinks.toList()) {
          payments.add(Transaction.fromIsar(txn) as CreditPayment);
        }
        return CreditSpending._(
          txn,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          Category.fromIsar(txn.categoryLink.value),
          CategoryTag.fromIsar(txn.categoryTagLink.value),
          payments: payments,
          installment: Installment._fromIsar(txn),
        );

      case TransactionType.creditPayment:
        return CreditPayment._(
          txn,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
        );
    }
  }
}

@immutable
sealed class TransactionWithCategory extends Transaction {
  final Category? category;
  final CategoryTag? categoryTag;

  const TransactionWithCategory(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.account,
    super.note,
    this.category,
    this.categoryTag,
  );
}

@immutable
class Expense extends TransactionWithCategory {
  const Expense._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.account,
    super.note,
    super.category,
    super.categoryTag,
  );
}

@immutable
class Income extends TransactionWithCategory {
  final bool isInitialTransaction;

  const Income._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.account,
    super.note,
    super.category,
    super.categoryTag, {
    required this.isInitialTransaction,
  });
}

@immutable
class Transfer extends Transaction {
  final Account? toAccount;
  final Fee? fee;

  const Transfer._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.toAccount,
    required this.fee,
  });
}

@immutable
class CreditSpending extends TransactionWithCategory {
  final List<CreditPayment> payments;
  final Installment? installment;

  bool get isDone {
    return paidAmount >= amount;
  }

  bool get hasInstallment {
    return installment != null;
  }

  double get paidAmount {
    double paidAmount = 0;
    for (CreditPayment txn in payments) {
      paidAmount += txn.amount;
    }
    return paidAmount;
  }

  double get pendingPayment {
    if (hasInstallment) {
      return min(amount - paidAmount, installment!.amount);
    } else {
      return amount - paidAmount;
    }
  }

  const CreditSpending._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.account,
    super.note,
    super.category,
    super.categoryTag, {
    required this.payments,
    required this.installment,
  });
}

@immutable
class CreditPayment extends Transaction {
  const CreditPayment._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.account,
    super.note,
  );
}

@immutable
class Fee {
  final double amount;
  final bool onDestination;

  static Fee? _fromIsar(TransactionIsar txn) {
    if (txn.transferFeeIsar == null) {
      return null;
    }
    return Fee(txn.transferFeeIsar!.amount, txn.transferFeeIsar!.onDestination);
  }

  const Fee(this.amount, this.onDestination);
}

@immutable
class Installment {
  final double amount;

  final double interestRate;

  final bool rateOnRemaining;

  static Installment? _fromIsar(TransactionIsar txn) {
    if (txn.installmentIsar == null) {
      return null;
    }
    return Installment(txn.installmentIsar!.amount, txn.installmentIsar!.interestRate,
        txn.installmentIsar!.rateOnRemaining);
  }

  const Installment(this.amount, this.interestRate, this.rateOnRemaining);
}
