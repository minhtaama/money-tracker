import 'package:flutter/material.dart';
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

  /// **Billing cycle**: From [startDate] to [endDate]
  final List<BaseCreditTransaction> transactionsInBillingCycle;

  /// **Grace Period**: From the day after [endDate] to [dueDate]
  final List<BaseCreditTransaction> transactionsInGracePeriod;

  final double _spentInPrvGracePeriod;
  final double _spentInBillingCycleAfterPrvGracePeriod;
  final double _spentInGracePeriod;
  final double _paidInPrvGracePeriodForCurStatement;
  final double _paidInPrvGracePeriodForPrvStatement;
  final double _paidInBillingCycleAfterPrvGracePeriod;
  final double _paidInGracePeriod;

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

  double getFullPaymentAmountAt(DateTime dateTime) {
    // Remaining spent amount after previous grace period that is left to this statement to pay
    final remainingSpentInPrvGracePeriod = math.max(0, _spentInPrvGracePeriod - _paidInPrvGracePeriodForCurStatement);

    double spentInBillingCycleAfterPrvGracePeriodBeforeDateTime = 0;
    double spentInGracePeriodBeforeDateTime = 0;

    for (BaseCreditTransaction txn in transactionsInGracePeriod) {
      if (txn is CreditSpending && txn.dateTime.onlyYearMonthDay.isBefore(dateTime)) {
        spentInGracePeriodBeforeDateTime += txn.amount;
      }
    }

    for (BaseCreditTransaction txn in transactionsInBillingCycle) {
      if (txn is CreditSpending &&
          txn.dateTime.onlyYearMonthDay.isBefore(dateTime) &&
          txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
        spentInBillingCycleAfterPrvGracePeriodBeforeDateTime += txn.amount;
      }
    }

    // Remaining balance before chosen dateTime
    final x = previousStatement.carryOver +
        remainingSpentInPrvGracePeriod +
        spentInBillingCycleAfterPrvGracePeriodBeforeDateTime +
        spentInGracePeriodBeforeDateTime -
        _paidInGracePeriod -
        _paidInBillingCycleAfterPrvGracePeriod;

    if (x < 0) {
      return 0;
    } else {
      return x;
    }
  }

  /// Assign to `previousStatement` of the next Statement object
  PreviousStatement get carryToNextStatement {
    // Remaining spent amount after previous grace period that is left to this statement to pay
    double remainingSpentInPrvGracePeriod = math.max(0, _spentInPrvGracePeriod - _paidInPrvGracePeriodForCurStatement);

    /// Remaining surplus payment amount after previous grace period count to this statement
    double remainingPaidInPreviousGracePeriod =
        math.max(0, _paidInPrvGracePeriodForCurStatement - _spentInPrvGracePeriod);

    // Total spent amount until this statement billing cycle end (until endDate)
    double totalSpent =
        previousStatement.carryOver + remainingSpentInPrvGracePeriod + _spentInBillingCycleAfterPrvGracePeriod;

    // Total payment amount in this billing cycle and the grace period.
    // This amount can be included the payment amount for spent of next statement
    // but inside this statement grace period.
    double totalPaid = remainingPaidInPreviousGracePeriod + _paidInBillingCycleAfterPrvGracePeriod + _paidInGracePeriod;

    // The spent amount that will be carried over to next statement.
    double balanceCarryToNextStatement = math.max(0, totalSpent - totalPaid);

    // Total payment amount until this statement billing cycle end (until endDate)
    double totalPaidBeforeEndDate = _paidInPrvGracePeriodForCurStatement + _paidInBillingCycleAfterPrvGracePeriod;

    double balanceAtEndDate = previousStatement.carryOver +
        _spentInPrvGracePeriod +
        _spentInBillingCycleAfterPrvGracePeriod -
        totalPaidBeforeEndDate;

    double interestCarryToNextStatement =
        balanceCarryToNextStatement > 0 || previousStatement.carryOver > 0 ? _interest : 0;

    return PreviousStatement._(
      balance: balanceCarryToNextStatement,
      balanceAtEndDate: balanceAtEndDate,
      interest: interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }

  factory Statement.create(
    StatementType type, {
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required int statementDay,
    required int paymentDueDay,
    required double apr,
    required List<BaseCreditTransaction> transactionsList,
  }) {
    return switch (type) {
      StatementType.withAverageDailyBalance => StatementWithAverageDailyBalance._create(
          previousStatement: previousStatement,
          startDate: startDate,
          statementDay: statementDay,
          paymentDueDay: paymentDueDay,
          apr: apr,
          transactionsList: transactionsList),
    };
  }

  const Statement(
    this._spentInPrvGracePeriod,
    this._spentInBillingCycleAfterPrvGracePeriod,
    this._spentInGracePeriod,
    this._paidInPrvGracePeriodForCurStatement,
    this._paidInPrvGracePeriodForPrvStatement,
    this._paidInBillingCycleAfterPrvGracePeriod,
    this._paidInGracePeriod, {
    required this.apr,
    required this.previousStatement,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.transactionsInBillingCycle,
    required this.transactionsInGracePeriod,
  });
}

@immutable
class PreviousStatement {
  /// Can't be **negative**. This is the remaining amount of money that haven't been paid
  /// at the end of previous statement's grace period
  ///
  /// No interest included. If value is more than 0, then there is balance (spending amount)
  /// left for next statement to pay, and the interest will be included in `carryOver`.
  final double balance;

  /// Can't be **negative**. This is the remaining amount of money that haven't been paid
  /// at the end of billing cycle. Use to calculate what left to pay in the grace period
  /// of previous statement in current statement.
  ///
  /// If value is more than 0,
  /// then there is balance (spending amount) left for grace period in next statement to pay.
  final double balanceAtEndDate;

  final double interest;

  final DateTime dueDate;

  /// **Can't be negative**
  double get carryOver => balance <= 0 ? 0 : balance + interest;

  factory PreviousStatement.noData() {
    return PreviousStatement._(balance: 0, balanceAtEndDate: 0, interest: 0, dueDate: Calendar.minDate);
  }

  /// Assign to `previousStatement` of the next Statement object.
  ///
  /// This class is not meant to be created outside of this library
  const PreviousStatement._({
    required this.balance,
    required this.balanceAtEndDate,
    required this.interest,
    required this.dueDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviousStatement &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          balanceAtEndDate == other.balanceAtEndDate &&
          interest == other.interest &&
          dueDate == other.dueDate;

  @override
  int get hashCode => balance.hashCode ^ balanceAtEndDate.hashCode ^ interest.hashCode ^ dueDate.hashCode;
}
