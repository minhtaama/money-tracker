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

  /// Assign to `previousStatement` of the next Statement object
  PreviousStatement get carryToNextStatement;

  double getFullPaymentAmountAt(DateTime dateTime);

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

  const Statement({
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
  /// Assign to `previousStatement` of the next Statement object.
  ///
  /// This class is not meant to be created outside of this library
  const PreviousStatement._({
    required this.balance,
    required this.pendingForGracePeriod,
    required this.interest,
    required this.dueDate,
  });

  /// Can't be **negative**. This is the remaining amount of money that haven't been paid.
  ///
  /// Use to calculate interest and carry over amount to next statement
  final double balance;

  /// Can't be **negative**. Use to calculate what left to pay or has paid in next statement
  /// **after this statement's end date**. if value is more than 0,
  /// then there is balance (spending amount) left for grace period in next statement to pay.
  final double pendingForGracePeriod;

  final double interest;

  final DateTime dueDate;

  /// **Can't be negative**
  double get carryOverWithInterest => balance <= 0 ? 0 : balance + interest;

  factory PreviousStatement.noData() {
    return PreviousStatement._(balance: 0, pendingForGracePeriod: 0, interest: 0, dueDate: Calendar.minDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviousStatement &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          pendingForGracePeriod == other.pendingForGracePeriod &&
          interest == other.interest &&
          dueDate == other.dueDate;

  @override
  int get hashCode => balance.hashCode ^ pendingForGracePeriod.hashCode ^ interest.hashCode ^ dueDate.hashCode;
}
