import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense_category.g.dart';

@HiveType(typeId: 1)
class ExpenseCategory {
  ExpenseCategory({required this.id, required this.icon, required this.name, required this.color});

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String icon;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final int color;

  factory ExpenseCategory.fromColorWithUuid(
      {required String icon, required String name, required Color color}) {
    final id = const Uuid().v1();
    return ExpenseCategory(id: id, icon: icon, name: name, color: color.value);
  }

  @override
  String toString() {
    return 'IncomeCategory{id: $id, icon: $icon, name: $name, color: $color}';
  }
}
