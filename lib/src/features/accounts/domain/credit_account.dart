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
  List<CreditSpending> get transactionsList {
    final List<CreditSpending> list = List.from(
        databaseObject.transactions.map<CreditSpending>((txn) => BaseTransaction.fromIsar(txn) as CreditSpending));
    list.sort((a, b) {
      return a.dateTime.isBefore(b.dateTime) ? -1 : 1;
    });
    return list;
  }
}

extension CreditDetails on CreditAccount {
  List<CreditSpending> get allUnpaidSpendingTxns => transactionsList.where((txn) => !txn.isDone).toList();

  List<CreditSpending> unpaidSpendingTxnsBefore(DateTime dateTime) {
    DateTime date;
    if (dateTime.day >= statementDay) {
      date = dateTime.copyWith(day: statementDay);
    } else if (dateTime.day <= paymentDueDay) {
      date = dateTime.copyWith(day: statementDay, month: dateTime.month - 1);
    } else {
      date = dateTime;
    }

    return allUnpaidSpendingTxns.where((txn) => !txn.isDone && txn.dateTime.isBefore(date)).toList();
  }

  double get totalPendingCreditPayment {
    double pendingPayment = 0;
    for (CreditSpending txn in allUnpaidSpendingTxns) {
      pendingPayment += txn.paymentAmount;
    }
    return pendingPayment;
  }

  DateTime? get earliestPayableDate {
    DateTime time = DateTime.now();

    final list = transactionsList.where((txn) => !txn.isDone).toList();

    if (list.isEmpty) {
      return null;
    }

    // Get earliest spending transaction un-done
    for (CreditSpending txn in list) {
      if (txn.dateTime.isBefore(time)) {
        time = txn.dateTime;
      }
    }

    // Earliest day that payment can happens
    if (time.day <= paymentDueDay) {
      time = time.copyWith(day: paymentDueDay + 1).onlyYearMonthDay;
    } else if (time.day >= statementDay) {
      time = time.copyWith(day: paymentDueDay + 1, month: time.month + 1).onlyYearMonthDay;
    }

    return time;
  }

  bool isAfterOrSameAsStatementDay(DateTime dateTime) => dateTime.day >= statementDay;

  bool isBeforeOrSameAsPaymentDueDay(DateTime dateTime) => dateTime.day <= paymentDueDay;

  bool isInPaymentPeriod(DateTime dateTime) {
    if (isAfterOrSameAsStatementDay(dateTime) || isBeforeOrSameAsPaymentDueDay(dateTime)) {
      return true;
    } else {
      return false;
    }
  }

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
