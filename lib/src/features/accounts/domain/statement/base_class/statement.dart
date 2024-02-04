import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;
import '../../../../transactions/domain/transaction_base.dart';

part 'previous_statement.dart';
part 'misc.dart';
part '../statement_with_average_daily_balance.dart';
part '../statement_pay_only_in_grace_period.dart';

/// ALL OF THIS CLASS IS INSTANTIATE IN ACCOUNT_BASE.DART
@immutable
sealed class Statement {
  final double apr;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate;

  /// Only specify if user custom this statement data
  /// This is the outstanding balance at [endDate] of statement
  final Checkpoint? checkpoint;

  /// Installment transactions happens before this statement, but need to pay at this statement
  final List<Installment> installments;

  /// **Billing cycle**: From [startDate] to [endDate]
  final List<BaseCreditTransaction> transactionsInBillingCycle;

  /// **Grace Period**: From the day after [endDate] to [dueDate]
  final List<BaseCreditTransaction> transactionsInGracePeriod;

  final PreviousStatement _previousStatement;
  final double _spentInBillingCycle;
  final double _spentInBillingCycleExcludeInstallments;
  final double _spentInGracePeriod;
  final double _spentInGracePeriodExcludeInstallments;
  final double _paidInBillingCycle;
  final double _paidInBillingCycleInPreviousGracePeriod;
  final double _paidInGracePeriod;

  /// This is the interest of this statement, only used to add
  /// to [PreviousStatement] in [carryToNextStatement] (to next [Statement]),
  /// if this statement is not paid in full or previous statement has a carry over amount.
  ///
  abstract final double _interest;

  /// Need to override because of the different whether the statement
  /// is allow to pay directly in billing cycle.
  double get paidForThisStatement;

  /// Need to override because of the different whether the statement
  /// is allow to pay directly in billing cycle.
  double balanceToPayAt(DateTime dateTime);

  factory Statement.create(
    StatementType type, {
    required PreviousStatement previousStatement,
    required Checkpoint? checkpoint,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime dueDate,
    required double apr,
    required List<Installment> installments,
    required List<BaseCreditTransaction> txnsInBillingCycle,
    required List<BaseCreditTransaction> txnsInGracePeriod,
  }) {
    return switch (type) {
      StatementType.withAverageDailyBalance => StatementWithAverageDailyBalance._create(
          previousStatement: previousStatement,
          checkpoint: checkpoint,
          startDate: startDate,
          endDate: endDate,
          dueDate: dueDate,
          apr: apr,
          installments: installments,
          txnsInBillingCycle: txnsInBillingCycle,
          txnsInGracePeriod: txnsInGracePeriod),
      StatementType.payOnlyInGracePeriod => StatementPayOnlyInGracePeriod._create(
          previousStatement: previousStatement,
          checkpoint: checkpoint,
          startDate: startDate,
          endDate: endDate,
          dueDate: dueDate,
          apr: apr,
          installments: installments,
          txnsInBillingCycle: txnsInBillingCycle,
          txnsInGracePeriod: txnsInGracePeriod),
    };
  }

  const Statement({
    required PreviousStatement previousStatement,
    required double spentInBillingCycle,
    required double spentInBillingCycleExcludeInstallments,
    required double spentInGracePeriodExcludeInstallments,
    required double spentInGracePeriod,
    required double paidInBillingCycle,
    required double paidInBillingCycleInPreviousGracePeriod,
    required double paidInGracePeriod,
    required this.apr,
    required this.checkpoint,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.installments,
    required this.transactionsInBillingCycle,
    required this.transactionsInGracePeriod,
  })  : _previousStatement = previousStatement,
        _spentInBillingCycle = spentInBillingCycle,
        _spentInBillingCycleExcludeInstallments = spentInBillingCycleExcludeInstallments,
        _spentInGracePeriodExcludeInstallments = spentInGracePeriodExcludeInstallments,
        _spentInGracePeriod = spentInGracePeriod,
        _paidInBillingCycle = paidInBillingCycle,
        _paidInBillingCycleInPreviousGracePeriod = paidInBillingCycleInPreviousGracePeriod,
        _paidInGracePeriod = paidInGracePeriod;

  @override
  String toString() {
    return 'Statement{startDate: $startDate, dueDate: $dueDate}';
  }
}

extension StatementGetters on Statement {
  DateTime get previousDueDate => _previousStatement.dueDate;
  DateTime get statementDate => startDate.copyWith(month: startDate.month + 1);

  /// Only count the spending transaction in billing cycle. Not include
  /// spendings with installment.
  double get spentInBillingCycleExcludeInstallments =>
      checkpoint?.unpaidToPay ?? _spentInBillingCycleExcludeInstallments;

  double get spentInGracePeriod => _spentInGracePeriod;

  /// installments to pay. Not included in any of startDate getters
  double get installmentsAmountToPay {
    if (checkpoint != null) {
      return 0;
    }

    double amount = 0;
    final installmentTransactions = installments.map((e) => e.txn).toList();
    for (CreditSpending txn in installmentTransactions) {
      amount += txn.paymentAmount!;
    }
    return amount;
  }

  /// Total spent amount (include **spendings-has-installment**) of credit account
  /// at start date of this statement.
  ///
  /// Do not include **[interestFromPrevious]**, **[installmentsAmountToPay]**
  /// and **`paid-in-grace-period-for-previous-statement`**.
  ///
  double get totalSpentAtStartDate => _previousStatement.balanceAtEndDate;

  /// Total spent amount (include **spendings-has-installment**) of credit account
  /// at start date of this statement.
  ///
  /// Include **`paid-in-grace-period-for-previous-statement`**.
  ///
  /// Do not include **[interestFromPrevious]**, **[installmentsAmountToPay]**.
  ///
  double get totalSpentAtStartDateWithPrvGracePayment =>
      _previousStatement.balanceAtEndDateWithPrvGracePayment;

  /// = **[totalSpentAtStartDate]** (include **spendings-has-installment**) +
  /// **`spent-in-billing-cycle-of-this-statement`**.
  ///
  /// Do not include [paidForThisStatement] and [interestFromPrevious].
  ///
  double get totalSpentAtEndDate => totalSpentAtStartDate + _spentInBillingCycle;

  /// Spent amount left to pay _from previous statement's end date_ of credit account
  /// at start date of this statement (exclude **spendings-has-installment**).
  ///
  /// Do not include **[interestFromPrevious]**, **[installmentsAmountToPay]**
  /// and **`paid-in-grace-period-for-previous-statement`**.
  ///
  double get spentToPayAtStartDate => _previousStatement.balanceToPayAtEndDate;

  /// Spent amount left to pay _from previous statement's end date_ of credit account
  /// at start date of this statement (exclude **spendings-has-installment**).
  ///
  /// Include **`paid-in-grace-period-for-previous-statement`**.
  ///
  /// Do not include **[interestFromPrevious]**, **[installmentsAmountToPay]**.
  ///
  double get spentToPayAtStartDateWithPrvGracePayment =>
      _previousStatement.balanceToPayAtEndDateWithPrvGracePayment;

  /// = **[spentToPayAtStartDate]** (exclude **spendings-has-installment**) +
  /// **[installmentsAmountToPay]** +
  /// **[spentInBillingCycleExcludeInstallments]**.
  ///
  /// Do not include [paidForThisStatement] and [interestFromPrevious].
  ///
  double get spentToPayAtEndDate =>
      spentToPayAtStartDate + installmentsAmountToPay + spentInBillingCycleExcludeInstallments;

  /// The interest from previous statement to this statement
  /// Not include in any other getters
  double get interestFromPrevious => _previousStatement.interestToThisStatement;

  /// The balance remaining
  double get balanceToPayRemaining {
    double value;
    if (checkpoint == null) {
      value = (interestFromPrevious +
              spentToPayAtStartDateWithPrvGracePayment +
              spentInBillingCycleExcludeInstallments +
              installmentsAmountToPay) -
          paidForThisStatement;
    } else {
      value = spentInBillingCycleExcludeInstallments - paidForThisStatement;
    }

    // Just to make sure it is not under 0
    return math.max(0, value);
  }

  /// Only to assign to [_previousStatement] property of the next [Statement] object
  ///
  /// When reading this getter, you must understand that all the
  /// property that assign to [PreviousStatement] is of "This Current [Statement]".
  ///
  /// The "Next [Statement]" in the statement list will
  /// access to "This Current [Statement]" info through [_previousStatement] property
  PreviousStatement get carryToNextStatement {
    final balanceAtEndDate = checkpoint?.oustdBalance ??
        double.parse(
          (totalSpentAtStartDate + interestFromPrevious + _spentInBillingCycle - _paidInBillingCycle)
              .toStringAsFixed(2),
        );

    final balanceAtEndDateWithPrvGracePayment = double.parse(
      (balanceAtEndDate - _paidInGracePeriod).toStringAsFixed(2),
    );

    final balanceToPayAtEndDate = checkpoint?.unpaidToPay ??
        double.parse(
          (spentToPayAtStartDate +
                  interestFromPrevious +
                  installmentsAmountToPay +
                  _spentInBillingCycleExcludeInstallments -
                  _paidInBillingCycle)
              .toStringAsFixed(2),
        );

    final balanceToPayAtEndDateWithPrvGracePayment = double.parse(
      math.max(0, balanceToPayAtEndDate - _paidInGracePeriod).toStringAsFixed(2),
    );

    final interestCarryToNextStatement = checkpoint != null
        ? 0.0
        : balanceToPayAtEndDateWithPrvGracePayment > 0 ||
                _previousStatement.balanceToPayAtEndDateWithPrvGracePayment > 0
            ? _interest
            : 0.0;

    return PreviousStatement._(
      math.max(0, balanceToPayAtEndDate),
      math.max(0, balanceAtEndDate),
      balanceAtEndDateWithPrvGracePayment: math.max(0, balanceAtEndDateWithPrvGracePayment),
      balanceToPayAtEndDateWithPrvGracePayment: math.max(0, balanceToPayAtEndDateWithPrvGracePayment),
      interestToThisStatement: interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }
}

extension StatementFunctions on Statement {
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

    final txnList = dateTime.onlyYearMonthDay.isAfter(endDate)
        ? transactionsInGracePeriod
        : transactionsInBillingCycle;

    for (BaseCreditTransaction txn in txnList) {
      if (txn.dateTime.onlyYearMonthDay.isAtSameMomentAs(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }
    return list;
  }
}
