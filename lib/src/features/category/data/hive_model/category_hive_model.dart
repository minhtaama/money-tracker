import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:uuid/uuid.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: 1)
class CategoryHiveModel {
  CategoryHiveModel(
      {required this.type,
      required this.id,
      required this.icon,
      required this.name,
      required this.color});

  @HiveField(0)
  final CategoryType type;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String icon;
  @HiveField(3)
  final String name;
  @HiveField(4)
  final int color;

  factory CategoryHiveModel.createExpenseCategory(
      {required String icon, required String name, required Color color}) {
    final id = const Uuid().v1();
    return CategoryHiveModel(
      type: CategoryType.expense,
      id: id,
      icon: icon,
      name: name,
      color: color.value,
    );
  }

  factory CategoryHiveModel.createIncomeCategory(
      {required String icon, required String name, required Color color}) {
    final id = const Uuid().v1();
    return CategoryHiveModel(
      type: CategoryType.income,
      id: id,
      icon: icon,
      name: name,
      color: color.value,
    );
  }
}
