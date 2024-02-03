import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'dart:math' as math;
import '../../../../utils/constants.dart';
import '../../../transactions/domain/transaction_base.dart';
part 'statement_for_interest_by_ADB.dart';

/// ALL OF THIS CLASS IS INSTANTIATE IN ACCOUNT_BASE.DART

@immutable
abstract class Statement {
  final double apr;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate;

  /// Only specify if user custom this statement data
  /// This is the outstanding balance at the end date of the statement
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

  double getBalanceAmountAt(DateTime dateTime) {
    double x;

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

    if (checkpoint != null) {
      if (!dateTime.onlyYearMonthDay.isAfter(endDate)) {
        x = 0;
      } else {
        x = checkpoint!.unpaidToPay + spentInGracePeriodBeforeDateTimeExcludeInstallments - _paidInGracePeriod;
      }
    } else {
      x = balanceToPayAtStartDate +
          installmentsAmountToPay +
          spentInBillingCycleBeforeDateTimeExcludeInstallments +
          spentInGracePeriodBeforeDateTimeExcludeInstallments -
          _paidInGracePeriod -
          _paidInBillingCycle;
    }

    if (x < 0) {
      return 0;
    } else {
      return double.parse(x.toStringAsFixed(2));
    }
  }

  /// Assign to `previousStatement` of the next Statement object
  PreviousStatement get carryToNextStatement {
    final balanceAtEndDate = checkpoint?.oustdBalance ??
        double.parse(
          (balanceAtStartDate + _spentInBillingCycle - _paidInBillingCycle).toStringAsFixed(2),
        );

    final balanceAfterPaidInGracePeriod = double.parse(
      (balanceAtEndDate - _paidInGracePeriod).toStringAsFixed(2),
    );

    final balanceToPayAtEndDate = checkpoint?.unpaidToPay ??
        double.parse(
          (balanceToPayAtStartDate +
                  installmentsAmountToPay +
                  _spentInBillingCycleExcludeInstallments -
                  _paidInBillingCycle)
              .toStringAsFixed(2),
        );

    final balanceToPayAfterPaidInGracePeriod = double.parse(
      math.max(0, balanceToPayAtEndDate - _paidInGracePeriod).toStringAsFixed(2),
    );

    final interestCarryToNextStatement = checkpoint != null
        ? 0.0
        : balanceToPayAfterPaidInGracePeriod > 0 || _previousStatement.balanceToPayAfterPaidInGracePeriod > 0
            ? _interest
            : 0.0;

    return PreviousStatement._(
      math.max(0, balanceToPayAtEndDate),
      math.max(0, balanceAtEndDate),
      balanceAfterPaidInGracePeriod: math.max(0, balanceAfterPaidInGracePeriod),
      balanceToPayAfterPaidInGracePeriod: math.max(0, balanceToPayAfterPaidInGracePeriod),
      interestToThisStatement: interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }

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
    };
  }

  const Statement(
    this._previousStatement,
    this._spentInBillingCycle,
    this._spentInBillingCycleExcludeInstallments,
    this._paidInBillingCycle,
    this._paidInGracePeriod, {
    required this.apr,
    required this.checkpoint,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.installments,
    required this.transactionsInBillingCycle,
    required this.transactionsInGracePeriod,
  });

  @override
  String toString() {
    return 'Statement{startDate: $startDate, dueDate: $dueDate}';
  }
}

extension StatementGetters on Statement {
  DateTime get previousDueDate => _previousStatement.dueDate;

  DateTime get statementDate => startDate.copyWith(month: startDate.month + 1);

  double get spentInBillingCycleExcludeInstallments =>
      checkpoint?.unpaidToPay ?? _spentInBillingCycleExcludeInstallments;

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

  double get paidForThisStatement {
    // Included Checkpoint transaction
    double spentInGracePeriodExcludeInstallments = 0;
    double paidInBillingCycleInPreviousGracePeriod = 0;

    for (int i = 0; i < transactionsInBillingCycle.length; i++) {
      final txn = transactionsInBillingCycle[i];
      if (txn is CreditPayment && !txn.dateTime.isAfter(_previousStatement.dueDate)) {
        paidInBillingCycleInPreviousGracePeriod += txn.afterAdjustedAmount;
      }
    }

    for (BaseCreditTransaction txn in transactionsInGracePeriod) {
      if (txn is CreditSpending && !txn.hasInstallment) {
        spentInGracePeriodExcludeInstallments += txn.amount;
      }
    }

    if (checkpoint != null) {
      return math.max(0, _paidInGracePeriod - spentInGracePeriodExcludeInstallments);
    } else {
      return math.max(0, paidInBillingCycleInPreviousGracePeriod - _previousStatement._balanceToPayAtEndDate) +
          (_paidInBillingCycle - paidInBillingCycleInPreviousGracePeriod) +
          math.max(0, _paidInGracePeriod - spentInGracePeriodExcludeInstallments);
    }
  }

  /// Included previous interest
  double get balanceRemaining {
    double value = checkpoint == null
        ? (_previousStatement.interestToThisStatement +
                _previousStatement.balanceToPayAfterPaidInGracePeriod +
                spentInBillingCycleExcludeInstallments +
                installmentsAmountToPay) -
            paidForThisStatement
        : spentInBillingCycleExcludeInstallments - paidForThisStatement;

    return math.max(0, value);
  }

  /// Included previous interest
  double get balanceAtStartDate => _previousStatement._balanceAtEndDate + _previousStatement.interestToThisStatement;

  /// Included previous interest
  double get balanceAtEndDate => balanceAtStartDate + _spentInBillingCycle;

  /// Included previous interest
  double get balanceToPayAtStartDate =>
      _previousStatement._balanceToPayAtEndDate + _previousStatement.interestToThisStatement;

  /// Included previous interest
  double get balanceToPayAtEndDate =>
      balanceToPayAtStartDate + installmentsAmountToPay + spentInBillingCycleExcludeInstallments;

  /// Not included previous interest, include payment amount in previous grace period
  double get balanceToPayAtStartDateAfterPaid => _previousStatement.balanceToPayAfterPaidInGracePeriod;

  /// Not included previous interest, include payment amount in previous grace period
  double get balanceAtStartDateAfterPaid => _previousStatement.balanceAfterPaidInGracePeriod;

  double get interestFromPrevious => _previousStatement.interestToThisStatement;
}

@immutable
class PreviousStatement {
  /// Can't be **negative**. Use to get the remaining amount needed to pay carry to current statement.
  /// This previous statement only carry interest if this value is more than 0.
  ///
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceToPayAtEndDate**, so no transaction
  /// is counted twice.
  ///
  /// Exclude interestToThisStatement amount
  final double balanceToPayAfterPaidInGracePeriod;

  /// Can't be **negative**, no interest included. Use as the balance to pay at the start date
  /// of current statement.
  ///
  /// The math should not be less than 0. However if so, return 0.
  ///
  /// /// Exclude interestToThisStatement amount
  final double _balanceToPayAtEndDate;

  /// Can't be **negative**. Use to calculate the interest of this previous statement.
  ///
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceAtEndDate**, so no transaction
  /// is counted twice.
  ///
  /// /// Exclude interestToThisStatement amount
  final double balanceAfterPaidInGracePeriod;

  /// Can't be **negative**, no interest included. Use as the credit balance at the start date
  /// of current statement.
  ///
  /// The math should not be less than 0. However if so, return 0.
  ///
  /// /// Exclude interestToThisStatement amount
  final double _balanceAtEndDate;

  /// Only charge/carry interest if `balanceToPay` is more than 0.
  /// This is the interest that previous statement carry to "THIS STATEMENT"
  final double interestToThisStatement;

  /// Use for checking if can add payments
  final DateTime dueDate;

  factory PreviousStatement.noData({required DateTime dueDate}) {
    return PreviousStatement._(0, 0,
        balanceToPayAfterPaidInGracePeriod: 0,
        balanceAfterPaidInGracePeriod: 0,
        interestToThisStatement: 0,
        dueDate: dueDate);
  }

  /// Assign to `previousStatement` of the next Statement object.
  ///
  /// This class is not meant to be created outside of this library
  const PreviousStatement._(
    this._balanceToPayAtEndDate,
    this._balanceAtEndDate, {
    required this.balanceToPayAfterPaidInGracePeriod,
    required this.balanceAfterPaidInGracePeriod,
    required this.interestToThisStatement,
    required this.dueDate,
  });

  PreviousStatement copyWith({
    double? balanceToPayAfterPaidInGracePeriod,
    double? balanceToPayAtEndDate,
    double? balanceAfterPaidInGracePeriod,
    double? balanceAtEndDate,
    double? interestToThisStatement,
  }) {
    return PreviousStatement._(
      balanceToPayAtEndDate ?? _balanceToPayAtEndDate,
      balanceAtEndDate ?? _balanceAtEndDate,
      balanceToPayAfterPaidInGracePeriod: balanceToPayAfterPaidInGracePeriod ?? this.balanceToPayAfterPaidInGracePeriod,
      balanceAfterPaidInGracePeriod: balanceAfterPaidInGracePeriod ?? this.balanceAfterPaidInGracePeriod,
      interestToThisStatement: interestToThisStatement ?? this.interestToThisStatement,
      dueDate: dueDate,
    );
  }

  @override
  String toString() {
    return 'PreviousStatement{balanceToPay: $balanceToPayAfterPaidInGracePeriod, _balanceToPayAtEndDate: $_balanceToPayAtEndDate, balance: $balanceAfterPaidInGracePeriod, _balanceAtEndDate: $_balanceAtEndDate, interest: $interestToThisStatement, dueDate: $dueDate}';
  }
}

@immutable
class Checkpoint {
  /// Can't be **negative**. The total of balance that user has spent at the checkpoint
  final double oustdBalance;

  /// Can't be **negative**. The total amount that haven't been paid of all installments in
  /// the statement has this checkpoint
  ///
  /// /// unpaidOfInstallment is always lower than `oustdBalance`, as the calculation of
  //   /// [_CreditAccountExtension.unpaidOfInstallmentsAtCheckpoint] in account_base.dart.
  final double unpaidOfInstallments;

  /// unpaidOfInstallment is always lower than `oustdBalance`, as the calculation of
  /// [CreditAccountExtension._modifyInstallmentsAtCheckpoint] in account_base.dart.
  ///
  /// But we put `math.max()` to make sure it always has to.
  double get unpaidToPay => math.max(0, oustdBalance - unpaidOfInstallments);

  const Checkpoint(this.oustdBalance, this.unpaidOfInstallments);
}

@immutable
class Installment {
  final CreditSpending txn;
  final int monthsLeft;

  double get unpaidAmount => txn.paymentAmount! * monthsLeft;

  const Installment(this.txn, this.monthsLeft);

  @override
  String toString() {
    return 'Installment{txn: $txn, monthsLeft: $monthsLeft}';
  }
}
