part of 'account_base.dart';

@immutable
class CreditAccount extends Account {
  /// Already sorted by transactions dateTime when created
  @override
  final List<BaseCreditTransaction> transactionsList;

  final List<Statement> statementsList;

  final double creditBalance;

  /// (APR) As in percent.
  final double apr;

  final int statementDay;

  final int paymentDueDay;

  final DateTime? earliestPayableDate;

  final DateTime? earliestStatementDate;

  const CreditAccount._(
    super._isarObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    required this.creditBalance,
    required this.apr,
    required this.statementDay,
    required this.paymentDueDay,
    required this.earliestStatementDate,
    required this.earliestPayableDate,
    required this.transactionsList,
    required this.statementsList,
  });
}

extension CreditAccountMethods on CreditAccount {
  List<CreditSpending> get spendingTransactions => transactionsList.whereType<CreditSpending>().toList();
  List<CreditPayment> get paymentTransactions => transactionsList.whereType<CreditPayment>().toList();

  bool canAddPaymentAt(DateTime dateTime) {
    Statement statement =
        paymentTransactions.isNotEmpty ? statementAt(paymentTransactions.last.dateTime) : statementsList.last;

    if (dateTime.onlyYearMonthDay.isAfter(statement.previousStatement.dueDate)) {
      return true;
    } else {
      return false;
    }
  }

  /// Return `null` if no statement is found.
  ///
  /// Get whole `Statement` object contains the `dateTime`
  Statement statementAt(DateTime dateTime) {
    final date = dateTime.onlyYearMonthDay;
    final latestStatement = statementsList[statementsList.length - 1];

    // If statement is already in credit account statements list
    for (Statement statement in statementsList) {
      if (date.compareTo(statement.startDate) >= 0 && date.compareTo(statement.dueDate) <= 0) {
        return statement;
      }
    }

    // Get future statement
    if (date.compareTo(latestStatement.dueDate) > 0) {
      final list = [latestStatement];

      for (DateTime startDate = latestStatement.endDate.copyWith(day: latestStatement.endDate.day + 1);
          startDate.compareTo(date) <= 0;
          startDate = startDate.copyWith(month: startDate.month + 1)) {
        PreviousStatement previousStatement = list.last.carryToNextStatement;

        Statement statement = Statement.create(StatementType.withAverageDailyBalance,
            previousStatement: previousStatement,
            startDate: startDate,
            statementDay: statementDay,
            paymentDueDay: paymentDueDay,
            apr: apr,
            transactionsList: transactionsList);

        list.add(statement);
      }
      return list.last;
    }

    throw ErrorDescription('No statement is found');
  }
}
