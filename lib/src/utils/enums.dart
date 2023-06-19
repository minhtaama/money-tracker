import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Define types of a transaction
@HiveType(typeId: 50)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

/// Define types of a category
@HiveType(typeId: 51)
enum CategoryType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 52)
enum ThemeType {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}
