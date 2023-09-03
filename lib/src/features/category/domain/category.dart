import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

@immutable
class Category extends IsarModel<CategoryIsar> {
  final CategoryType type;

  final String name;
  final Color color;
  final Color backgroundColor;
  final String iconPath;

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
    required this.type,
    required this.name,
    required this.color,
    required this.backgroundColor,
    required this.iconPath,
  });
}
