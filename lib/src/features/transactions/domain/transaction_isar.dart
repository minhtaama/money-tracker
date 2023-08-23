import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
part 'transaction_isar.g.dart';

@Collection()
class TransactionIsar {
  Id id = Isar.autoIncrement;

  /// Type of this transaction. This is used to distinguish between transactions.
  ///
  /// **Must specify**
  @enumerated
  late TransactionType transactionType;

  /// Date time when this transaction happens
  ///
  /// **For all transaction type**
  @Index()
  late DateTime dateTime;

  /// Amount of this transaction
  ///
  /// **For all transaction type**
  late double amount;

  /// Note of this transaction
  ///
  /// **For all transaction type**
  String? note;

  /// IsarLink to `CategoryIsar` of this transaction
  ///
  /// **Only specify this if type is NOT [TransactionType.transfer] and [TransactionType.creditPayment]**
  @Index()
  final categoryLink = IsarLink<CategoryIsar>();

  /// IsarLink to `CategoryTagIsar` of this transaction
  ///
  /// **Only specify this if type is NOT [TransactionType.transfer] and [TransactionType.creditPayment]**
  @Index()
  final categoryTagLink = IsarLink<CategoryTagIsar>();

  /// IsarLink to `AccountIsar` of this transaction
  ///
  /// **For all transaction type**
  @Index()
  final accountLink = IsarLink<AccountIsar>();

  /// IsarLink to `AccountIsar` of this transaction as the account has money transferred to.
  ///
  /// **Only specify this if type is [TransactionType.transfer]**
  @Index()
  final toAccountLink = IsarLink<AccountIsar>();

  /// Fee of the transfer transaction.
  ///
  /// **Only specify this if type is [TransactionType.transfer]**
  double transferFee = 0;

  /// Only specify this to `true` when **first creating new account**  and type is [TransactionType.income]**
  bool isInitialTransaction = false;

  /// **Only specify if type is [TransactionType.creditSpending]**
  CreditSpendingTxnDetails? creditSpendingTxnDetails;

  // /// **Only specify if type is [TransactionType.creditPayment]**
  // CreditPaymentTxnDetails? creditPaymentTxnDetails;
}

@Embedded()
class CreditSpendingTxnDetails {
  /// Indicate months to pay if this transaction has installment payment.
  /// `1` means no installment (Pay full in next month)
  late int paymentPeriod;

  /// The payment amount of each month if this transaction has installment payment
  /// This value is equal `amount/paymentPeriod` (and equal `amount` if `paymentPeriod == 1`)
  late double paymentAmountPerMonth;

  /// The interest rate of the installment payment. '0' if this transaction
  /// does not have installment payment or has 0% interest rate
  late double monthlyInstallmentInterestRate;

  /// `True` if the `monthlyInstallmentInterestRate` is based on the **remaining**
  /// unpaid amount of this installment. If so, the monthly interest rate will
  /// decrease as user made an installment payment.
  ///
  /// `False` if the `monthlyInstallmentInterestRate` is based on the **total** amount
  /// of this transaction every month in the payment period. If so, the monthly
  /// interest rate will not changed even user has paid for some months.
  bool rateBasedOnRemainingInstallmentUnpaid = false;

  /// Any fee that apply to this credit spending transaction. `0` if this transaction
  /// does not has any fee. The fee will be counted in total amount that user has
  /// to pay next month.
  late double fee;
}

// @Embedded()
// class CreditPaymentTxnDetails {}
