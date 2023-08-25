import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// https://www.hsbc.com.vn/en-vn/credit-cards/understanding-your-credit-card-statement/
part 'transaction_isar.g.dart';

@Collection()
class TransactionIsar {
  Id id = Isar.autoIncrement;

  /// Type of this transaction. This is used to distinguish between transactions.
  @enumerated
  late TransactionType transactionType;

  /// Date time when this transaction happens
  @Index()
  late DateTime dateTime;

  /// Amount of this transaction
  late double amount;

  /// Note of this transaction
  String? note;

  /// Only specify this to `true` when **first creating new account**  and type is [TransactionType.income]**
  bool isInitialTransaction = false;

  /// IsarLink to `CategoryIsar` of this transaction
  ///
  /// **Only specify this if type is NOT [TransactionType.transfer]**
  @Index()
  final categoryLink = IsarLink<CategoryIsar>();

  /// IsarLink to `CategoryTagIsar` of this transaction
  ///
  /// **Only specify this if type is NOT [TransactionType.transfer]**
  @Index()
  final categoryTagLink = IsarLink<CategoryTagIsar>();

  /// IsarLink to `AccountIsar` of this transaction
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
  TransferFeeDetails? transferFeeDetails;
}

@Embedded()
class TransferFeeDetails {
  double transferFee = 0;

  /// Specify this to `true` if the fee is charged on the destination account
  /// `false` if the fee is charge on the account has money transferred away
  bool isChargeOnDestinationAccount = false;
}
