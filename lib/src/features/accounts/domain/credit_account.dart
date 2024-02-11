part of 'account_base.dart';

@immutable
class CreditAccount extends Account {
  /// Already sorted by transactions dateTime when created
  @override
  final List<BaseCreditTransaction> transactionsList;

  final List<Statement> statementsList;

  final double creditLimit;

  /// (APR) As in percent.
  final double apr;

  final int statementDay;

  final int paymentDueDay;

  final DateTime? earliestPayableDate;

  final DateTime? earliestStatementDate;

  final StatementType statementType;

  const CreditAccount._(
    super._databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    required this.creditLimit,
    required this.apr,
    required this.statementDay,
    required this.paymentDueDay,
    required this.earliestStatementDate,
    required this.earliestPayableDate,
    required this.transactionsList,
    required this.statementsList,
    required this.statementType,
  });
}

extension CreditAccountMethods on CreditAccount {
  List<CreditSpending> get spendingTransactions => transactionsList.whereType<CreditSpending>().toList();
  List<CreditPayment> get paymentTransactions => transactionsList.whereType<CreditPayment>().toList();
  List<CreditCheckpoint> get checkpointTransactions => transactionsList.whereType<CreditCheckpoint>().toList();

  DateTime get latestCheckpointDateTime {
    CreditCheckpoint? lastCheckpoint = checkpointTransactions.isNotEmpty ? checkpointTransactions.last : null;

    return lastCheckpoint?.dateTime.onlyYearMonthDay ?? Calendar.minDate;
  }

  DateTime get latestStatementDueDate {
    Statement? statement = paymentTransactions.isNotEmpty ? statementAt(paymentTransactions.last.dateTime)! : null;

    return statement?.date.previousDue.onlyYearMonthDay ?? Calendar.minDate;
  }

  DateTime get todayStatementDueDate {
    final today = DateTime.now().onlyYearMonthDay;
    if (today.day <= paymentDueDay) {
      return today.copyWith(day: paymentDueDay);
    } else {
      return today.copyWith(day: paymentDueDay, month: today.month + 1);
    }
  }

  bool isInGracePeriod(DateTime dateTime) {
    if (paymentDueDay < statementDay) {
      if (dateTime.day <= paymentDueDay || dateTime.day >= statementDay) {
        return true;
      }
      return false;
    } else {
      if (dateTime.day <= paymentDueDay && dateTime.day >= statementDay) {
        return true;
      }
      return false;
    }
  }

  ///Find the next [CreditPayment] from since this [CreditSpending] date time
  ///
  /// Throw state error if no payment is found
  CreditPayment getNextPayment({required CreditSpending from}) {
    return paymentTransactions.firstWhere((payment) => payment.dateTime.isAfter(from.dateTime.onlyYearMonthDay));
  }

  /// Return `null` if account has no transaction.
  ///
  /// Get whole `Statement` object contains the `dateTime`
  ///
  /// If `upperGapAtDueDate` is true, will returns statement that dateTime is in grace period.
  Statement? statementAt(DateTime dateTime, {bool? upperGapAtDueDate}) {
    if (statementsList.isEmpty) {
      return null;
    }

    final date = dateTime.onlyYearMonthDay;
    final latestStatement = statementsList[statementsList.length - 1];

    // If statement is already in credit account statements list
    for (Statement statement in statementsList) {
      if (date.compareTo(statement.date.previousDue) > 0 && date.compareTo(statement.date.due) <= 0) {
        return statement;
      }
    }

    // Get future statement
    if (date.compareTo(latestStatement.date.due) > 0) {
      final list = [latestStatement];

      DateTime startDate = latestStatement.date.end.copyWith(day: latestStatement.date.end.day + 1);
      DateTime dueDate = statementDay >= paymentDueDay
          ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
          : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

      while (upperGapAtDueDate != null && upperGapAtDueDate
          ? date.isAfter(list[list.length - 1].date.due)
          : startDate.compareTo(date) <= 0) {
        final endDate = startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;

        final previousStatement = list.last.carryToNextStatement;

        Statement statement = Statement.create(
          statementType,
          previousStatement: previousStatement,
          startDate: startDate,
          endDate: endDate,
          dueDate: dueDate,
          apr: apr,
          installments: const [],
          txnsInGracePeriod: const [],
          txnsInBillingCycle: const [],
          checkpoint: null,
        );

        list.add(statement);

        startDate = startDate.copyWith(month: startDate.month + 1);
        dueDate = statementDay >= paymentDueDay
            ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
            : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;
      }

      return list.last;
    }

    return null;
  }
}
