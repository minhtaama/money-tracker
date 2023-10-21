import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../../utils/constants.dart';
import '../../../transactions/domain/transaction_base.dart';
import '../account_base.dart';

part 'previous_statement.dart';

@immutable
class Statement {
  const Statement._(this._creditAccount, this.previousStatement, this.startDate, this.endDate, this.dueDate,
      this.transactions, this.balanceAfterPreviousDueDateUntilDueDate, this.averageDailyBalance);

  final CreditAccount _creditAccount;

  final PreviousStatement previousStatement;

  final DateTime startDate;

  final DateTime endDate;

  final DateTime dueDate;

  /// Include all [BaseCreditTransaction] happens in both:
  ///
  /// **Billing cycle**: From [startDate] to [endDate]
  ///
  /// and **Grace Period**: From the day after [endDate] to [dueDate]
  final List<BaseCreditTransaction> transactions;

  /// Excluded surplus payment amount of previous statement if there are
  /// payments transactions happens "not after [previousStatement.dueDate]"
  /// Because these payments will be counted in GracePeriod of previous statement
  ///
  /// Counts [CreditPayment] and [CreditSpending] between/in [previousStatement.dueDate] to/and in [dueDate]
  final double balanceAfterPreviousDueDateUntilDueDate;

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
    List<BaseCreditTransaction> transactions = List.empty(growable: true);
    double balanceAfterPreviousDueDateUntilDueDate = 0;

    // Calculate sum of daily balance from `checkpoint` to current Txn DateTime
    // If this is the first Txn in the list, `checkpoint` is `Statement.startDate`
    double tDailyBalanceSum = 0;

    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.balanceAfterEndDate;

    DateTime tLastSpendingInBillingCycleDateTime = startDate;

    for (int i = 0; i <= creditAccount.transactionsList.length - 1; i++) {
      // Previous transaction dateTime
      final checkpoint = i == 0 ? startDate : creditAccount.transactionsList[i - 1].dateTime;

      final txn = creditAccount.transactionsList[i];

      if (txn.dateTime.isBefore(startDate)) {
        continue;
      }

      if (txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        break;
      }

      transactions.add(txn);

      if (txn is CreditSpending) {
        if (txn.dateTime.isAfter(previousStatement.dueDate)) {
          balanceAfterPreviousDueDateUntilDueDate += txn.amount;
        }

        // Calculate tDailyBalanceSum before this txn happens
        tLastSpendingInBillingCycleDateTime = txn.dateTime.onlyYearMonthDay;
        tDailyBalanceSum += tCurrentBalance * checkpoint.getDaysDifferent(txn.dateTime);
        tCurrentBalance += txn.amount;
      }

      if (txn is CreditPayment) {
        // We don't count payments before `previousStatement.dueDate` because these are already
        // counted in grace period of previous statement.
        if (txn.dateTime.isAfter(previousStatement.dueDate)) {
          balanceAfterPreviousDueDateUntilDueDate -= txn.amount;
        }

        if (!txn.dateTime.isAfter(endDate)) {
          // - Only calculate tDailyBalanceSum before this txn if this txn is made not after `endDate`.
          // - The point is that any payment happens in grace period (from `endDate` to `dueDate`) will
          // not be counted in averageDailyBalance. These payments will only to count
          // carry over balance of previous statement.
          tDailyBalanceSum += tCurrentBalance * checkpoint.getDaysDifferent(txn.dateTime);
          tCurrentBalance -= txn.amount;
        }
      }
    }

    tDailyBalanceSum += tCurrentBalance * tLastSpendingInBillingCycleDateTime.getDaysDifferent(endDate);
    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    return Statement._(creditAccount, previousStatement, startDate, endDate, dueDate, transactions,
        balanceAfterPreviousDueDateUntilDueDate, averageDailyBalance);
  }

  bool get isFullPaid {
    double result = previousStatement.totalCarryToThisStatement + balanceAfterPreviousDueDateUntilDueDate;
    if (result <= 0) {
      return true;
    }
    return false;
  }

  double get thisStatementInterest {
    if (previousStatement.totalCarryToThisStatement <= 0) {
      return 0;
    }

    return averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);
  }

  double get interestCarryToNextStatement =>
      isFullPaid ? 0 : averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);

  /// Assign to `carryingOver` of the next Statement object
  PreviousStatement get carryToNextStatement {
    double balanceCarryToNextStatement =
        previousStatement.totalCarryToThisStatement + balanceAfterPreviousDueDateUntilDueDate;
    return PreviousStatement._(
      balanceCarryToThisStatement: balanceCarryToNextStatement,
      balanceAfterEndDate: 0,
      interest: interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }
}

extension StatementWithDateTimeDetails on Statement {
  /// BillingCycle is only from [startDate] to [endDate].
  List<BaseCreditTransaction> txnsInBillingCycleBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= transactions.length - 1; i++) {
      final txn = transactions[i];

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

  /// BillingCycle is only from [endDate] to [dueDate].
  List<BaseCreditTransaction> txnsInGracePeriodBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in transactions) {
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
    for (BaseCreditTransaction txn in transactions) {
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
  /// be counted in [PreviousStatement.balanceCarryToThisStatement].
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
    final x = previousStatement.totalCarryToThisStatement +
        thisStatementInterest +
        _spentAmountAfterPreviousDueDateBefore(dateTime) +
        _spentAmountFromEndDateBefore(dateTime) -
        _paidAmountFromEndDateBefore(dueDate) -
        _paidAmountAfterPreviousDueDateBefore(dueDate);

    print(previousStatement.balanceCarryToThisStatement);
    print(previousStatement.interest);
    print(thisStatementInterest);
    print('this');
    print(interestCarryToNextStatement);

    if (x < 0) {
      return 0;
    } else {
      return x;
    }
  }
}
