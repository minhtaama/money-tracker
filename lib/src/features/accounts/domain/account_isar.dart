import 'package:isar/isar.dart';
import '../../../utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
part 'account_isar.g.dart';

@Collection()
class AccountIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late AccountType type;

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;

  late double initialBalance;
}
