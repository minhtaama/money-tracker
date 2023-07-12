import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
part 'transaction_isar.g.dart';

@Collection()
class TransactionIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late TransactionType transactionType;

  @Index()
  late DateTime dateTime;

  late double amount;
  String? note;

  final category = IsarLink<CategoryIsar>();
  final account = IsarLink<AccountIsar>();

  /// Only specify this if transaction type is __Transfer__
  final toAccount = IsarLink<AccountIsar>();
}
