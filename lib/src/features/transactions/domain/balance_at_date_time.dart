import '../../../../persistent/base_model.dart';
import '../../../../persistent/realm_dto.dart';

class BalanceAtDateTime extends BaseModel<BalanceAtDateTimeDb> {
  final DateTime date;
  final double amount;

  factory BalanceAtDateTime.fromDatabase(BalanceAtDateTimeDb db) {
    return BalanceAtDateTime._(db, date: db.date.toLocal(), amount: db.amount);
  }

  const BalanceAtDateTime._(super._databaseObject, {required this.date, required this.amount});
}
