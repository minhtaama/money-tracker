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
  final PreviousStatement previousStatement;
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

  final double _spentInBillingCycle;
  final double _spentInBillingCycleExcludeInstallments;
  final double _paidInBillingCycle;
  final double _paidInGracePeriod;

  /// This is the interest of this statement, only add this value to next statement
  /// if this statement is not paid in full or previous statement has a carry over amount.
  abstract final double _interest;

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
      if (txn is CreditPayment && !txn.dateTime.isAfter(previousStatement.dueDate)) {
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
      return math.max(
              0, paidInBillingCycleInPreviousGracePeriod - previousStatement._balanceToPayAtEndDate) +
          (_paidInBillingCycle - paidInBillingCycleInPreviousGracePeriod) +
          math.max(0, _paidInGracePeriod - spentInGracePeriodExcludeInstallments);
    }
  }

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
        x = checkpoint!.unpaidToPay +
            spentInGracePeriodBeforeDateTimeExcludeInstallments -
            _paidInGracePeriod;
      }
    } else {
      x = previousStatement._balanceToPayAtEndDate +
          previousStatement.interest +
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
          (previousStatement._balanceAtEndDate +
                  previousStatement.interest +
                  _spentInBillingCycle -
                  _paidInBillingCycle)
              .toStringAsFixed(2),
        );

    final balance = double.parse(
      (balanceAtEndDate - _paidInGracePeriod).toStringAsFixed(2),
    );

    final balanceToPayAtEndDate = checkpoint?.unpaidToPay ??
        double.parse(
          (previousStatement._balanceToPayAtEndDate +
                  previousStatement.interest +
                  installmentsAmountToPay +
                  _spentInBillingCycleExcludeInstallments -
                  _paidInBillingCycle)
              .toStringAsFixed(2),
        );

    final balanceToPay = double.parse(
      math.max(0, balanceToPayAtEndDate - _paidInGracePeriod).toStringAsFixed(2),
    );

    final interestCarryToNextStatement = checkpoint != null
        ? 0.0
        : balanceToPay > 0 || previousStatement.balanceToPay > 0
            ? _interest
            : 0.0;

    return PreviousStatement._(
      balanceToPayAtEndDate,
      balanceAtEndDate,
      balance: balance,
      balanceToPay: balanceToPay,
      interest: interestCarryToNextStatement,
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
    this._spentInBillingCycle,
    this._spentInBillingCycleExcludeInstallments,
    this._paidInBillingCycle,
    this._paidInGracePeriod, {
    required this.apr,
    required this.previousStatement,
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

@immutable
class PreviousStatement {
  /// Can't be **negative**. Use to get the remaining amount needed to pay carry to current statement.
  /// This previous statement only carry interest if this value is more than 0.
  ///
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceToPayAtEndDate**, so no transaction
  /// is counted twice.
  final double balanceToPay;

  /// Can't be **negative**, no interest included. Use as the balance to pay at the start date
  /// of current statement.
  ///
  /// The math should not be less than 0. However if so, return 0.
  final double _balanceToPayAtEndDate;

  /// Can't be **negative**. Use to calculate the interest of this previous statement.
  ///
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceAtEndDate**, so no transaction
  /// is counted twice.
  final double balance;

  /// Can't be **negative**, no interest included. Use as the credit balance at the start date
  /// of current statement.
  ///
  /// The math should not be less than 0. However if so, return 0.
  final double _balanceAtEndDate;

  /// Only charge/carry interest if `balanceToPay` is more than 0.
  final double interest;

  /// Use for checking if can add payments
  final DateTime dueDate;

  factory PreviousStatement.noData({required DateTime dueDate}) {
    return PreviousStatement._(0, 0, balanceToPay: 0, balance: 0, interest: 0, dueDate: dueDate);
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

  PreviousStatement copyWith({
    double? balanceToPay,
    double? balanceToPayAtEndDate,
    double? balance,
    double? balanceAtEndDate,
    double? interest,
  }) {
    return PreviousStatement._(
      balanceToPayAtEndDate ?? _balanceToPayAtEndDate,
      balanceAtEndDate ?? _balanceAtEndDate,
      balanceToPay: balanceToPay ?? this.balanceToPay,
      balance: balance ?? this.balance,
      interest: interest ?? this.interest,
      dueDate: dueDate,
    );
  }

  @override
  String toString() {
    return 'PreviousStatement{balanceToPay: $balanceToPay, _balanceToPayAtEndDate: $_balanceToPayAtEndDate, balance: $balance, _balanceAtEndDate: $_balanceAtEndDate, interest: $interest, dueDate: $dueDate}';
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
