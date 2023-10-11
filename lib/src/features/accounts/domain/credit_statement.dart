part of 'account_base.dart';

@immutable
class Statement {
  const Statement(this._creditAccount, {required this.carryingOver, required this.beginDate});

  final CreditAccount _creditAccount;

  final double carryingOver;

  final DateTime beginDate;

  Statement copyWith({
    CreditAccount? creditAccount,
    double? carryingOver,
    DateTime? beginDate,
  }) {
    return Statement(
      creditAccount ?? _creditAccount,
      carryingOver: carryingOver ?? this.carryingOver,
      beginDate: beginDate ?? this.beginDate,
    );
  }
}

// https://www.youtube.com/watch?v=SnlHbMIWJak

extension StatementDetails on Statement {
  DateTime get endDate => beginDate.copyWith(month: beginDate.month + 1);
  DateTime get dueDate => endDate.copyWith(month: endDate.month + 1, day: _creditAccount.paymentDueDay);

  /// Because transactions list of account is sorted by dateTime
  /// so this list will be sorted by dateTime too.
  List<BaseCreditTransaction> get transactionsUntilDueDate {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= _creditAccount.transactionsList.length - 1; i++) {
      final transaction = _creditAccount.transactionsList[i];

      if (transaction.dateTime.isBefore(beginDate)) {
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

  List<BaseCreditTransaction> transactionsUntil(DateTime dateTime) {
    List<BaseCreditTransaction> list = <BaseCreditTransaction>[];
    for (BaseCreditTransaction transaction in transactionsUntilDueDate) {
      if (transaction.dateTime.compareTo(dateTime.toLocal()) < 0) {
        list.add(transaction);
      }
    }
    return list;
  }

  List<BaseCreditTransaction> get transactionsOfThisStatementOnly {
    final List<BaseCreditTransaction> list = List.empty(growable: true);

    for (int i = 0; i <= transactionsUntilDueDate.length - 1; i++) {
      final transaction = transactionsUntilDueDate[i];

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
    for (BaseCreditTransaction transaction in transactionsOfThisStatementOnly) {
      if (transaction is CreditSpending) {
        spending += transaction.amount;
      }
    }
    return spending;
  }

  double get paymentAmount {
    double payment = 0;
    for (BaseCreditTransaction transaction in transactionsOfThisStatementOnly) {
      if (transaction is CreditPayment) {
        payment += transaction.amount;
      }
    }
    return payment;
  }

  double get averageDailyBalance {
    double sum = 0;
    DateTime prvDateTime = beginDate;
    double balance = carryingOver;

    for (int i = 0; i <= transactionsUntilDueDate.length - 1; i++) {
      final transaction = transactionsUntilDueDate[i];

      sum += balance * prvDateTime.getDaysDifferent(transaction.dateTime);

      if (transaction is CreditSpending) {
        balance += transaction.amount;
      }
      if (transaction is CreditPayment) {
        balance -= transaction.amount;
      }

      prvDateTime = transaction.dateTime;
    }

    if (transactionsUntilDueDate.isNotEmpty) {
      sum += balance * transactionsUntilDueDate.last.dateTime.getDaysDifferent(endDate);
    } else {
      sum += balance * beginDate.getDaysDifferent(endDate);
    }

    return sum / beginDate.getDaysDifferent(endDate);
  }

  double get interest {
    if (outstandingBalance <= 0) {
      return 0;
    }
    final interest =
        averageDailyBalance * (_creditAccount.apr / (365 * 100)) * beginDate.getDaysDifferent(endDate);
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
