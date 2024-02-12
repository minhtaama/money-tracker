import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/application/custom_line_chart_services.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
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

  /// ## The adjusted amount at this [Statement.date.end]
  /// Only specify (not null) if there is a [CreditCheckpoint] in [transactions.inBillingCycle]
  final Checkpoint? checkpoint;

  /// **Installments to pay**: Amount to pay of installments transactions happens before this statement,
  ///
  /// **Billing cycle**: From [startDate] to [endDate]
  ///
  /// **Grace Period**: From the day after [endDate] to [dueDate]
  final StmTxnsData transactions;

  /// Use getter instead for more property
  final ({DateTime start, DateTime end, DateTime due}) _date;

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

  /// ## Balance remaining to pay at selected dateTime
  ///
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
  CreditPayment get firstPayment {
    final list = transactions.inBillingCycle.followedBy(transactions.inGracePeriod);
    return list.whereType<CreditPayment>().first;
  }

  StmDateData get date => (
        start: _date.start,
        end: _date.end,
        due: _date.due,
        previousDue: _previousStatement.dueDate,
        statement: _date.start.copyWith(month: _date.start.month + 1)
      );

  /// ## Contains only data of spendings in this statement billing cycle, no [carry] amount
  ///
  /// **`toPay`**: Only count the spending transaction without installment payment
  /// because it is not required to pay in-full. The installment-amount-to-pay
  /// of these is located in [installmentsToPay]
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
          all: checkpoint?.oustdBalance ?? _rawSpent.inBillingCycle.all,
          toPay: checkpoint?.unpaidToPay ?? _rawSpent.inBillingCycle.toPay,
        ),
        inGracePeriod: _rawSpent.inGracePeriod.all,
      );

  /// ## Balance carry from previous statement.
  ///
  /// **`totalBalance`**: Total balance left **from previous statement** (include **spendings-has-installment**)
  ///
  /// **`balanceToPay`**: Spent amount left to pay **from previous statement**
  /// (exclude **spendings-has-installment**).
  ///
  /// -
  ///
  /// ## Included payment amount in-grace-period for previous-statement.
  ///
  /// Payment happens between current **[date.start]** to **[date.previousDue]** is count for spendings
  /// of **previous [Statement]** first (which is paid-in-grace-period-for-previous-statement).
  /// Then the surplus amount will be count for spendings happens in **this [Statement]**. The logic for
  /// not counted surplus amount twice is in [paid]:
  ///
  /// ```dart
  ///   ...
  ///   surplus = math.max(0, _rawPaid.inBillingCycle.inPreviousGracePeriod - startPoint.toPay),
  ///   ...
  /// ```
  ///
  /// ## [carry.interest] is not include in [carry.total] and [carry.toPay]
  ///
  StmCarryWithInterestData get carry => (
        totalBalance: _previousStatement.balance,
        balanceToPay: _previousStatement.balanceToPay,
        interest: _previousStatement.interest,
      );

  /// ## Contains data at "start-point" of this [Statement].
  ///
  /// **`totalBalance`**: Balance left from total spending (include **spendings-has-installment**) of credit account
  /// **at start date** of this statement.
  ///
  /// **`balanceToPay`**: Balance left to pay **from previous statement's end date** of credit account
  /// at start date of this statement (exclude **spendings-has-installment**).
  ///
  /// -
  ///
  /// ## Do not contains payment amount in-grace-period for previous-statement.
  ///
  /// Serve as the "start-point" of a statement. **ONLY THIS VALUE** is used to "bring" from
  /// previous to next statement recursively. That is why no payment in grace period is counted twice.
  ///
  /// In other word, the balance calculation of last statement only stop at previous [date.end], the payment
  /// in previous grace period (in this statement) is not counted
  ///
  /// -
  ///
  /// ## [carry.interest] is not included
  ///
  StmStartPoint get startPoint => (
        totalRemaining: _previousStatement.balanceAtEndDate,
        remainingToPay: _previousStatement.balanceToPayAtEndDate,
      );

  /// ## Contains data at "end-point" of this [Statement].
  ///
  /// Use **[date.end]** as the "end-point" of each statement when calculate the "bring" amount from
  /// previous to next statement recursively. That is why no payment in grace period is counted twice.
  ///
  /// ```dart
  ///   totalSpent = startPoint.totalBalance + _rawSpent.inBillingCycle.all
  ///   spentToPay = startPoint.balanceToPay + installmentsToPay + _rawSpent.inBillingCycle.toPay
  /// ```
  ///
  /// If **[checkpoint]** is not null, will use [checkpoint]'s value
  ///
  /// -
  ///
  /// ## Not included [paid] and [carry.interest]
  ///
  StmEndPoint get endPoint => (
        totalSpent: checkpoint?.oustdBalance ?? startPoint.totalRemaining + _rawSpent.inBillingCycle.all,
        spentToPay:
            checkpoint?.unpaidToPay ?? startPoint.remainingToPay + installmentsToPay + _rawSpent.inBillingCycle.toPay,
      );

  /// ## Installments to pay.
  ///
  /// Included in [endPoint.spentToPay], [balance] and [balanceToPayAt]
  ///
  ///TODO: modify the can pay in current statement
  double get installmentsToPay {
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

  /// ## Total amount of payment counted for this statement.
  /// ### The code of sub-class must include [checkpoint] null check
  ///
  /// Included:
  /// - payment surplus in previous grace period (in case of payable in billing cycle)
  /// ```dart
  ///   = math.max(0, _rawPaid.inBillingCycle.inPreviousGracePeriod - startPoint.toPay),
  /// ```
  /// - in-billing-cycle-after-previous-grace-period (in case of payable in billing cycle)
  /// ```dart
  ///   = _rawPaid.inBillingCycle.all - _rawPaid.inBillingCycle.inPreviousGracePeriod,
  /// ```
  /// - in-grace-period.
  ///
  /// For each statement type, will need to override because of the different
  /// whether the statement is allow to pay directly in billing cycle or not.
  ///
  double get paid {
    if (checkpoint != null) {
      return math.max(0, _rawPaid.inGracePeriod - _rawSpent.inGracePeriod.toPay);
    }

    // Only count surplus amount of payment in previous grace period
    // for this statement
    final paidInPreviousGracePeriodSurplusForThisStatement =
        math.max(0, _rawPaid.inBillingCycle.inPreviousGracePeriod - startPoint.remainingToPay);

    final paidInBillingCycleAfterPreviousDueDate =
        _rawPaid.inBillingCycle.all - _rawPaid.inBillingCycle.inPreviousGracePeriod;

    // Can be higher than spent amount in billing cycle.
    final paidAmount = paidInPreviousGracePeriodSurplusForThisStatement +
        paidInBillingCycleAfterPreviousDueDate +
        _rawPaid.inGracePeriod;

    // Math.min to remove surplus amount of payment in grace period
    return math.min(spent.inBillingCycle.toPay, paidAmount);
  }

  /// ## The balance remaining to pay of this statement
  ///
  double get balance {
    double value;
    if (checkpoint == null) {
      value = (carry.interest + carry.balanceToPay + _rawSpent.inBillingCycle.toPay + installmentsToPay) - paid;
    } else {
      value = checkpoint!.unpaidToPay - paid;
    }

    return math.max(0, value); // Just to make sure it is not under 0
  }

  /// To assign as previous statement of the next [Statement] object
  ///
  /// When reading this getter, you must understand that all the
  /// property that assign to [PreviousStatement] is of "this current [Statement]".
  ///
  /// ```dart
  ///   ThisStatement.bringToNextStatement -> NextStatement._previousStatement
  /// ```
  ///
  PreviousStatement get bringToNextStatement {
    StmStartPoint atEndPoint = (
      totalRemaining:
          checkpoint?.oustdBalance ?? (endPoint.totalSpent + carry.interest - _rawPaid.inBillingCycle.all).roundTo2DP(),
      remainingToPay:
          checkpoint?.unpaidToPay ?? (endPoint.spentToPay + carry.interest - _rawPaid.inBillingCycle.all).roundTo2DP(),
    );

    final x = (atEndPoint.remainingToPay - _rawPaid.inGracePeriod).roundTo2DP();

    StmCarryWithInterestData bring = (
      totalBalance: (atEndPoint.totalRemaining - _rawPaid.inGracePeriod).roundTo2DP(),
      balanceToPay: x,
      interest: (x > 0 || carry.balanceToPay > 0) && checkpoint == null ? _interest : 0.0,
    );

    return PreviousStatement._(
      math.max(0, atEndPoint.remainingToPay),
      math.max(0, atEndPoint.totalRemaining),
      balance: math.max(0, bring.totalBalance),
      balanceToPay: math.max(0, bring.balanceToPay),
      interest: bring.interest,
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
