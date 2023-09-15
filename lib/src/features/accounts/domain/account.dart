import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../../persistent/isar_model.dart';
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
      AccountType.credit => CreditAccount._(
          accountIsar,
          name: accountIsar.name,
          color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
          backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
          iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
          creditDetails: CreditDetails._fromIsar(accountIsar),
        ),
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
  final CreditDetails creditDetails;

  double get totalPendingCreditPayment => isarObject.totalPendingCreditPayment;

  int get statementDay => creditDetails.statementDay;
  int get paymentDueDay => creditDetails.paymentDueDay;

  bool get todayIsAfterStatementDayAndBeforeNextMonth =>
      DateTime.now().isAfter(DateTime(DateTime.now().year, DateTime.now().month, statementDay));

  bool get todayIsBeforePaymentDueDayAndAfterPreviousMonth =>
      DateTime.now().isBefore(DateTime(DateTime.now().year, DateTime.now().month, paymentDueDay));

  bool get isTodayInPaymentPeriod {
    if (todayIsBeforePaymentDueDayAndAfterPreviousMonth || todayIsAfterStatementDayAndBeforeNextMonth) {
      return true;
    } else {
      return false;
    }
  }

  String get nextPaymentPeriod {
    DateTime statementDate;
    DateTime paymentDueDate;

    if (todayIsAfterStatementDayAndBeforeNextMonth) {
      statementDate = DateTime(DateTime.now().year, DateTime.now().month, statementDay);
      paymentDueDate = DateTime(DateTime.now().year, DateTime.now().month + 1, paymentDueDay);
    }
    if (todayIsBeforePaymentDueDayAndAfterPreviousMonth) {
      statementDate = DateTime(DateTime.now().year, DateTime.now().month - 1, statementDay);
      paymentDueDate = DateTime(DateTime.now().year, DateTime.now().month, paymentDueDay);
    } else {
      statementDate = DateTime(DateTime.now().year, DateTime.now().month, statementDay);
      paymentDueDate = DateTime(DateTime.now().year, DateTime.now().month + 1, paymentDueDay);
    }

    return '${statementDate.getFormattedDate()} - ${paymentDueDate.getFormattedDate()}';
  }

  static Account? fromIsar(AccountIsar? accountIsar) {
    if (accountIsar == null) {
      return null;
    }

    return CreditAccount._(
      accountIsar,
      name: accountIsar.name,
      color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
      creditDetails: CreditDetails._fromIsar(accountIsar),
    );
  }

  const CreditAccount._(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.creditDetails,
  });
}

@immutable
class CreditDetails {
  final double creditBalance;

  /// As in percent.
  final double interestRate;

  final int statementDay;

  final int paymentDueDay;

  factory CreditDetails._fromIsar(AccountIsar accountIsar) {
    return CreditDetails._(
        creditBalance: accountIsar.creditDetailsIsar!.creditBalance,
        interestRate: accountIsar.creditDetailsIsar!.interestRate,
        statementDay: accountIsar.creditDetailsIsar!.statementDay,
        paymentDueDay: accountIsar.creditDetailsIsar!.paymentDueDay);
  }

  const CreditDetails._({
    required this.creditBalance,
    required this.interestRate,
    required this.statementDay,
    required this.paymentDueDay,
  });
}
