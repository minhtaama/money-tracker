import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_domain.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';
import 'category_tag.dart';

@immutable
class Category extends IsarDomain {
  final CategoryType type;

  final String name;
  final Color color;
  final Color backgroundColor;
  final String iconPath;

  final List<CategoryTag?> tags;

  static Category? fromIsar(CategoryIsar? categoryIsar) {
    if (categoryIsar == null) {
      return null;
    }

    final tags = categoryIsar.tags.map((tag) => CategoryTag.fromIsar(tag)).toList();

    return Category._(
      categoryIsar.id,
      type: categoryIsar.type,
      name: categoryIsar.name,
      color: AppColors.allColorsUserCanPick[categoryIsar.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[categoryIsar.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(categoryIsar.iconCategory, categoryIsar.iconIndex),
      tags: tags,
    );
  }

  const Category._(
    super.id, {
    required this.type,
    required this.name,
    required this.color,
    required this.backgroundColor,
    required this.iconPath,
    required this.tags,
  });
}
