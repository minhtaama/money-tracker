part of 'account_base.dart';

@immutable
class Statement {
  const Statement(this._creditAccount, {required this.carryingOver, required this.beginDate, required this.dueDate});

  final CreditAccount _creditAccount;

  final double carryingOver;

  final DateTime beginDate;

  final DateTime dueDate;
}

extension StatementDetails on Statement {
  List<BaseCreditTransaction> get transactionsList {
    final list = List.empty(growable: true) as List<BaseCreditTransaction>;
    for (BaseCreditTransaction transaction in _creditAccount.transactionsList) {
      switch (transaction) {
        case CreditSpending():
          if (transaction.dateTime.isAfter(beginDate) &&
              transaction.dateTime.isBefore(beginDate.copyWith(month: beginDate.month + 1))) {
            list.add(transaction);
          }
          break;
        case CreditPayment():
          if (transaction.dateTime.isAfter(beginDate) && transaction.dateTime.isBefore(dueDate)) {
            list.add(transaction);
          }
          break;
      }
    }
    return list;
  }

  double get spendingAmount {
    double spending = 0;
    for (BaseCreditTransaction transaction in transactionsList) {
      if (transaction is CreditSpending) {
        spending += transaction.amount;
      }
    }
    return spending;
  }

  double get paymentAmount {
    double payment = 0;
    for (BaseCreditTransaction transaction in transactionsList) {
      if (transaction is CreditPayment) {
        payment += transaction.amount;
      }
    }
    return payment;
  }

  // https://www.youtube.com/watch?v=SnlHbMIWJak
  //TODO: YOU FORGOT THE "Average Daily Balance"
  double get interest {
    if (outstandingBalance <= 0) {
      return 0;
    }

    return outstandingBalance * (_creditAccount.apr / (365 * 100));
  }

  double get outstandingBalance => carryingOver + spendingAmount - paymentAmount;

  /// Tiền nợ cộng dồn sang kỳ sau
  ///
  /// Assign to `carryingOverDebt` of the next Statement object
  double get cumulativeDebt => outstandingBalance + interest;
}
