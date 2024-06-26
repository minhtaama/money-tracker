import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:realm/realm.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

@immutable
class Category extends BaseModelWithIcon<CategoryDb> {
  final CategoryType type;
  final bool isNotExistInDatabase;

  static Category initialIncome(BuildContext context) {
    return Category._(
      CategoryDb(ObjectId(), CategoryType.income.databaseValue, '', 0, '', 0),
      type: CategoryType.income,
      name: 'Initial Income',
      iconColor: context.appTheme.onPositive,
      backgroundColor: context.appTheme.positive,
      iconPath: AppIcons.add,
    );
  }

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
    this.isNotExistInDatabase = false,
  });
}

class DeletedCategory extends Category {
  DeletedCategory()
      : super._(
          CategoryDb(ObjectId(), 0, '', 0, '', 0),
          type: CategoryType.income,
          name: 'Deleted category'.hardcoded,
          iconColor: AppColors.black,
          backgroundColor: Colors.grey[300]!,
          iconPath: AppIcons.delete,
          isNotExistInDatabase: true,
        );
}

class OthersCategory extends Category {
  OthersCategory()
      : super._(
          CategoryDb(ObjectId(), 0, '', 0, '', 0),
          type: CategoryType.income,
          name: 'Others'.hardcoded,
          iconColor: AppColors.black,
          backgroundColor: Colors.grey[300]!,
          iconPath: AppIcons.categories,
          isNotExistInDatabase: true,
        );
}
