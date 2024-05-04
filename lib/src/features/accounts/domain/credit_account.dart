part of 'account_base.dart';

abstract interface class _ICreditInfo {
  /// (APR) As in percent.
  final double apr;

  final int statementDay;

  final int paymentDueDay;

  final StatementType statementType;

  _ICreditInfo(
      {required this.apr, required this.statementDay, required this.paymentDueDay, required this.statementType});
}

@immutable
class CreditAccountInfo extends AccountInfo implements _ICreditInfo {
  final double creditLimit;

  /// (APR) As in percent.
  @override
  final double apr;

  @override
  final int statementDay;

  @override
  final int paymentDueDay;

  @override
  final StatementType statementType;

  const CreditAccountInfo._(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    super.isNotExistInDatabase,
    required this.creditLimit,
    required this.apr,
    required this.statementDay,
    required this.paymentDueDay,
    required this.statementType,
  });
}

@immutable
class CreditAccount extends Account implements _ICreditInfo {
  /// Already sorted by transactions dateTime when created
  @override
  final List<BaseCreditTransaction> transactionsList;

  final List<Statement> statementsList;

  final double creditLimit;

  /// (APR) As in percent.
  @override
  final double apr;

  @override
  final int statementDay;

  @override
  final int paymentDueDay;

  final DateTime? earliestPayableDate;

  final DateTime? earliestStatementDate;

  @override
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

  /// Returns closed statements, which can not add transaction into.
  List<Statement> get closedStatementsList {
    final latestPayment = paymentTransactions.isNotEmpty ? statementAt(paymentTransactions.last.dateTime)! : null;
    final latestCheckpoint =
        checkpointTransactions.isNotEmpty ? statementAt(checkpointTransactions.last.dateTime)! : null;

    int latestPaymentIndex = 0;
    int latestCheckpointIndex = 0;
    if (latestPayment != null) {
      latestPaymentIndex = statementsList.indexOf(latestPayment);
    }
    if (latestCheckpoint != null) {
      latestCheckpointIndex = statementsList.indexOf(latestCheckpoint);
    }

    return statementsList.sublist(0, math.max(latestPaymentIndex, latestCheckpointIndex));
  }

  /// Latest closed statement due date (Can not add transaction before this date)
  DateTime get latestClosedStatementDueDate {
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
    // for (Statement statement in statementsList) {
    //   if (date.compareTo(statement.date.previousDue) > 0 && date.compareTo(statement.date.due) <= 0) {
    //     return statement;
    //   }
    // }

    // If statement is already in credit account statements list
    for (int i = 0; i < statementsList.length; i++) {
      final statement = statementsList[i];
      if (i == 0) {
        if (date.compareTo(statement.date.previousDue) >= 0 && date.compareTo(statement.date.due) <= 0) {
          return statement;
        }
      }

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

        final previousStatement = list.last.bringToNextStatement;

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
