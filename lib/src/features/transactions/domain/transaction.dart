import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_domain.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../data/isar_dto/transaction_isar.dart';

@immutable
abstract class Transaction extends IsarDomain {
  final DateTime dateTime;
  final double amount;
  final String? note;
  final Account? account;

  const Transaction(
    super.id,
    this.dateTime,
    this.amount,
    this.account,
    this.note,
  );

  factory Transaction.fromIsar(TransactionIsar txn) {
    switch (txn.transactionType) {
      case TransactionType.income:
        return Income._(
          txn.id,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          isInitialTransaction: txn.isInitialTransaction,
          category: Category.fromIsar(txn.categoryLink.value),
          categoryTag: CategoryTag.fromIsar(txn.categoryTagLink.value),
        );

      case TransactionType.expense:
        return Expense._(
          txn.id,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          category: Category.fromIsar(txn.categoryLink.value),
          categoryTag: CategoryTag.fromIsar(txn.categoryTagLink.value),
        );

      case TransactionType.transfer:
        return Transfer._(
          txn.id,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          toAccount: Account.fromIsar(txn.toAccountLink.value),
          fee: Fee.fromIsar(txn),
        );

      case TransactionType.creditSpending:
        final payments = <CreditPayment>[];
        for (TransactionIsar txn in txn.paymentTxnBacklinks.toList()) {
          payments.add(Transaction.fromIsar(txn) as CreditPayment);
        }
        return CreditSpending._(
          txn.id,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          category: Category.fromIsar(txn.categoryLink.value),
          categoryTag: CategoryTag.fromIsar(txn.categoryTagLink.value),
          payments: payments,
          installment: Installment.fromIsar(txn),
        );

      case TransactionType.creditPayment:
        return CreditPayment._(
          txn.id,
          txn.dateTime,
          txn.amount,
          Account.fromIsar(txn.accountLink.value),
          txn.note,
          spendingTxn: Transaction.fromIsar(txn.spendingTxnLink.value!) as CreditSpending,
        );
    }
  }
}

class Expense extends Transaction {
  final Category? category;
  final CategoryTag? categoryTag;

  const Expense._(
    super.id,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.category,
    required this.categoryTag,
  });
}

class Income extends Transaction {
  final Category? category;
  final CategoryTag? categoryTag;
  final bool isInitialTransaction;

  const Income._(
    super.id,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.isInitialTransaction,
    required this.category,
    required this.categoryTag,
  });
}

class Transfer extends Transaction {
  final Account? toAccount;
  final Fee? fee;

  const Transfer._(
    super.id,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.toAccount,
    required this.fee,
  });
}

class CreditSpending extends Transaction {
  final Category? category;
  final CategoryTag? categoryTag;
  final List<CreditPayment> payments;
  final Installment? installment;

  bool get isDone {
    return paidAmount <= 0;
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
    super.id,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.category,
    required this.categoryTag,
    required this.payments,
    required this.installment,
  });
}

class CreditPayment extends Transaction {
  final CreditSpending spendingTxn;

  const CreditPayment._(
    super.id,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.spendingTxn,
  });
}

@immutable
class Fee {
  final double amount;
  final bool onDestination;

  static Fee? fromIsar(TransactionIsar txn) {
    if (txn.transferFeeIsar == null) {
      return null;
    }
    return Fee._(txn.transferFeeIsar!.amount, txn.transferFeeIsar!.onDestination);
  }

  const Fee._(this.amount, this.onDestination);
}

@immutable
class Installment {
  final double amount;

  final double interestRate;

  final bool rateOnRemaining;

  static Installment? fromIsar(TransactionIsar txn) {
    if (txn.installmentIsar == null) {
      return null;
    }
    return Installment._(txn.installmentIsar!.amount, txn.installmentIsar!.interestRate,
        txn.installmentIsar!.rateOnRemaining);
  }

  const Installment._(this.amount, this.interestRate, this.rateOnRemaining);
}
