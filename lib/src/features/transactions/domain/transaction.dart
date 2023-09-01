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

  Transaction(
    super.id,
    this.dateTime,
    this.amount,
    this.account,
    this.note,
  );

  factory Transaction.fromIsar(TransactionIsar txn) {
    switch (txn.transactionType) {
      case TransactionType.income:
        return Income._internal(
          txn.id,
          txn.dateTime,
          txn.amount,
          txn.accountLink.value,
          txn.note,
          isInitialTransaction: txn.isInitialTransaction,
          category: txn.categoryLink.value,
          categoryTag: txn.categoryTagLink.value,
        );

      case TransactionType.expense:
        return Expense._internal(
          txn.id,
          txn.dateTime,
          txn.amount,
          txn.accountLink.value,
          txn.note,
          category: txn.categoryLink.value,
          categoryTag: txn.categoryTagLink.value,
        );

      case TransactionType.transfer:
        return Transfer._internal(
          txn.id,
          txn.dateTime,
          txn.amount,
          txn.accountLink.value,
          txn.note,
          toAccount: txn.toAccountLink.value,
          fee: Fee.fromIsar(txn),
        );

      case TransactionType.creditSpending:
        final payments = <CreditPayment>[];
        for (TransactionIsar txn in txn.paymentTxnBacklinks.toList()) {
          payments.add(Transaction.fromIsar(txn) as CreditPayment);
        }
        return CreditSpending._internal(
          txn.id,
          txn.dateTime,
          txn.amount,
          txn.accountLink.value,
          txn.note,
          category: txn.categoryLink.value,
          categoryTag: txn.categoryTagLink.value,
          payments: payments,
          installment: Installment.fromIsar(txn),
        );

      case TransactionType.creditPayment:
        return CreditPayment._internal(
          txn.id,
          txn.dateTime,
          txn.amount,
          txn.accountLink.value,
          txn.note,
          spendingTxn: Transaction.fromIsar(txn.spendingTxnLink.value!) as CreditSpending,
        );
    }
  }
}

class Expense extends Transaction {
  final Category? category;
  final CategoryTag? categoryTag;

  Expense._internal(
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

  Income._internal(
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

  Transfer._internal(
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

  CreditSpending._internal(
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

  CreditPayment._internal(
    super.id,
    super.dateTime,
    super.amount,
    super.account,
    super.note, {
    required this.spendingTxn,
  });
}

class Fee {
  final double amount;
  final bool onDestination;

  static Fee? fromIsar(TransactionIsar txn) {
    if (txn.transferFeeIsar == null) {
      return null;
    }
    return Fee._internal(txn.transferFeeIsar!.amount, txn.transferFeeIsar!.onDestination);
  }

  Fee._internal(this.amount, this.onDestination);
}

class Installment {
  final double amount;

  final double interestRate;

  final bool rateOnRemaining;

  static Installment? fromIsar(TransactionIsar txn) {
    if (txn.installmentIsar == null) {
      return null;
    }
    return Installment._internal(txn.installmentIsar!.amount, txn.installmentIsar!.interestRate,
        txn.installmentIsar!.rateOnRemaining);
  }

  Installment._internal(this.amount, this.interestRate, this.rateOnRemaining);
}
