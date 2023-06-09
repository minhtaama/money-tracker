import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'income_category.g.dart';

@HiveType(typeId: 0)
class IncomeCategory {
  IncomeCategory({required this.id, required this.icon, required this.name, required this.color});

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String icon;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String color;

  factory IncomeCategory.autoID({required String icon, required String name, required String color}) {
    final id = const Uuid().v1();
    return IncomeCategory(id: id, icon: icon, name: name, color: color);
  }

  @override
  String toString() {
    return 'IncomeCategory{id: $id, icon: $icon, name: $name, color: $color}';
  }
}
