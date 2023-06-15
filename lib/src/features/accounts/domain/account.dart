import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Account {
  Account({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String icon;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String color;
}
