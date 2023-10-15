part of 'account_base.dart';

@immutable
class Statement {
  const Statement(this._creditAccount, {required this.lastStatement, required this.startDate});

  final CreditAccount _creditAccount;

  final CarryingOverDetails lastStatement;

  final DateTime startDate;

  Statement copyWith({
    CreditAccount? creditAccount,
    CarryingOverDetails? lastStatement,
    DateTime? startDate,
  }) {
    return Statement(
      creditAccount ?? _creditAccount,
      lastStatement: lastStatement ?? this.lastStatement,
      startDate: startDate ?? this.startDate,
    );
  }
}

@immutable
class CarryingOverDetails {
  const CarryingOverDetails(this.remainingBalance, this.interest);

  final double remainingBalance;
  final double interest;

  double get carryToThisStatement => remainingBalance + interest;

  @override
  String toString() {
    return 'CarryingOverDetails{outstandingBalance: $remainingBalance, interest: $interest}';
  }
}

// https://www.youtube.com/watch?v=SnlHbMIWJak
extension StatementDetails on Statement {
  DateTime get endDate => startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1);

  DateTime get dueDate {
    if (_creditAccount.statementDay >= _creditAccount.paymentDueDay) {
      return startDate.copyWith(month: startDate.month + 2, day: _creditAccount.paymentDueDay);
    } else {
      return startDate.copyWith(month: startDate.month + 1, day: _creditAccount.paymentDueDay);
    }
  }

  DateTime get lastStatementDueDate {
    if (_creditAccount.statementDay >= _creditAccount.paymentDueDay) {
      return startDate.copyWith(month: startDate.month + 1, day: _creditAccount.paymentDueDay);
    } else {
      return startDate.copyWith(month: startDate.month, day: _creditAccount.paymentDueDay);
    }
  }

  /// Include [CreditSpending] of next statement, but happens between
  /// this statement `endDate` and `dueDate`.
  List<BaseCreditTransaction> get txnsFromBeginToDueDate {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= _creditAccount.transactionsList.length - 1; i++) {
      final transaction = _creditAccount.transactionsList[i];

      if (transaction.dateTime.isBefore(startDate)) {
        continue;
      }

      if (transaction.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        break;
      }

      if (transaction.dateTime.isBefore(dueDate)) {
        list.add(transaction);
        continue;
      }
    }

    return list;
  }

  /// Returns [CreditSpending] between `startDate` and `endDate`.
  ///
  /// Returns [CreditPayment] between `startDate` and `dueDate`
  List<BaseCreditTransaction> get txnsOfThisStatement {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= txnsFromBeginToDueDate.length - 1; i++) {
      final transaction = txnsFromBeginToDueDate[i];

      if (transaction is CreditSpending && transaction.dateTime.isBefore(endDate)) {
        list.add(transaction);
        continue;
      }

      if (transaction is CreditPayment) {
        list.add(transaction);
        continue;
      }
    }

    return list;
  }

  double get spentAmount {
    double spending = 0;
    for (BaseCreditTransaction transaction in txnsOfThisStatement) {
      if (transaction is CreditSpending) {
        spending += transaction.amount;
      }
    }
    return spending;
  }

  /// Excluded surplus payment amount of last statement and next statement if there are
  /// payments transactions happens "not after [lastStatementDueDate]" and "after [endDate]"
  /// of this statement.
  double get paidAmount {
    double totalAmountNotAfterLastStatementDueDate = 0; // Might include last statement payment
    double totalAmountAfterThisStatementEndDate = 0; // Might include next statement payment
    double amountOnlyForThisStatement = 0;

    final list = txnsOfThisStatement.whereType<CreditPayment>();

    for (CreditPayment payment in list) {
      if (!payment.dateTime.onlyYearMonthDay.isAfter(lastStatementDueDate)) {
        totalAmountNotAfterLastStatementDueDate += payment.amount;
      }
      if (payment.dateTime.onlyYearMonthDay.isAfter(endDate)) {
        totalAmountAfterThisStatementEndDate += payment.amount;
      } else {
        amountOnlyForThisStatement += payment.amount;
      }
    }

    double amountNotAfterLastStatementDueDateForThisStatement =
        math.max(0, totalAmountNotAfterLastStatementDueDate - lastStatement.remainingBalance);
    double amountAfterThisStatementEndDateForThisStatement = math.max(
        0, totalAmountAfterThisStatementEndDate - spentAmountFromEndDateOfNextStatementUntil(dueDate));

    return amountOnlyForThisStatement +
        amountNotAfterLastStatementDueDateForThisStatement +
        amountAfterThisStatementEndDateForThisStatement;
  }

  double get averageDailyBalance {
    double sum = 0;
    DateTime prvDateTime = startDate;
    double balance = lastStatement.carryToThisStatement;

    for (int i = 0; i <= txnsFromBeginToDueDate.length - 1; i++) {
      final transaction = txnsFromBeginToDueDate[i];

      sum += balance * prvDateTime.getDaysDifferent(transaction.dateTime);

      if (transaction is CreditSpending) {
        balance += transaction.amount;
      }
      if (transaction is CreditPayment) {
        balance -= transaction.amount;
      }

      prvDateTime = transaction.dateTime;
    }

    if (txnsFromBeginToDueDate.isNotEmpty) {
      sum += balance * txnsFromBeginToDueDate.last.dateTime.getDaysDifferent(endDate);
    } else {
      sum += balance * startDate.getDaysDifferent(endDate);
    }

    return sum / startDate.getDaysDifferent(endDate);
  }

  double get interest {
    if (remainingBalance <= 0) {
      return 0;
    }
    final interest =
        averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);
    return interest;
  }

  double get remainingBalance {
    double result = lastStatement.carryToThisStatement + spentAmount - paidAmount;
    if (result < 0) {
      return 0;
    }
    return result;
  }

  /// Assign to `carryingOver` of the next Statement object
  CarryingOverDetails get carryToNextStatement => CarryingOverDetails(remainingBalance, interest);
}

extension NextStatementDetails on Statement {
  /// Hard upper gap at this statement [endDate]
  List<BaseCreditTransaction> txnsFromStartDateOfThisStatementUntil(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= _creditAccount.transactionsList.length - 1; i++) {
      final transaction = _creditAccount.transactionsList[i];

      if (transaction.dateTime.isBefore(startDate)) {
        continue;
      }

      if (transaction.dateTime.isAfter(endDate.copyWith(day: endDate.day + 1))) {
        break;
      }

      if (transaction.dateTime.isBefore(dateTime)) {
        list.add(transaction);
        continue;
      }
    }

    return list;
  }

  /// Hard upper gap at this statement [dueDate]
  List<BaseCreditTransaction> txnsFromEndDateOfNextStatementUntil(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    if (!dateTime.isAfter(endDate)) {
      return list;
    }

    for (int i = 0; i <= _creditAccount.transactionsList.length - 1; i++) {
      final transaction = _creditAccount.transactionsList[i];

      if (transaction.dateTime.isBefore(endDate)) {
        continue;
      }

      if (transaction.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        break;
      }

      if (transaction.dateTime.isBefore(dateTime)) {
        list.add(transaction);
        continue;
      }
    }

    return list;
  }

  double spentAmountFromEndDateOfNextStatementUntil(DateTime dateTime) {
    double amount = 0;
    final list = txnsFromEndDateOfNextStatementUntil(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double spentAmountFromStartDateOfThisStatementUntil(DateTime dateTime) {
    double amount = lastStatement.carryToThisStatement;
    final list = txnsFromStartDateOfThisStatementUntil(dateTime).whereType<CreditSpending>();
    for (CreditSpending txn in list) {
      amount += txn.amount;
    }
    return amount;
  }

  double paymentAmountAt(DateTime dateTime) {
    return spentAmountFromStartDateOfThisStatementUntil(dateTime) +
        spentAmountFromEndDateOfNextStatementUntil(dateTime);
  }
}
