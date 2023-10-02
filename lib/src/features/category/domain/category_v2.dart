import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/model_from_realm.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_v2.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

@immutable
class CategoryV2 extends ModelFromRealmWithIcon<CategoryRealm> {
  final CategoryType type;
  final List<CategoryTagV2> tags;

  static CategoryV2? fromRealm(CategoryRealm? categoryRealm) {
    if (categoryRealm == null) {
      return null;
    }

    final CategoryType type = switch (categoryRealm.type) {
      0 => CategoryType.expense,
      _ => CategoryType.income,
    };

    final List<CategoryTagV2> tags = categoryRealm.tags.map((e) => CategoryTagV2.fromRealm(e)!).toList();

    return CategoryV2._(
      categoryRealm,
      type: type,
      tags: tags,
      name: categoryRealm.name,
      color: AppColors.allColorsUserCanPick[categoryRealm.colorIndex][1],
      backgroundColor: AppColors.allColorsUserCanPick[categoryRealm.colorIndex][0],
      iconPath: AppIcons.fromCategoryAndIndex(categoryRealm.iconCategory, categoryRealm.iconIndex),
    );
  }

  const CategoryV2._(
    super._realmObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.type,
    required this.tags,
  });
}
