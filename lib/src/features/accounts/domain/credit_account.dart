part of 'account_base.dart';

@immutable
class CreditAccount extends Account {
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
  });

  @override
  List<BaseCreditTransaction> get transactionsList {
    final List<BaseCreditTransaction> list = List.from(databaseObject.transactions
        .query('SORT(dateTime ASC)')
        .map<BaseCreditTransaction>((txn) => BaseTransaction.fromIsar(txn) as BaseCreditTransaction));
    // list.sort((a, b) {
    //   return a.dateTime.compareTo(b.dateTime);
    // });
    return list;
  }
}

extension CreditAccountDateTimeDetails on CreditAccount {
  DateTime? get earliestPayableDate {
    if (transactionsList.isEmpty) {
      return null;
    }

    return transactionsList[0].dateTime;
  }

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

  List<CreditSpending> spendingTxnsInThisStatementBefore(DateTime dateTime) {
    DateTime date;
    if (dateTime.day >= statementDay) {
      date = dateTime.copyWith(day: statementDay);
    } else if (dateTime.day <= paymentDueDay) {
      date = dateTime.copyWith(day: statementDay, month: dateTime.month - 1);
    } else {
      date = dateTime;
    }

    return spendingTransactionsList.where((txn) => !txn.isDone && txn.dateTime.isBefore(date)).toList();
  }

  // double get carryAmount

  double get outstandingBalance {
    double pendingPayment = 0;
    for (CreditSpending txn in spendingTransactionsList) {
      pendingPayment += txn.paymentAmount;
    }
    return pendingPayment;
  }

  List<Statement> get statementsList {
    final List<Statement> list = List.empty(growable: true);
  }
}
