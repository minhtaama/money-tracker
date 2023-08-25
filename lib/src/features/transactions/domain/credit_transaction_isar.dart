import 'dart:math';

import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// https://www.hsbc.com.vn/en-vn/credit-cards/understanding-your-credit-card-statement/
part 'credit_transaction_isar.g.dart';

@Collection()
class CreditSpendingIsar {
  Id id = Isar.autoIncrement;

  /// Date time when this transaction happens
  @Index()
  late DateTime dateTime;

  /// Amount of this transaction
  late double amount;

  /// Note of this transaction
  String? note;

  /// IsarLink to `CategoryIsar` of this transaction
  @Index()
  final categoryLink = IsarLink<CategoryIsar>();

  /// IsarLink to `CategoryTagIsar` of this transaction
  @Index()
  final categoryTagLink = IsarLink<CategoryTagIsar>();

  /// IsarLink to `AccountIsar` of this transaction
  @Index()
  final creditAccountLink = IsarLink<AccountIsar>();

  @Backlink(to: 'spendingTxnLink')
  final paymentTxnBacklinks = IsarLinks<CreditPaymentIsar>();

  InstallmentDetails? installmentDetails;

  @Ignore()
  bool get isDone {
    return paidAmount <= 0;
  }

  @Ignore()
  double get paidAmount {
    double paidAmount = 0;
    final payments = paymentTxnBacklinks.toList();
    for (CreditPaymentIsar txn in payments) {
      paidAmount += txn.amount;
    }
    return paidAmount;
  }

  @Ignore()
  double get pendingPayment {
    if (installmentDetails == null) {
      return amount - paidAmount;
    } else {
      return min(amount - paidAmount, installmentDetails!.paymentAmountPerMonth);
    }
  }
}

@Collection()
class CreditPaymentIsar {
  Id id = Isar.autoIncrement;

  late DateTime dateTime;

  late double amount;

  final accountLink = IsarLink<AccountIsar>();

  final spendingTxnLink = IsarLink<CreditSpendingIsar>();
}

@Embedded()
class InstallmentDetails {
  /// Indicate months to pay
  late int paymentPeriod;

  /// The payment amount of each month
  late double paymentAmountPerMonth;

  /// The interest rate of the installment payment. '0' if this transaction
  /// has 0% interest rate
  late double monthlyInstallmentInterestRate;

  /// `True` if the `monthlyInstallmentInterestRate` is based on the **remaining**
  /// unpaid amount of this installment. If so, the monthly interest rate will
  /// decrease as user made an installment payment.
  ///
  /// `False` if the `monthlyInstallmentInterestRate` is based on the **total** amount
  /// of this transaction every month in the payment period. If so, the monthly
  /// interest rate will not changed even user has paid for some months.
  bool rateBasedOnRemainingInstallmentUnpaid = false;
}
