import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/model_from_realm.dart';
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

    final CategoryType type = switch (categoryRealm.type) {
      0 => CategoryType.expense,
      _ => CategoryType.income,
    };

    return Category._(
      categoryRealm,
      type: type,
      name: categoryRealm.name,
      color: AppColors.allColorsUserCanPick[categoryRealm.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[categoryRealm.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(categoryRealm.iconCategory, categoryRealm.iconIndex),
    );
  }

  const Category._(
    super._realmObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.type,
  });
}
