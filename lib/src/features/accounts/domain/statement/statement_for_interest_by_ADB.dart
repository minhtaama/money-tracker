part of 'statement.dart';

@immutable
class StatementWithAverageDailyBalance extends Statement {
  const StatementWithAverageDailyBalance._(
    this._spentInPrvGracePeriod,
    this._spentInBillingCycleAfterPrvGracePeriod,
    this._spentInGracePeriod,
    this._paidInPrvGracePeriodForCurStatement,
    this._paidInPrvGracePeriodForPrvStatement,
    this._paidInBillingCycleAfterPrvGracePeriod,
    this._paidInGracePeriod,
    this._averageDailyBalance, {
    required super.apr,
    required super.previousStatement,
    required super.startDate,
    required super.endDate,
    required super.dueDate,
    required super.transactionsInBillingCycle,
    required super.transactionsInGracePeriod,
  });

  final double _spentInPrvGracePeriod;
  final double _spentInBillingCycleAfterPrvGracePeriod;
  final double _spentInGracePeriod;
  final double _paidInPrvGracePeriodForCurStatement;
  final double _paidInPrvGracePeriodForPrvStatement;
  final double _paidInBillingCycleAfterPrvGracePeriod;
  final double _paidInGracePeriod;
  final double _averageDailyBalance;

  @override
  PreviousStatement get carryToNextStatement {
    return PreviousStatement._(
      balance: _balanceCarryToNextStatement,
      pendingForGracePeriod: _pendingForGracePeriod,
      interest: _interestCarryToNextStatement,
      dueDate: dueDate,
    );
  }

  @override
  double getFullPaymentAmountAt(DateTime dateTime) {
    // Remaining balance before chosen dateTime
    final x = previousStatement.carryOverWithInterest +
        _remainingSpentInPrvGracePeriod +
        _spentAmountInBillingCycleAfterPreviousGracePeriodBefore(dateTime) +
        _spentAmountInGracePeriodBefore(dateTime) -
        _paidAmountFromEndDateBefore(dueDate) -
        _paidAmountInBillingCycleAfterPreviousGracePeriodBefore(dueDate);

    if (x < 0) {
      return 0;
    } else {
      return x;
    }
  }

  factory StatementWithAverageDailyBalance._create({
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required int statementDay,
    required int paymentDueDay,
    required double apr,
    required List<BaseCreditTransaction> transactionsList,
  }) {
    final DateTime endDate = startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;
    final DateTime dueDate = statementDay >= paymentDueDay
        ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
        : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

    List<BaseCreditTransaction> txnsInBillingCycle = List.empty(growable: true);
    List<BaseCreditTransaction> txnsInGracePeriod = List.empty(growable: true);
    double spentInPreviousGracePeriod = 0;
    double spentInBillingCycleAfterPreviousGracePeriod = 0;
    double spentInGracePeriod = 0;
    double paidInPreviousGracePeriodForThis = 0;
    double paidInPreviousGracePeriodForPrevious = 0;
    double paidInBillingCycleAfterPreviousGracePeriod = 0;
    double paidInGracePeriod = 0;

    double pendingOfPreviousStatement = previousStatement.pendingForGracePeriod;

    // Calculate sum of daily balance from `tCheckpointDateTime` to current Txn DateTime
    // If this is the first Txn in the list, `tCheckpointDateTime` is `Statement.startDate`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.carryOverWithInterest;
    DateTime tCheckpointDateTime = startDate;

    for (int i = 0; i <= transactionsList.length - 1; i++) {
      final txn = transactionsList[i];

      if (txn.dateTime.isBefore(startDate)) {
        continue;
      }

      if (txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        if (i >= 1) {
          tCheckpointDateTime = transactionsList[i - 1].dateTime;
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
            spentInPreviousGracePeriod += txn.amount;
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
            paidInPreviousGracePeriodForPrevious += math.min(txn.amount, pendingOfPreviousStatement);
            paidInPreviousGracePeriodForThis += math.max(0, txn.amount - pendingOfPreviousStatement);
            pendingOfPreviousStatement = math.max(0, pendingOfPreviousStatement - paidInPreviousGracePeriodForPrevious);

            tCurrentBalance -= paidInPreviousGracePeriodForThis;
          }
        }
      }

      if (i >= 1) {
        tCheckpointDateTime = transactionsList[i - 1].dateTime;
      }
    }

    tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(endDate);

    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    return StatementWithAverageDailyBalance._(
      spentInPreviousGracePeriod,
      spentInBillingCycleAfterPreviousGracePeriod,
      spentInGracePeriod,
      paidInPreviousGracePeriodForThis,
      paidInPreviousGracePeriodForPrevious,
      paidInBillingCycleAfterPreviousGracePeriod,
      paidInGracePeriod,
      averageDailyBalance,
      previousStatement: previousStatement,
      startDate: startDate,
      endDate: endDate,
      dueDate: dueDate,
      transactionsInBillingCycle: txnsInBillingCycle,
      transactionsInGracePeriod: txnsInGracePeriod,
      apr: apr,
    );
  }
}

extension _CalculateBalanceAndInterest on StatementWithAverageDailyBalance {
  /// Remaining spent amount after previous grace period that is left to this statement to pay
  double get _remainingSpentInPrvGracePeriod =>
      math.max(0, _spentInPrvGracePeriod - _paidInPrvGracePeriodForCurStatement);

  /// Remaining surplus payment amount after previous grace period count to this statement
  double get _remainingPaidInPreviousGracePeriod =>
      math.max(0, _paidInPrvGracePeriodForCurStatement - _spentInPrvGracePeriod);

  /// Total spent amount until this statement billing cycle end (until endDate)
  double get _totalSpent =>
      previousStatement.carryOverWithInterest +
      _remainingSpentInPrvGracePeriod +
      _spentInBillingCycleAfterPrvGracePeriod;

  /// Total payment amount until this statement billing cycle end (until endDate)
  double get _totalPaidBeforeEndDate => _paidInPrvGracePeriodForCurStatement + _paidInBillingCycleAfterPrvGracePeriod;

  /// Total payment amount in this billing cycle and the grace period
  ///
  /// This amount can be included the payment amount for spent of next statement but inside this
  /// statement grace period
  double get _totalPaid =>
      _remainingPaidInPreviousGracePeriod + _paidInBillingCycleAfterPrvGracePeriod + _paidInGracePeriod;

  /// The interest of this statement
  double get _interest => _averageDailyBalance * (apr / (365 * 100)) * startDate.getDaysDifferent(endDate);

  /// The spent amount that will be carried over to next statement.
  ///
  ///
  double get _balanceCarryToNextStatement => math.max(0, _totalSpent - _totalPaid);

  double get _pendingForGracePeriod =>
      previousStatement.carryOverWithInterest +
      _spentInPrvGracePeriod +
      _spentInBillingCycleAfterPrvGracePeriod -
      _totalPaidBeforeEndDate;

  double get _interestCarryToNextStatement =>
      _balanceCarryToNextStatement > 0 || previousStatement.carryOverWithInterest > 0 ? _interest : 0;

  double _spentAmountInGracePeriodBefore(DateTime dateTime) {
    double amount = 0;
    final list = transactionsInGracePeriodBefore(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double _spentAmountInBillingCycleAfterPreviousGracePeriodBefore(DateTime dateTime) {
    double amount = 0;
    final list = transactionsInBillingCycleBefore(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
        amount += txn.amount;
      }
    }
    return amount;
  }

  double _paidAmountFromEndDateBefore(DateTime dateTime) {
    double amount = 0;
    final list = transactionsInGracePeriodBefore(dateTime).whereType<CreditPayment>();
    for (CreditPayment txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  /// Because all [CreditPayment] and [CreditSpending] that happens in previous grace period
  /// (before [PreviousStatement.dueDate]) will be counted in [_remainingSpentInPrvGracePeriod].
  double _paidAmountInBillingCycleAfterPreviousGracePeriodBefore(DateTime dateTime) {
    double amount = 0;
    final list = transactionsInBillingCycleBefore(dateTime).whereType<CreditPayment>();
    for (CreditPayment txn in list) {
      if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
        amount += txn.amount;
      }
    }
    return amount;
  }
}
