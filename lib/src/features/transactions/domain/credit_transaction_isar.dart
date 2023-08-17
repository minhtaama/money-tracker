import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
part 'credit_transaction_isar.g.dart';

@Collection()
class CreditTransactionIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime dateTime;

  late double amount;

  String? note;

  @Index()
  final category = IsarLink<CategoryIsar>();

  @Index()
  final tag = IsarLink<CategoryTagIsar>();

  @Index()
  final account = IsarLink<AccountIsar>();

  final payments = List<CreditPaymentIsar>.empty(growable: true);
}

@Embedded()
class CreditPaymentIsar {
  late DateTime dateTime;

  late double amount;
}

// TODO: ADD CREDIT TRANSACTION
