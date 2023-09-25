import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';

abstract class RegularTransactionIsar extends IsarCollectionObject {
  late double amount;

  late String? note;
}

@Collection()
class ExpenseTransactionIsar extends RegularTransactionIsar implements IsarCollectionDateTime {
  @override
  late DateTime dateTime;
}
