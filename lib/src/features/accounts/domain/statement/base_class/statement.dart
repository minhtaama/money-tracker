import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_line_chart_services.dart';
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
  /// Use [date] getter instead for more property
  final ({DateTime start, DateTime end, DateTime due}) _date;

  final double apr;

  /// Only specify if user custom this statement data
  /// This is the outstanding balance at [endDate] of statement
  final Checkpoint? checkpoint;

  /// **Installments to pay**: Amount to pay of installments transactions happens before this statement,
  ///
  /// **Billing cycle**: From [startDate] to [endDate]
  ///
  /// **Grace Period**: From the day after [endDate] to [dueDate]
  final StmTxnsData transactions;

  final PreviousStatement _previousStatement;

  /// Without checking for checkpoint at [date.statement]
  final _StmRawSpentData _rawSpent;

  /// Without checking for checkpoint at [date.statement]
  final _StmRawPaidData _rawPaid;

  /// This is the interest of this statement, only used to add
  /// to [PreviousStatement] in [bringToNextStatement] (to next [Statement]),
  /// if this statement is not paid in full or previous statement has a carry over amount.
  ///
  /// Create in sub-class
  ///
  abstract final double _interest;

  /// The total amount of payment that is for this statement.
  ///
  /// The code in each statement sub-class will make it not be counted twice
  /// with payment-in-previous-grace-period amount for-previous-statement.
  /// Read the code for more understanding.
  ///
  /// For each statement type, will need to override because of the different
  /// whether the statement is allow to pay directly in billing cycle or not.
  double get paid;

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
    required ({DateTime start, DateTime end, DateTime due}) date,
    required _StmRawSpentData rawSpent,
    required _StmRawPaidData rawPaid,
    required this.apr,
    required this.checkpoint,
    required this.transactions,
  })  : _date = date,
        _previousStatement = previousStatement,
        _rawSpent = rawSpent,
        _rawPaid = rawPaid;

  @override
  String toString() {
    return 'Statement{startDate: ${date.start}, dueDate: ${date.due}}';
  }
}

extension StatementGetters on Statement {
  StmDateData get date => (
        start: _date.start,
        end: _date.end,
        due: _date.due,
        previousDue: _previousStatement.dueDate,
        statement: _date.start.copyWith(month: _date.start.month + 1)
      );

  /// ## Contains data of spendings in this statement billing cycle
  ///
  /// **`excludeInstallments`**: Only count the spending transaction without installment payment
  /// because these transaction is not required to pay in current grace period.
  ///
  /// -
  ///
  /// **`inBillingCycle`**: If [Checkpoint] is not null, the return value
  /// of both property is [checkpoint.unpaidToPay].
  ///
  /// **`inGracePeriod`**: Count all.
  ///
  StmSpentData get spent => (
        inBillingCycle: (
          all: checkpoint?.unpaidToPay ?? _rawSpent.inBillingCycle.all,
          excludeInstallments: checkpoint?.unpaidToPay ?? _rawSpent.inBillingCycle.excludeInstallments
        ),
        inGracePeriod: _rawSpent.inGracePeriod.all,
      );

  /// total = **[carry.total.excludeGracePayment]** (include **spendings-has-installment**) +
  /// **`spent-in-billing-cycle-of-this-statement`**.
  ///
  /// toPay = **[carry.toPay.excludeGracePayment]** (exclude **spendings-has-installment**) +
  /// **[installmentsAmountToPay]** +
  /// **[spent.inBillingCycle.excludeInstallments]**.
  ///
  /// Do not include [paid] and [carry.interest]. For **line-chart-services**
  ///
  StmAtSpentEndDateData get spentAtEnd => (
        total: carry.total.excludeGracePayment + _rawSpent.inBillingCycle.all,
        toPay: carry.toPay.excludeGracePayment + installmentsAmountToPay + spent.inBillingCycle.excludeInstallments,
      );

  /// ## Installments to pay. Not included in any of [carry] getters
  double get installmentsAmountToPay {
    if (checkpoint != null) {
      return 0;
    }

    double amount = 0;
    final installmentTransactions = transactions.installmentsToPay.map((e) => e.txn).toList();
    for (CreditSpending txn in installmentTransactions) {
      amount += txn.paymentAmount!;
    }
    return amount;
  }

  /// ## Contains data carry from previous statement.
  ///
  /// **`total`**: Total spent amount (include **spendings-has-installment**) of credit account
  /// at start date of this statement.
  ///
  /// **`toPay`**: Spent amount left to pay **from previous statement's end date** of credit account
  /// at start date of this statement (exclude **spendings-has-installment**).
  ///
  /// -
  ///
  /// **`excludeGracePayment`**: Do not contains **paid-in-grace-period-for-previous-statement**.
  ///
  /// Only this value is used to "bring" from previous to next statement recursively.
  /// That is why no payment in grace period is counted twice.
  ///
  /// -
  ///
  /// **`includeGracePayment`**: Contains **paid-in-grace-period-for-previous-statement**.
  ///
  /// This value is used to get THE TRUE CARRY AMOUNT AT A SPECIFIC DATETIME
  ///
  /// -
  ///
  /// Payment happens between current **[date.start]** to **[date.previousDue]** is count for spendings
  /// of **previous [Statement]** first (which is **paid-in-grace-period-for-previous-statement**).
  /// Then the surplus amount will be count for spendings happens in **this [Statement]**.
  ///
  /// -
  ///
  /// ## [carry.interest] is not include in [carry.total] and [carry.toPay]
  ///
  StmCarryWithInterestData get carry => (
        total: (
          excludeGracePayment: _previousStatement.balanceAtEndDate,
          includeGracePayment: _previousStatement.balanceAtEndDateWithPrvGracePayment,
        ),
        toPay: (
          excludeGracePayment: _previousStatement.balanceToPayAtEndDate,
          includeGracePayment: _previousStatement.balanceToPayAtEndDateWithPrvGracePayment,
        ),
        interest: _previousStatement.interestToThisStatement,
      );

  /// The balance remaining
  ///
  double get balanceToPayRemaining {
    double value;
    if (checkpoint == null) {
      value = (carry.interest +
              carry.toPay.includeGracePayment +
              spent.inBillingCycle.excludeInstallments +
              installmentsAmountToPay) -
          paid;
    } else {
      value = spent.inBillingCycle.excludeInstallments - paid;
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
  ///
  PreviousStatement get bringToNextStatement {
    final balanceAtEndDate = checkpoint?.oustdBalance ??
        double.parse(
          (carry.total.excludeGracePayment +
                  carry.interest +
                  _rawSpent.inBillingCycle.all -
                  _rawPaid.inBillingCycle.all)
              .toStringAsFixed(2),
        );

    final balanceAtEndDateWithPrvGracePayment = double.parse(
      (balanceAtEndDate - _rawPaid.inGracePeriod).toStringAsFixed(2),
    );

    final balanceToPayAtEndDate = checkpoint?.unpaidToPay ??
        double.parse(
          (carry.total.excludeGracePayment +
                  carry.interest +
                  installmentsAmountToPay +
                  _rawSpent.inBillingCycle.excludeInstallments -
                  _rawPaid.inBillingCycle.all)
              .toStringAsFixed(2),
        );

    final balanceToPayAtEndDateWithPrvGracePayment = double.parse(
      math.max(0, balanceToPayAtEndDate - _rawPaid.inGracePeriod).toStringAsFixed(2),
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
      dueDate: date.due,
    );
  }
}

extension StatementFunctions on Statement {
  /// BillingCycle is only from [startDate] to [endDate].
  List<BaseCreditTransaction> transactionsInBillingCycleBefore(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (BaseCreditTransaction txn in transactions.inBillingCycle) {
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

    for (BaseCreditTransaction txn in transactions.inGracePeriod) {
      if (txn.dateTime.isBefore(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }

    return list;
  }

  List<BaseCreditTransaction> transactionsIn(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    final txnList =
        dateTime.onlyYearMonthDay.isAfter(date.end) ? transactions.inGracePeriod : transactions.inBillingCycle;

    for (BaseCreditTransaction txn in txnList) {
      if (txn.dateTime.onlyYearMonthDay.isAtSameMomentAs(dateTime.onlyYearMonthDay)) {
        list.add(txn);
      }
    }

    return list;
  }
}
