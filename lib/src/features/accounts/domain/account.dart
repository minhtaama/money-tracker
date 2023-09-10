import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../../persistent/isar_model.dart';
import '../../../utils/enums.dart';
import '../data/isar_dto/account_isar.dart';

@immutable
class Account extends IsarModelWithIcon<AccountIsar> {
  final AccountType type;

  final CreditDetails? creditDetails;

  double get currentBalance => isarObject.currentBalance;

  double get totalPendingCreditPayment => isarObject.totalPendingCreditPayment;

  bool get isTodayInPaymentPeriod {
    if (creditDetails == null) {
      throw ErrorDescription('Account type is not Credit and creditDetails is null');
    }

    final statementDay = creditDetails!.statementDay;
    final paymentDueDay = creditDetails!.paymentDueDay;

    bool todayIsAfterStatementDayAndBeforeNextMonth =
        DateTime.now().isAfter(DateTime(DateTime.now().year, DateTime.now().month, statementDay));
    bool todayIsBeforePaymentDueDayAndAfterPreviousMonth =
        DateTime.now().isBefore(DateTime(DateTime.now().year, DateTime.now().month, paymentDueDay));

    if (todayIsBeforePaymentDueDayAndAfterPreviousMonth || todayIsAfterStatementDayAndBeforeNextMonth) {
      return true;
    } else {
      return false;
    }
  }

  String get nextPaymentPeriod {
    if (creditDetails == null) {
      throw ErrorDescription('Account type is not Credit and creditDetails is null');
    }

    final statementDay = creditDetails!.statementDay;
    final paymentDueDay = creditDetails!.paymentDueDay;

    bool todayIsAfterStatementDayAndBeforeNextMonth =
        DateTime.now().isAfter(DateTime(DateTime.now().year, DateTime.now().month, statementDay));
    bool todayIsBeforePaymentDueDayAndAfterPreviousMonth =
        DateTime.now().isBefore(DateTime(DateTime.now().year, DateTime.now().month, paymentDueDay));

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

    return Account._(
      accountIsar,
      type: accountIsar.type,
      name: accountIsar.name,
      color: AppColors.allColorsUserCanPick[accountIsar.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[accountIsar.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(accountIsar.iconCategory, accountIsar.iconIndex),
      creditDetails: CreditDetails.fromIsar(accountIsar),
    );
  }

  const Account._(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.type,
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

  static CreditDetails? fromIsar(AccountIsar accountIsar) {
    if (accountIsar.creditDetailsIsar == null) {
      return null;
    } else {
      return CreditDetails._(
          creditBalance: accountIsar.creditDetailsIsar!.creditBalance,
          interestRate: accountIsar.creditDetailsIsar!.interestRate,
          statementDay: accountIsar.creditDetailsIsar!.statementDay,
          paymentDueDay: accountIsar.creditDetailsIsar!.paymentDueDay);
    }
  }

  const CreditDetails._({
    required this.creditBalance,
    required this.interestRate,
    required this.statementDay,
    required this.paymentDueDay,
  });
}
