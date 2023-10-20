import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;

import '../../../utils/constants.dart';
import '../../transactions/domain/transaction_base.dart';
import 'account_base.dart';

@immutable
class Statement {
  const Statement._(
      this._creditAccount,
      this.previousStatement,
      this.startDate,
      this.endDate,
      this.dueDate,
      this.txnsFromBeginToDueDate,
      this.txnsOfThisStatement,
      this.spentAmount,
      this.paidAmount);

  final CreditAccount _creditAccount;

  final PreviousStatement previousStatement;

  final DateTime startDate;

  final DateTime endDate;

  final DateTime dueDate;

  /// Include [CreditSpending] of next statement, but happens between
  /// this statement `endDate` and `dueDate`.
  final List<BaseCreditTransaction> txnsFromBeginToDueDate;

  /// Returns [CreditSpending] between `startDate` and `endDate`.
  ///
  /// Returns [CreditPayment] between `startDate` and `dueDate`
  final List<BaseCreditTransaction> txnsOfThisStatement;

  /// Only counts [CreditSpending] between/in [startDate] to/and in [endDate]
  final double spentAmount;

  /// Excluded surplus payment amount of last statement and next statement if there are
  /// payments transactions happens "not after [previousStatement.dueDate]" and "after [endDate]"
  /// of this statement.
  ///
  /// Counts [CreditPayment] between/in [startDate] to/and in [dueDate]
  final double paidAmount;

  factory Statement.create(
    CreditAccount creditAccount, {
    required PreviousStatement previousStatement,
    required DateTime startDate,
  }) {
    final DateTime endDate =
        startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;

    final DateTime dueDate = creditAccount.statementDay >= creditAccount.paymentDueDay
        ? startDate
            .copyWith(month: startDate.month + 2, day: creditAccount.paymentDueDay)
            .onlyYearMonthDay
        : startDate
            .copyWith(month: startDate.month + 1, day: creditAccount.paymentDueDay)
            .onlyYearMonthDay;

    List<BaseCreditTransaction> txnsFromBeginToDueDate = List.empty(growable: true);
    List<BaseCreditTransaction> txnsOfThisStatement = List.empty(growable: true);

    double spentAmount = 0;

    double paidAmount = 0;

    for (int i = 0; i <= creditAccount.transactionsList.length - 1; i++) {
      final txn = creditAccount.transactionsList[i];

      if (txn.dateTime.isBefore(startDate)) {
        continue;
      }

      if (txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        break;
      }

      if (!txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        txnsFromBeginToDueDate.add(txn);
      }

      if (txn is CreditSpending && txn.dateTime.isBefore(endDate)) {
        txnsOfThisStatement.add(txn);
        spentAmount += txn.amount;
        continue;
      }

      if (txn is CreditPayment) {
        txnsOfThisStatement.add(txn);
        paidAmount += txn.amount;
        continue;
      }
    }

    return Statement._(creditAccount, previousStatement, startDate, endDate, dueDate,
        txnsFromBeginToDueDate, txnsOfThisStatement, spentAmount, paidAmount);
  }
}

@immutable
class PreviousStatement {
  const PreviousStatement._(this.balance, this.interest, this.dueDate);

  /// Can be **negative** if payments after [endDate] is also
  /// paid for [CreditSpending] of next statement
  final double balance;
  final double interest;
  final DateTime dueDate;

  /// Can't be negative
  double get carryToThisStatement => balance > 0 ? balance + interest : 0;

  factory PreviousStatement.noData() {
    return PreviousStatement._(0, 0, Calendar.minDate);
  }
}

// https://www.youtube.com/watch?v=SnlHbMIWJak
extension StatementDetails on Statement {
  double get averageDailyBalance {
    double sum = 0;
    DateTime prvDateTime = startDate;
    double balance = previousStatement.carryToThisStatement;

    for (int i = 0; i <= txnsFromBeginToDueDate.length - 1; i++) {
      final transaction = txnsFromBeginToDueDate[i];

      sum += balance * prvDateTime.getDaysDifferent(transaction.dateTime);

      if (transaction is CreditSpending) {
        balance += transaction.amount;
      }
      if (transaction is CreditPayment) {
        balance -= transaction.amount;
      }

      prvDateTime = transaction.dateTime;
    }

    if (txnsFromBeginToDueDate.isNotEmpty) {
      sum += balance * txnsFromBeginToDueDate.last.dateTime.getDaysDifferent(endDate);
    } else {
      sum += balance * startDate.getDaysDifferent(endDate);
    }

    return sum / startDate.getDaysDifferent(endDate);
  }

  double get interest {
    if (remainingBalance <= 0) {
      return 0;
    }
    final interest =
        averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);
    return interest;
  }

  double get remainingBalance {
    double result = previousStatement.carryToThisStatement + spentAmount - paidAmount;
    if (result < 0) {
      return 0;
    }
    return result;
  }

  /// Assign to `carryingOver` of the next Statement object
  PreviousStatement get carryToNextStatement => PreviousStatement._(
      previousStatement.carryToThisStatement + spentAmount - paidAmount, interest, dueDate);
}

extension StatementAtDateTimeDetails on Statement {
  /// Hard upper gap at this statement [endDate].
  List<BaseCreditTransaction> txnsFromStartDateBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= txnsFromBeginToDueDate.length - 1; i++) {
      final txn = txnsFromBeginToDueDate[i];

      if (txn.dateTime.isAfter(endDate.copyWith(day: endDate.day + 1))) {
        break;
      }

      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
        continue;
      }
    }

    return list;
  }

  /// Hard upper gap at this statement [dueDate]
  List<BaseCreditTransaction> txnsFromEndDateBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in txnsFromBeginToDueDate) {
      if (txn.dateTime.isBefore(endDate)) {
        continue;
      }

      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
        continue;
      }
    }

    return list;
  }

  List<BaseCreditTransaction> txnsIn(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);
    for (BaseCreditTransaction txn in txnsFromBeginToDueDate) {
      if (txn.dateTime.onlyYearMonthDay.isAtSameMomentAs(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }
    return list;
  }

  double spentAmountFromEndDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsFromEndDateBefore(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double spentAmountFromStartDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsFromStartDateBefore(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double paidAmountFromEndDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsFromEndDateBefore(dateTime).whereType<CreditPayment>();
    for (CreditPayment txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double paidAmountFromStartDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsFromStartDateBefore(dateTime).whereType<CreditPayment>();
    for (CreditPayment txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double getFullPaymentAmountAt(DateTime dateTime) {
    // Remaining balance before chosen dateTime
    final x = previousStatement.balance +
        spentAmountFromStartDateBefore(dateTime) +
        spentAmountFromEndDateBefore(dateTime) -
        paidAmountFromEndDateBefore(dueDate) -
        paidAmountFromStartDateBefore(dueDate);

    if (x < 0) {
      return 0;
    } else {
      return x;
    }
  }
}
