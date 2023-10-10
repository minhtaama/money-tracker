part of 'account_base.dart';

@immutable
class CreditAccount extends Account {
  @override
  final List<BaseCreditTransaction> transactionsList;

  final double creditBalance;

  /// (APR) As in percent.
  final double apr;

  final int statementDay;

  final int paymentDueDay;

  const CreditAccount._(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.creditBalance,
    required this.apr,
    required this.statementDay,
    required this.paymentDueDay,
    required this.transactionsList,
  });

  // @override
  // List<BaseCreditTransaction> get transactionsList {
  //   final List<BaseCreditTransaction> list = List.from(databaseObject.transactions
  //       .query('TRUEPREDICATE SORT(dateTime ASC)')
  //       .map<BaseCreditTransaction>((txn) => BaseTransaction.fromIsar(txn) as BaseCreditTransaction));
  //   return list;
  // }
}

extension CreditAccountDateTimeDetails on CreditAccount {
  DateTime? get earliestPayableDate {
    if (transactionsList.isEmpty) {
      return null;
    }

    return transactionsList.first.dateTime;
  }

  /// only year, month and day
  DateTime? get earliestStatementDate {
    if (transactionsList.isEmpty || earliestPayableDate == null) {
      return null;
    }

    if (statementDay > earliestPayableDate!.day) {
      return DateTime(earliestPayableDate!.year, earliestPayableDate!.month - 1, statementDay);
    }

    if (statementDay <= earliestPayableDate!.day) {
      return earliestPayableDate!.copyWith(day: statementDay).onlyYearMonthDay;
    }

    return null;
  }

  DateTime? get latestSpendingDate {
    if (transactionsList.isEmpty) {
      return null;
    }

    return transactionsList.last.dateTime;
  }

  /// only year, month and day
  DateTime? get latestStatementDate {
    if (transactionsList.isEmpty || latestSpendingDate == null) {
      return null;
    }

    if (statementDay > latestSpendingDate!.day) {
      return DateTime(earliestPayableDate!.year, earliestPayableDate!.month - 1, statementDay);
    }

    if (statementDay <= latestSpendingDate!.day) {
      return earliestPayableDate!.copyWith(day: statementDay).onlyYearMonthDay;
    }

    return null;
  }

  bool isAfterOrSameAsStatementDay(DateTime dateTime) => dateTime.day >= statementDay;

  bool isBeforeOrSameAsPaymentDueDay(DateTime dateTime) => dateTime.day <= paymentDueDay;

  List<DateTime> nextPaymentPeriod(DateTime dateTime) {
    DateTime statementDate;
    DateTime paymentDueDate;

    if (isAfterOrSameAsStatementDay(dateTime)) {
      statementDate = DateTime(dateTime.year, dateTime.month, statementDay);
      paymentDueDate = DateTime(dateTime.year, dateTime.month + 1, paymentDueDay);
    }
    if (isBeforeOrSameAsPaymentDueDay(dateTime)) {
      statementDate = DateTime(dateTime.year, dateTime.month - 1, statementDay);
      paymentDueDate = DateTime(dateTime.year, dateTime.month, paymentDueDay);
    } else {
      statementDate = DateTime(dateTime.year, dateTime.month, statementDay);
      paymentDueDate = DateTime(dateTime.year, dateTime.month + 1, paymentDueDay);
    }

    return List.from([statementDate, paymentDueDate], growable: false);
  }
}

extension CreditAccountDetails on CreditAccount {
  List<CreditSpending> get spendingTransactionsList => transactionsList.whereType<CreditSpending>().toList();

  // List<CreditSpending> spendingTxnsInThisStatementBefore(DateTime dateTime) {
  //   DateTime date;
  //   if (dateTime.day >= statementDay) {
  //     date = dateTime.copyWith(day: statementDay);
  //   } else if (dateTime.day <= paymentDueDay) {
  //     date = dateTime.copyWith(day: statementDay, month: dateTime.month - 1);
  //   } else {
  //     date = dateTime;
  //   }
  //
  //   return spendingTransactionsList.where((txn) => !txn.isDone && txn.dateTime.isBefore(date)).toList();
  // }

  List<Statement> get statementsList {
    final List<Statement> list = List.empty(growable: true);

    if (earliestStatementDate == null || latestStatementDate == null) {
      return list;
    }

    for (DateTime begin = earliestStatementDate!;
        begin.compareTo(latestStatementDate!) <= 0;
        begin = begin.copyWith(month: begin.month + 1)) {
      double carryingOver = 0;
      if (begin != earliestStatementDate!) {
        carryingOver = list[list.length - 1].carryToNextStatement;
      }
      Statement statement = Statement(this, carryingOver: carryingOver, beginDate: begin);
      list.add(statement);
    }

    return list;
  }

  /// Return `null` if no statement is found
  Statement? statementAt(DateTime dateTime) {
    if (statementsList.isEmpty) {
      return null;
    }

    final date = dateTime.onlyYearMonthDay;
    final latestStatement = statementsList[statementsList.length - 1];

    // If statement is already in credit account statements list
    for (Statement statement in statementsList) {
      if (date.compareTo(statement.beginDate) >= 0 && date.compareTo(statement.dueDate) < 0) {
        return statement;
      }
    }

    // Get future statement
    if (date.compareTo(latestStatement.dueDate) >= 0) {
      final list = [latestStatement];

      for (DateTime begin = latestStatement.endDate;
          begin.compareTo(date) <= 0;
          begin = begin.copyWith(month: begin.month + 1)) {
        double carryingOver = list.last.carryToNextStatement;
        Statement statement = Statement(this, carryingOver: carryingOver, beginDate: begin);
        list.add(statement);
      }
      return list.last;
    }

    return null;
  }
}
