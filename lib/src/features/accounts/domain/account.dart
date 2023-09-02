import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import '../../../../persistent/isar_domain.dart';
import '../../../utils/enums.dart';
import '../data/isar_dto/account_isar.dart';

@immutable
class Account extends IsarDomain {
  final AccountType type;

  final String name;
  final Color color;
  final Color backgroundColor;
  final String iconPath;

  final CreditDetails? creditDetails;

  final AccountIsar _accountIsar;

  double get currentBalance => _accountIsar.currentBalance;

  double get totalPendingCreditPayment => _accountIsar.totalPendingCreditPayment;

  static Account? fromIsar(AccountIsar? accountIsar) {
    if (accountIsar == null) {
      return null;
    }

    return Account._(
      accountIsar.id,
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
    super.id,
    this._accountIsar, {
    required this.type,
    required this.name,
    required this.color,
    required this.backgroundColor,
    required this.iconPath,
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
