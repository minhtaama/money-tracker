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

  /// Only specify if user custom this statement data
  /// This is the outstanding balance at [endDate] of statement
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

  /// ## Total amount of payment counted for this statement.
  /// ### The code of sub-class must include [checkpoint] null check
  ///
  /// The code in each statement sub-class will make it not be counted twice
  /// with payment-in-previous-grace-period amount for-previous-statement.
  /// Read the code for more understanding.
  ///
  /// For each statement type, will need to override because of the different
  /// whether the statement is allow to pay directly in billing cycle or not.
  ///
  double get paid;

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
  StmDateData get date => (
        start: _date.start,
        end: _date.end,
        due: _date.due,
        previousDue: _previousStatement.dueDate,
        statement: _date.start.copyWith(month: _date.start.month + 1)
      );

  /// ## Contains only data of spendings in this statement billing cycle, no [carry] amount
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
          all: checkpoint?.oustdBalance ?? _rawSpent.inBillingCycle.all,
          toPay: checkpoint?.unpaidToPay ?? _rawSpent.inBillingCycle.toPay,
        ),
        inGracePeriod: _rawSpent.inGracePeriod.all,
      );

  /// ## The total spent amount, included [carry] and [_rawSpent.inBillingCycle]
  /// ### (Not included [paid] and [carry.interest])
  ///
  /// Use [date.end] as the "end-point" of each statement when calculate the "bring" amount from
  /// previous to next statement recursively. That is why no payment in grace period is counted twice.
  ///
  /// -
  ///
  /// **`all`**  =
  /// [carry.total.excludeGracePayment] + [_rawSpent.inBillingCycle.all]
  ///
  /// -
  ///
  /// **`toPay`** =
  /// [carry.toPay.excludeGracePayment] + [installmentsToPay] + [_rawSpent.inBillingCycle.excludeInstallments]
  ///
  /// -
  ///
  /// If [checkpoint] is not null, will use checkpoint's value
  ///
  StmTotalSpentData get totalSpent => (
        all: checkpoint?.oustdBalance ?? carry.total.excludeGracePayment + _rawSpent.inBillingCycle.all,
        toPay: checkpoint?.unpaidToPay ??
            carry.toPay.excludeGracePayment + installmentsToPay + _rawSpent.inBillingCycle.toPay,
      );

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
  /// Serve as the "start-point" initial amount of a statement. Only this value is used to "bring" from
  /// previous to next statement recursively. That is why no payment in grace period is counted twice.
  ///
  /// In other word, the carry amount calculation of last statement only stop at previous [date.end], the payment
  /// in previous grace period (in this statement) is not counted.
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

  /// ## Installments to pay. Not included in any of [carry] getters
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

  /// ## The balance remaining to pay of this statement
  ///
  /// No need to add any calculation, else.
  ///
  double get balance {
    double value;
    if (checkpoint == null) {
      value = (carry.interest + carry.toPay.includeGracePayment + _rawSpent.inBillingCycle.toPay + installmentsToPay) -
          paid;
    } else {
      value = checkpoint!.unpaidToPay - paid;
    }

    return math.max(0, value); // Just to make sure it is not under 0
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
    final balanceAtEndDate =
        checkpoint?.oustdBalance ?? (totalSpent.all + carry.interest + -_rawPaid.inBillingCycle.all).roundTo2DP();

    final balanceAtEndDateWithPrvGracePayment = (balanceAtEndDate - _rawPaid.inGracePeriod).roundTo2DP();

    final balanceToPayAtEndDate =
        checkpoint?.unpaidToPay ?? (totalSpent.toPay + carry.interest + -_rawPaid.inBillingCycle.all).roundTo2DP();

    final balanceToPayAtEndDateWithPrvGracePayment =
        math.max(0.0, balanceToPayAtEndDate - _rawPaid.inGracePeriod).roundTo2DP();

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
