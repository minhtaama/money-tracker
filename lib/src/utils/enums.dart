import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Define types of a transaction
enum TransactionType {
  income,
  expense,
  transfer,
}

/// Define types of a category
@HiveType(typeId: 0)
enum CategoryType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}
