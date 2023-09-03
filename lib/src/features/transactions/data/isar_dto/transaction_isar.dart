import 'dart:math';

import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/features/accounts/data/isar_dto/account_isar.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

import '../../../category/data/isar_dto/category_tag_isar.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// https://www.hsbc.com.vn/en-vn/credit-cards/understanding-your-credit-card-statement/
part 'transaction_isar.g.dart';

@Collection()
class TransactionIsar extends IsarCollectionObject {
  @enumerated
  late TransactionType transactionType;

  @Index()
  late DateTime dateTime;

  late double amount;

  String? note;

  /// Only specify this to `true` when **first creating new account**  and type is [TransactionType.income]**
  bool isInitialTransaction = false;

  /// **Only specify this if type is NOT [TransactionType.transfer]**
  @Index()
  final categoryLink = IsarLink<CategoryIsar>();

  /// **Only specify this if type is NOT [TransactionType.transfer]**
  @Index()
  final categoryTagLink = IsarLink<CategoryTagIsar>();

  @Index()
  final accountLink = IsarLink<AccountIsar>();

  /// **Only specify this if type is [TransactionType.transfer]**
  @Index()
  final toAccountLink = IsarLink<AccountIsar>();

  /// **Only specify this if type is [TransactionType.transfer]**
  TransferFeeIsar? transferFeeIsar;

  /// Payments of this credit spending
  ///
  /// **Only available if type is [TransactionType.creditSpending]**
  @Backlink(to: 'spendingTxnLink')
  final paymentTxnBacklinks = IsarLinks<TransactionIsar>();

  /// **Only specify this if type is [TransactionType.creditSpending]**
  InstallmentIsar? installmentIsar;

  /// **Only specify this if type is [TransactionType.creditPayment]**
  final spendingTxnLink = IsarLink<TransactionIsar>();
}

@Embedded()
class InstallmentIsar {
  /// The payment amount of each month
  late double amount;

  /// The interest rate of the installment payment. '0' if this transaction
  /// has 0% interest rate
  late double interestRate;

  /// `True` if the `interestRate` is based on the **remaining**
  /// unpaid amount of this installment. If so, the monthly interest rate will
  /// decrease as user made an installment payment.
  ///
  /// `False` if the `interestRate` is based on the **total** amount
  /// of this transaction every month in the payment period. If so, the monthly
  /// interest rate will not changed even user has paid for some months.
  bool rateOnRemaining = false;
}

@Embedded()
class TransferFeeIsar {
  double amount = 0;

  /// Specify this to `true` if the fee is charged on the destination account
  /// `false` if the fee is charge on the account has money transferred away
  bool onDestination = false;
}

extension CreditInfo on TransactionIsar {
  bool get isDone {
    return paidAmount <= 0;
  }

  double get paidAmount {
    double paidAmount = 0;
    final payments = paymentTxnBacklinks.toList();
    for (TransactionIsar txn in payments) {
      paidAmount += txn.amount;
    }
    return paidAmount;
  }

  double get pendingPayment {
    if (installmentIsar == null) {
      return amount - paidAmount;
    } else {
      return min(amount - paidAmount, installmentIsar!.amount);
    }
  }
}
