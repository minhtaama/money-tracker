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

  /// Only specify this to `true` when **first creating new account**
  bool isInitialTransaction = false;

  /// Date time of this transaction happens
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

  /// The Backlink to payment transaction(s) of this spending transaction
  ///
  /// **Only available if type is [TransactionType.creditSpending]**
  @Backlink(to: 'asPaymentOfCreditTxnLink')
  final paymentTxnsBacklinks = IsarLinks<TransactionIsar>();

  /// Link to the credit spending transaction that this is act as a payment to
  /// that spending.
  ///
  /// **Only specify this if this transaction type is [TransactionType.creditPayment]**
  ///
  /// **And value adding must have type [TransactionType.creditSpending]**
  final asPaymentOfCreditTxnLink = IsarLink<TransactionIsar>();

  /// Indicate months to pay if this transaction has installment payment.
  /// `1` means no installment (Pay full in next month)
  ///
  /// **Only specify if type is [TransactionType.creditSpending]**
  int? paymentPeriod;

  /// The payment amount of each month if this transaction has installment payment
  /// This value is equal `amount/paymentPeriod`
  ///
  /// **Only specify if type is [TransactionType.creditSpending]**
  double? paymentAmount;
}
