import 'package:hive/hive.dart';

part 'account_hive_model.g.dart';

@HiveType(typeId: 0)
class AccountHiveModel {
  AccountHiveModel({
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
