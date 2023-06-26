import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:uuid/uuid.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: 1)
class CategoryHiveModel {
  CategoryHiveModel({
    required this.type,
    required this.id,
    required this.iconCategory,
    required this.iconIndex,
    required this.name,
    required this.colorIndex,
  });

  @HiveField(0)
  final CategoryType type;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String iconCategory;
  @HiveField(3)
  final String name;
  @HiveField(4)
  final int colorIndex;
  @HiveField(5)
  final int iconIndex;

  factory CategoryHiveModel.create(
      {required CategoryType type,
      required String iconCategory,
      required int iconIndex,
      required String name,
      required int colorIndex}) {
    final id = const Uuid().v1();
    return CategoryHiveModel(
      type: type,
      id: id,
      iconCategory: iconCategory,
      iconIndex: iconIndex,
      name: name,
      colorIndex: colorIndex,
    );
  }
}
