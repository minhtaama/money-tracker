import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

@immutable
class Category extends BaseModelWithIcon<CategoryDb> {
  final CategoryType type;

  static Category? fromDatabase(CategoryDb? categoryRealm) {
    if (categoryRealm == null) {
      return null;
    }

    return Category._(
      categoryRealm,
      type: CategoryType.fromDatabaseValue(categoryRealm.type),
      name: categoryRealm.name,
      iconColor: AppColors.allColorsUserCanPick[categoryRealm.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[categoryRealm.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(categoryRealm.iconCategory, categoryRealm.iconIndex),
    );
  }

  const Category._(
    super._realmObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    required this.type,
  });
}
