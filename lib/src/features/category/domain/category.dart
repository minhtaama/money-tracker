import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

@immutable
class Category extends IsarModelWithIcon<CategoryIsar> {
  final CategoryType type;

  static Category? fromIsar(CategoryIsar? categoryIsar) {
    if (categoryIsar == null) {
      return null;
    }

    return Category._(
      categoryIsar,
      type: categoryIsar.type,
      name: categoryIsar.name,
      color: AppColors.allColorsUserCanPick[categoryIsar.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[categoryIsar.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(categoryIsar.iconCategory, categoryIsar.iconIndex),
    );
  }

  const Category._(
    super._isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.type,
  });
}
