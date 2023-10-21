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

    return transactionsList.whereType<CreditSpending>().last.dateTime;
  }

  /// only year, month and day
  DateTime? get latestStatementDate {
    if (transactionsList.isEmpty || latestSpendingDate == null) {
      return null;
    }

    if (statementDay > latestSpendingDate!.day) {
      return DateTime(latestSpendingDate!.year, latestSpendingDate!.month - 1, statementDay);
    }

    if (statementDay <= latestSpendingDate!.day) {
      return latestSpendingDate!.copyWith(day: statementDay).onlyYearMonthDay;
    }

    return null;
  }
}

extension CreditAccountDetails on CreditAccount {
  List<CreditSpending> get spendingTransactions => transactionsList.whereType<CreditSpending>().toList();
  List<CreditPayment> get paymentTransactions => transactionsList.whereType<CreditPayment>().toList();

  List<Statement> get statements {
    final List<Statement> list = List.empty(growable: true);

    if (earliestStatementDate == null || latestStatementDate == null) {
      return list;
    }

    for (DateTime begin = earliestStatementDate!;
        begin.compareTo(latestStatementDate!) <= 0;
        begin = begin.copyWith(month: begin.month + 1)) {
      PreviousStatement lastStatementDetails = PreviousStatement.noData();
      if (begin != earliestStatementDate!) {
        lastStatementDetails = list.last.carryToNextStatement;
      }
      Statement statement = Statement.create(this, previousStatement: lastStatementDetails, startDate: begin);
      list.add(statement);
    }

    return list;
  }

  /// Return `null` if no statement is found.
  ///
  /// Get whole `Statement` object contains the `dateTime`
  Statement? statementAt(DateTime dateTime) {
    if (statements.isEmpty) {
      return null;
    }

    final date = dateTime.onlyYearMonthDay;
    final latestStatement = statements[statements.length - 1];

    // If statement is already in credit account statements list
    for (Statement statement in statements) {
      if (date.compareTo(statement.startDate) >= 0 && date.compareTo(statement.dueDate) <= 0) {
        return statement;
      }
    }

    // Get future statement
    if (date.compareTo(latestStatement.dueDate) > 0) {
      final list = [latestStatement];

      for (DateTime begin = latestStatement.endDate.copyWith(day: latestStatement.endDate.day + 1);
          begin.compareTo(date) <= 0;
          begin = begin.copyWith(month: begin.month + 1)) {
        PreviousStatement lastStatement = list.last.carryToNextStatement;
        Statement statement = Statement.create(this, previousStatement: lastStatement, startDate: begin);
        list.add(statement);
      }
      return list.last;
    }

    return null;
  }
}
