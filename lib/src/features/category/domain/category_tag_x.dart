import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_tag_isar.dart';

@immutable
class CategoryTag extends IsarModel<CategoryTagIsar> {
  final String name;

  static CategoryTag? fromIsar(CategoryTagIsar? categoryTagIsar) {
    if (categoryTagIsar == null) {
      return null;
    }

    return CategoryTag._(
      categoryTagIsar,
      categoryTagIsar.name,
    );
  }

  const CategoryTag._(super._isarObject, this.name);
}
