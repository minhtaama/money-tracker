part of 'transaction_base.dart';

@immutable
class CreditSpending extends BaseTransaction implements BaseTransactionWithCategory {
  @override
  final CreditAccount? account;

  @override
  final Category? category;

  @override
  final CategoryTag? categoryTag;

  final double? installmentAmount;

  const CreditSpending._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    this.category,
    this.categoryTag, {
    required this.account,
    required this.installmentAmount,
  });
}

final class PaymentPeriod {
  const PaymentPeriod({required this.statementDay, required this.paymentDueDay, required this.payments});

  final DateTime statementDay;

  final DateTime paymentDueDay;

  final List<CreditPayment> payments;
}

extension SpendingDetails on CreditSpending {
  List<CreditPayment> get paymentTransactions {
    final payments = <CreditPayment>[];
    for (TransactionDb txn in databaseObject.paymentTransactions.toList()) {
      payments.add(BaseTransaction.fromIsar(txn) as CreditPayment);
    }
    return payments;
  }

  DateTime get firstDueDate {
    if (account == null) {
      throw ErrorDescription('No credit account is associated with this transaction');
    }

    if (dateTime.day >= account!.statementDay) {
      return dateTime.copyWith(day: account!.paymentDueDay, month: dateTime.month + 2).onlyYearMonthDay;
    }

    return dateTime.copyWith(day: account!.paymentDueDay, month: dateTime.month + 1).onlyYearMonthDay;
  }

  double interestAt(DateTime date) {
    if (account == null) {
      throw ErrorDescription('No credit account is associated with this transaction');
    }

    if (date.onlyYearMonthDay.isBefore(firstDueDate) || date.onlyYearMonthDay.isAtSameMomentAs(firstDueDate)) {
      return 0;
    }

    final daysDifference = dateTime.getDaysDifferent(date);
    final aprInDay = account!.apr / (365 * 100);
    double interest = 0;
    for (int i = 1; i <= daysDifference; i++) {
      interest += (remainingAmount + interest) * aprInDay;
    }

    return interest;
  }

  // List<DateTime> statementDaysUntil({required DateTime toDate}) {
  //   if (account == null) {
  //     throw ErrorDescription('Credit Account must be specified');
  //   }
  //
  //   DateTime startDate = dateTime;
  //   List<DateTime> list = [];
  //   for (int month = startDate.month;
  //       DateTime(startDate.year, month, account!.statementDay - 1).isBefore(toDate.onlyYearMonthDay);
  //       month++) {
  //     list.add(DateTime(startDate.year, month, account!.statementDay - 1));
  //   }
  //   return list;
  // }

  bool get isDone {
    return paidAmount >= amount;
  }

  bool get hasInstallment {
    return installmentAmount != null;
  }

  double get paidAmount {
    double paidAmount = 0;
    for (CreditPayment txn in paymentTransactions) {
      paidAmount += txn.amount;
    }
    return paidAmount;
  }

  double get remainingAmount => amount - paidAmount;

  double get minimumPaymentAmount {
    if (hasInstallment) {
      return paymentAmount;
    }
    return min(amount - paidAmount, amount * 5 / 100);
  }

  double get paymentAmount {
    if (hasInstallment) {
      return min(amount - paidAmount, installmentAmount!);
    }
    return amount - paidAmount;
  }
}
