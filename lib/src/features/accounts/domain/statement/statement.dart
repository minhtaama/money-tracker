import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;
import '../../../../utils/constants.dart';
import '../../../transactions/domain/transaction_base.dart';
part 'statement_for_interest_by_ADB.dart';

@immutable
abstract class Statement {
  final double apr;
  final PreviousStatement previousStatement;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate;

  /// Installment transactions happens before this statement, but need to pay at this statement
  final List<CreditSpending> installmentTransactionsToPay;

  /// **Billing cycle**: From [startDate] to [endDate]
  final List<BaseCreditTransaction> transactionsInBillingCycle;

  /// **Grace Period**: From the day after [endDate] to [dueDate]
  final List<BaseCreditTransaction> transactionsInGracePeriod;

  final double _totalSpentInBillingCycle;
  final double _spentInBillingCycleExcludeInstallments;
  final double _paidInBillingCycle;
  final double _paidInGracePeriod;

  /// This is the interest of this statement, only add this value to next statement
  /// if this statement is not paid in full or previous statement has a carry over amount.
  abstract final double _interest;

  /// BillingCycle is only from [startDate] to [endDate].
  List<BaseCreditTransaction> transactionsInBillingCycleBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in transactionsInBillingCycle) {
      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }

    return list;
  }

  /// BillingCycle is only from [endDate] to [dueDate].
  ///
  /// If `dateTime` is before grace period, value returned is an empty list
  List<BaseCreditTransaction> transactionsInGracePeriodBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in transactionsInGracePeriod) {
      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }

    return list;
  }

  List<BaseCreditTransaction> transactionsIn(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    final txnList = dateTime.onlyYearMonthDay.isAfter(endDate) ? transactionsInGracePeriod : transactionsInBillingCycle;

    for (BaseCreditTransaction txn in txnList) {
      if (txn.dateTime.onlyYearMonthDay.isAtSameMomentAs(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }
    return list;
  }

  double get installmentsAmountToPay {
    double amount = 0;
    for (CreditSpending txn in installmentTransactionsToPay) {
      amount += txn.paymentAmount;
    }
    return amount;
  }

  double getFullPaymentAmountAt(DateTime dateTime, {required bool withDecimalDigits}) {
    double spentInBillingCycleBeforeDateTimeExcludeInstallments = 0;
    double spentInGracePeriodBeforeDateTimeExcludeInstallments = 0;

    for (BaseCreditTransaction txn in transactionsInGracePeriod) {
      if (txn is CreditSpending &&
          !txn.hasInstallment &&
          txn.dateTime.onlyYearMonthDay.isBefore(dateTime.onlyYearMonthDay)) {
        spentInGracePeriodBeforeDateTimeExcludeInstallments += txn.amount;
      }
    }

    for (BaseCreditTransaction txn in transactionsInBillingCycle) {
      if (txn is CreditSpending &&
          !txn.hasInstallment &&
          txn.dateTime.onlyYearMonthDay.isBefore(dateTime.onlyYearMonthDay)) {
        spentInBillingCycleBeforeDateTimeExcludeInstallments += txn.amount;
      }
    }

    // Remaining balance before chosen dateTime
    final x = previousStatement._balanceToPayAtEndDate +
        previousStatement.interest +
        installmentsAmountToPay +
        spentInBillingCycleBeforeDateTimeExcludeInstallments +
        spentInGracePeriodBeforeDateTimeExcludeInstallments -
        _paidInGracePeriod -
        _paidInBillingCycle;

    if (x < 0) {
      return 0;
    } else {
      return withDecimalDigits ? CalService.formatToDouble(x.toStringAsFixed(2))! : x.roundToDouble();
    }
  }

  /// Assign to `previousStatement` of the next Statement object
  PreviousStatement get carryToNextStatement {
    double balanceAtEndDate = previousStatement._balanceAtEndDate +
        previousStatement.interest +
        _totalSpentInBillingCycle -
        _paidInBillingCycle;

    double balance = previousStatement._balanceAtEndDate +
        previousStatement.interest +
        _totalSpentInBillingCycle -
        _paidInBillingCycle -
        _paidInGracePeriod;

    double balanceToPayAtEndDate = previousStatement._balanceToPayAtEndDate +
        previousStatement.interest +
        installmentsAmountToPay +
        _spentInBillingCycleExcludeInstallments -
        _paidInBillingCycle;

    double balanceToPay = previousStatement._balanceToPayAtEndDate +
        previousStatement.interest +
        installmentsAmountToPay +
        _spentInBillingCycleExcludeInstallments -
        _paidInBillingCycle -
        _paidInGracePeriod;

    double interestCarryToNextStatement = balanceToPay > 0 || previousStatement.balanceToPay > 0 ? _interest : 0;

    return PreviousStatement._(
      balanceToPayAtEndDate,
      balanceAtEndDate,
      balance: math.max(0, balance),
      balanceToPay: math.max(0, balanceToPay),
      interest: interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }

  factory Statement.create(
    StatementType type, {
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime dueDate,
    required double apr,
    required List<CreditSpending> installmentTransactionsToPay,
    required List<BaseCreditTransaction> txnsInBillingCycle,
    required List<BaseCreditTransaction> txnsInGracePeriod,
  }) {
    return switch (type) {
      StatementType.withAverageDailyBalance => StatementWithAverageDailyBalance._create(
          previousStatement: previousStatement,
          startDate: startDate,
          endDate: endDate,
          dueDate: dueDate,
          apr: apr,
          installmentTransactionsToPay: installmentTransactionsToPay,
          txnsInBillingCycle: txnsInBillingCycle,
          txnsInGracePeriod: txnsInGracePeriod),
    };
  }

  const Statement(
    this._totalSpentInBillingCycle,
    this._spentInBillingCycleExcludeInstallments,
    this._paidInBillingCycle,
    this._paidInGracePeriod, {
    required this.apr,
    required this.previousStatement,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.installmentTransactionsToPay,
    required this.transactionsInBillingCycle,
    required this.transactionsInGracePeriod,
  });
}

@immutable
class PreviousStatement {
  /// Can't be **negative**. Use to get the remaining amount needed to pay carry to current statement.
  /// This previous statement only carry interest if this value is more than 0.
  /// ---
  /// = **previousStatement._balanceToPayAtEndDate** + **previousStatement.interest** +
  ///
  /// **the payment needed of all installments before** +
  ///
  /// **spent amount happens in billing cycle** (excluded installments transaction) -
  ///
  /// **paid amount happens in billing cycle and in grace period (included pay for spent in current statement)**.
  /// ---
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceToPayAtEndDate**, so no transaction
  /// is counted twice.
  final double balanceToPay;

  /// Can't be **negative**, no interest included. Use as the balance to pay at the start date
  /// of current statement.
  /// ---
  /// = **previousStatement._balanceToPayAtEndDate** + **previousStatement.interest** +
  ///
  /// **spent amount happens in billing cycle** (included installments transaction) -
  ///
  /// **paid amount happens in billing cycle**.
  /// ---
  /// The math should not be less than 0. However if so, return 0.
  final double _balanceToPayAtEndDate;

  /// Can't be **negative**. Use to calculate the interest of this previous statement.
  /// ---
  /// = **previousStatement._balanceAtEndDate** + **previousStatement.interest** +
  ///
  /// **spent amount happens in billing cycle** (included installments transaction) -
  ///
  /// **paid amount happens in billing cycle and in grace period (included pay for spent in current statement)**.
  /// ---
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceAtEndDate**, so no transaction
  /// is counted twice.
  final double balance;

  /// Can't be **negative**, no interest included. Use as the credit balance at the start date
  /// of current statement.
  /// ---
  /// = **previousStatement._balanceAtEndDate** + **previousStatement.interest** +
  ///
  /// **spent amount happens in billing cycle** (included installments transaction) -
  ///
  /// **paid amount happens in billing cycle**.
  /// ---
  /// The math should not be less than 0. However if so, return 0.
  final double _balanceAtEndDate;

  /// Only charge/carry interest if `balanceToPay` is more than 0.
  final double interest;

  /// Use for checking if can add payments
  final DateTime dueDate;

  factory PreviousStatement.noData() {
    return PreviousStatement._(0, 0, balanceToPay: 0, balance: 0, interest: 0, dueDate: Calendar.minDate);
  }

  /// Assign to `previousStatement` of the next Statement object.
  ///
  /// This class is not meant to be created outside of this library
  const PreviousStatement._(
    this._balanceToPayAtEndDate,
    this._balanceAtEndDate, {
    required this.balanceToPay,
    required this.balance,
    required this.interest,
    required this.dueDate,
  });
}
