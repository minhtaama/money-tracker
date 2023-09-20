import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../../../../persistent/isar_model.dart';
import '../../transactions/domain/transaction.dart';
import '../data/isar_dto/account_isar.dart';

@immutable
class Account extends IsarModelWithIcon<AccountIsar> {
  double get currentBalance => isarObject.currentBalance;

  static Account? fromIsar(AccountIsar? accountIsar) {
    if (accountIsar == null) {
      return null;
    }

    return switch (accountIsar.type) {
      AccountType.regular => Account(
          accountIsar,
          name: accountIsar.name,
          color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
        ),
      AccountType.credit => CreditAccount.fromIsar(accountIsar),
    };
  }

  const Account(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
  });
}

@immutable
class CreditAccount extends Account {
  final double creditBalance;

  /// As in percent.
  final double interestRate;

  final int statementDay;

  final int paymentDueDay;

  static CreditAccount? fromIsar(AccountIsar? accountIsar) {
    if (accountIsar == null) {
      return null;
    }

    return CreditAccount._(
      accountIsar,
      name: accountIsar.name,
      color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
      creditBalance: accountIsar.creditDetailsIsar!.creditBalance,
      interestRate: accountIsar.creditDetailsIsar!.interestRate,
      statementDay: accountIsar.creditDetailsIsar!.statementDay,
      paymentDueDay: accountIsar.creditDetailsIsar!.paymentDueDay,
    );
  }

  const CreditAccount._(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.creditBalance,
    required this.interestRate,
    required this.statementDay,
    required this.paymentDueDay,
  });
}

extension CreditDetails on CreditAccount {
  List<CreditSpending> get spendingTxns => List.from(
      isarObject.txnOfThisAccountBacklinks.map<CreditSpending>((e) => Transaction.fromIsar(e) as CreditSpending));

  List<CreditSpending> get allUnpaidSpendingTxns => spendingTxns.where((txn) => !txn.isDone).toList();

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
      pendingPayment += txn.pendingPayment;
    }
    return pendingPayment;
  }

  DateTime get earliestPayableDate {
    DateTime time = DateTime.now();

    // Get earliest spending transaction un-done
    for (CreditSpending txn in spendingTxns) {
      if (!txn.isDone && txn.dateTime.isBefore(time)) {
        time = txn.dateTime;
      }
    }

    // Earliest day that payment can happens
    if (time.day <= paymentDueDay) {
      time = time.copyWith(day: paymentDueDay + 1);
    }
    if (time.day >= statementDay) {
      time = time.copyWith(day: paymentDueDay + 1, month: time.month + 1);
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
