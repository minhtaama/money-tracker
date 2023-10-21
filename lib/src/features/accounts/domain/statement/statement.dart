import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;

import '../../../../utils/constants.dart';
import '../../../transactions/domain/transaction_base.dart';
import '../account_base.dart';

part 'previous_statement.dart';

@immutable
class Statement {
  const Statement._(
    this._creditAccount,
    this._spentInPreviousGracePeriod,
    this._spentInBillingCycleAfterPreviousGracePeriod,
    this._spentInGracePeriod,
    this._paidInPreviousGracePeriodForThisStatement,
    this._paidInPreviousGracePeriodForPreviousPending,
    this._paidInBillingCycleAfterPreviousGracePeriod,
    this._paidInGracePeriod, {
    required this.previousStatement,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.transactionsInBillingCycle,
    required this.transactionsInGracePeriod,
    required this.averageDailyBalance,
  });

  final CreditAccount _creditAccount;

  final PreviousStatement previousStatement;

  final DateTime startDate;

  final DateTime endDate;

  final DateTime dueDate;

  /// **Billing cycle**: From [startDate] to [endDate]
  final List<BaseCreditTransaction> transactionsInBillingCycle;

  /// **Grace Period**: From the day after [endDate] to [dueDate]
  final List<BaseCreditTransaction> transactionsInGracePeriod;

  final double _spentInPreviousGracePeriod;
  final double _spentInBillingCycleAfterPreviousGracePeriod;
  final double _spentInGracePeriod;
  final double _paidInPreviousGracePeriodForThisStatement;
  final double _paidInPreviousGracePeriodForPreviousPending;
  final double _paidInBillingCycleAfterPreviousGracePeriod;
  final double _paidInGracePeriod;

  // /// Excluded surplus payment amount of previous statement if there are
  // /// payments transactions happens "not after [previousStatement.dueDate]"
  // /// Because these payments will be counted in GracePeriod of previous statement
  // ///
  // /// Counts [CreditPayment] and [CreditSpending] between/in [previousStatement.dueDate] to/and in [dueDate]
  // final double balanceAfterPreviousDueDateUntilDueDate;

  final double averageDailyBalance;

  factory Statement.create(
    CreditAccount creditAccount, {
    required PreviousStatement previousStatement,
    required DateTime startDate,
  }) {
    final DateTime endDate = startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;
    final DateTime dueDate = creditAccount.statementDay >= creditAccount.paymentDueDay
        ? startDate.copyWith(month: startDate.month + 2, day: creditAccount.paymentDueDay).onlyYearMonthDay
        : startDate.copyWith(month: startDate.month + 1, day: creditAccount.paymentDueDay).onlyYearMonthDay;

    List<BaseCreditTransaction> txnsInBillingCycle = List.empty(growable: true);
    List<BaseCreditTransaction> txnsInGracePeriod = List.empty(growable: true);
    double spentInBillingCycleInPreviousGracePeriod = 0;
    double spentInBillingCycleAfterPreviousGracePeriod = 0;
    double spentInGracePeriod = 0;
    double paidInPreviousGracePeriodForThisStatement = 0;
    double paidInPreviousGracePeriodForPreviousStatement = 0;
    double paidInBillingCycleAfterPreviousGracePeriod = 0;
    double paidInGracePeriod = 0;

    double pendingOfPreviousStatement = previousStatement.pendingForGracePeriod;

    // Calculate sum of daily balance from `tCheckpointDateTime` to current Txn DateTime
    // If this is the first Txn in the list, `tCheckpointDateTime` is `Statement.startDate`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.carryOverWithInterest;

    DateTime tCheckpointDateTime = startDate;

    for (int i = 0; i <= creditAccount.transactionsList.length - 1; i++) {
      final txn = creditAccount.transactionsList[i];

      if (txn.dateTime.isBefore(startDate)) {
        continue;
      }

      if (txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        if (i >= 1) {
          tCheckpointDateTime = creditAccount.transactionsList[i - 1].dateTime;
        }
        break;
      }

      if (txn is CreditSpending) {
        if (txn.dateTime.onlyYearMonthDay.isAfter(endDate)) {
          spentInGracePeriod += txn.amount;
          txnsInGracePeriod.add(txn);
        } else {
          if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
            spentInBillingCycleAfterPreviousGracePeriod += txn.amount;
          } else {
            spentInBillingCycleInPreviousGracePeriod += txn.amount;
          }
          txnsInBillingCycle.add(txn);

          // Calculate tDailyBalanceSum before this txn happens
          tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);
          tCurrentBalance += txn.amount;
        }
      }

      if (txn is CreditPayment) {
        if (txn.dateTime.onlyYearMonthDay.isAfter(endDate)) {
          paidInGracePeriod += txn.amount;
          txnsInGracePeriod.add(txn);
        } else {
          txnsInBillingCycle.add(txn);
          tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);

          if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
            paidInBillingCycleAfterPreviousGracePeriod += txn.amount;

            tCurrentBalance -= txn.amount;
          } else {
            paidInPreviousGracePeriodForPreviousStatement += math.min(txn.amount, pendingOfPreviousStatement);
            paidInPreviousGracePeriodForThisStatement += math.max(0, txn.amount - pendingOfPreviousStatement);
            pendingOfPreviousStatement =
                math.max(0, pendingOfPreviousStatement - paidInPreviousGracePeriodForPreviousStatement);

            tCurrentBalance -= paidInPreviousGracePeriodForThisStatement;
          }
        }
      }

      if (i >= 1) {
        tCheckpointDateTime = creditAccount.transactionsList[i - 1].dateTime;
      }
    }

    tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(endDate);

    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    return Statement._(
      creditAccount,
      spentInBillingCycleInPreviousGracePeriod,
      spentInBillingCycleAfterPreviousGracePeriod,
      spentInGracePeriod,
      paidInPreviousGracePeriodForThisStatement,
      paidInPreviousGracePeriodForPreviousStatement,
      paidInBillingCycleAfterPreviousGracePeriod,
      paidInGracePeriod,
      previousStatement: previousStatement,
      startDate: startDate,
      endDate: endDate,
      dueDate: dueDate,
      transactionsInBillingCycle: txnsInBillingCycle,
      transactionsInGracePeriod: txnsInGracePeriod,
      averageDailyBalance: averageDailyBalance,
    );
  }

  double get currentInterest {
    if (previousStatement.carryOverWithInterest <= 0) {
      return 0;
    }

    return averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);
  }

  /// Assign to `carryingOver` of the next Statement object
  PreviousStatement get carryToNextStatement {
    return PreviousStatement._(
      balance: _balanceCarryToNextStatement,
      pendingForGracePeriod: _pendingForGracePeriod,
      interest: _interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }
}

extension _StatementPaymentDetails on Statement {
  double get _remainingSpentInPreviousGracePeriod =>
      math.max(0, _spentInPreviousGracePeriod - _paidInPreviousGracePeriodForThisStatement);

  double get _remainingPaidInPreviousGracePeriod =>
      math.max(0, _paidInPreviousGracePeriodForThisStatement - _spentInPreviousGracePeriod);

  double get _totalSpent =>
      previousStatement.carryOverWithInterest +
      _remainingSpentInPreviousGracePeriod +
      _spentInBillingCycleAfterPreviousGracePeriod;

  double get _totalPaidBeforeEndDate =>
      _paidInPreviousGracePeriodForThisStatement + _paidInBillingCycleAfterPreviousGracePeriod;

  // Can be negative because of payment in grace period
  double get _totalPaid =>
      _remainingPaidInPreviousGracePeriod + _paidInBillingCycleAfterPreviousGracePeriod + _paidInGracePeriod;

  double get _interest =>
      averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);

  double get _balanceCarryToNextStatement => math.max(0, _totalSpent - _totalPaid);

  double get _pendingForGracePeriod =>
      previousStatement.carryOverWithInterest +
      _spentInPreviousGracePeriod +
      _spentInBillingCycleAfterPreviousGracePeriod -
      _totalPaidBeforeEndDate;

  double get _interestCarryToNextStatement => _balanceCarryToNextStatement <= 0 ? 0 : _interest;
}

extension StatementWithDateTimeDetails on Statement {
  /// BillingCycle is only from [startDate] to [endDate].
  List<BaseCreditTransaction> txnsInBillingCycleBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in transactionsInBillingCycle) {
      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }

    return list;
  }

  /// BillingCycle is only from [endDate] to [dueDate].
  List<BaseCreditTransaction> txnsInGracePeriodBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in transactionsInGracePeriod) {
      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }

    return list;
  }

  List<BaseCreditTransaction> txnsIn(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    final txnList = dateTime.onlyYearMonthDay.isAfter(endDate) ? transactionsInGracePeriod : transactionsInBillingCycle;

    for (BaseCreditTransaction txn in txnList) {
      if (txn.dateTime.onlyYearMonthDay.isAtSameMomentAs(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }
    return list;
  }

  double _spentAmountFromEndDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsInGracePeriodBefore(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double _spentAmountAfterPreviousDueDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsInBillingCycleBefore(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
        amount += txn.amount;
      }
    }
    return amount;
  }

  double _paidAmountFromEndDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsInGracePeriodBefore(dateTime).whereType<CreditPayment>();
    for (CreditPayment txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  /// Because all [CreditPayment] that happens before [PreviousStatement.dueDate] will
  /// be counted in [PreviousStatement.balance].
  double _paidAmountAfterPreviousDueDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = txnsInBillingCycleBefore(dateTime).whereType<CreditPayment>();
    for (CreditPayment txn in list) {
      if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
        amount += txn.amount;
      }
    }
    return amount;
  }

  double getFullPaymentAmountAt(DateTime dateTime) {
    // Remaining balance before chosen dateTime
    final x = previousStatement.carryOverWithInterest +
        _remainingSpentInPreviousGracePeriod +
        currentInterest +
        _spentAmountAfterPreviousDueDateBefore(dateTime) +
        _spentAmountFromEndDateBefore(dateTime) -
        _paidAmountFromEndDateBefore(dueDate) -
        _paidAmountAfterPreviousDueDateBefore(dueDate);

    // print(
    //     'total paid in previousGracePeriod: ${paidInPreviousGracePeriodForThisStatement + paidInBillingCycleInPreviousGracePeriodForPreviousPending}');
    // print('paidInBillingCycleInPreviousGracePeriodForThisStatement $paidInPreviousGracePeriodForThisStatement');
    // print(
    //     'paidInBillingCycleInPreviousGracePeriodForPreviousPending $paidInBillingCycleInPreviousGracePeriodForPreviousPending');
    // print('TOTAL PAID: $_totalPaid');
    //
    // print('spentInBillingCycleInPreviousGracePeriod $spentInPreviousGracePeriod');
    // print('spentInBillingCycleAfterPreviousGracePeriod $spentInBillingCycleAfterPreviousGracePeriod');
    //
    // print('REMAINING SPENT InPreviousGracePeriod $_remainingSpentInPreviousGracePeriod');
    // print('paidInBillingCycleAfterPreviousGracePeriod $paidInBillingCycleAfterPreviousGracePeriod');
    // print('paidInGracePeriod $paidInGracePeriod');
    // print('previous.carryWithInterest ${previousStatement.carryOverWithInterest}');
    // print('TOTAL SPEND: $_totalSpent');
    //
    // print('interest $_interest');
    //
    // print('averageDailyBalance $averageDailyBalance');
    // print('balance carry to next: $_balanceCarryToNextStatement');

    if (x < 0) {
      return 0;
    } else {
      return x;
    }
  }
}
