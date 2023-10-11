part of 'account_base.dart';

@immutable
class Statement {
  const Statement(this._creditAccount, {required this.carryingOver, required this.startDate});

  final CreditAccount _creditAccount;

  final double carryingOver;

  final DateTime startDate;

  Statement copyWith({
    CreditAccount? creditAccount,
    double? carryingOver,
    DateTime? beginDate,
  }) {
    return Statement(
      creditAccount ?? _creditAccount,
      carryingOver: carryingOver ?? this.carryingOver,
      startDate: beginDate ?? this.startDate,
    );
  }
}

// https://www.youtube.com/watch?v=SnlHbMIWJak

extension StatementDetails on Statement {
  DateTime get endDate => startDate.copyWith(month: startDate.month + 1);
  DateTime get dueDate => endDate.copyWith(month: endDate.month + 1, day: _creditAccount.paymentDueDay);

  /// Include CreditSpending of next statement, but happens between
  /// this statement `endDate` and `dueDate`.
  List<BaseCreditTransaction> get txnsFromBeginToDueDate {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= _creditAccount.transactionsList.length - 1; i++) {
      final transaction = _creditAccount.transactionsList[i];

      if (transaction.dateTime.isBefore(startDate)) {
        continue;
      }

      if (transaction.dateTime.isAfter(dueDate)) {
        break;
      }

      if (transaction.dateTime.isBefore(dueDate)) {
        list.add(transaction);
        continue;
      }
    }

    return list;
  }

  List<BaseCreditTransaction> txnsFromBeginTo(DateTime dateTime) {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= _creditAccount.transactionsList.length - 1; i++) {
      final transaction = _creditAccount.transactionsList[i];

      if (transaction.dateTime.isBefore(startDate)) {
        continue;
      }

      if (transaction.dateTime.isAfter(dueDate)) {
        break;
      }

      if (transaction.dateTime.isBefore(dateTime)) {
        list.add(transaction);
        continue;
      }
    }

    return list;
  }

  /// Returns CreditSpending between `startDate` and `endDate`
  /// Returns CreditPayment between `startDate` and `dueDate`
  List<BaseCreditTransaction> get transactions {
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

  double get spendingAmount {
    double spending = 0;
    for (BaseCreditTransaction transaction in transactions) {
      if (transaction is CreditSpending) {
        spending += transaction.amount;
      }
    }
    return spending;
  }

  double get paymentAmount {
    double payment = 0;
    for (BaseCreditTransaction transaction in transactions) {
      if (transaction is CreditPayment) {
        payment += transaction.amount;
      }
    }
    return payment;
  }

  double get averageDailyBalance {
    double sum = 0;
    DateTime prvDateTime = startDate;
    double balance = carryingOver;

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
    if (outstandingBalance <= 0) {
      return 0;
    }
    final interest =
        averageDailyBalance * (_creditAccount.apr / (365 * 100)) * startDate.getDaysDifferent(endDate);
    return interest;
  }

  double get outstandingBalance {
    double result = carryingOver + spendingAmount - paymentAmount;
    if (result < 0) {
      return 0;
    }
    return result;
  }

  /// Assign to `carryingOver` of the next Statement object
  double get carryToNextStatement => outstandingBalance + interest;
}
