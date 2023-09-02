import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/isar_domain.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_tag_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';

@immutable
class CategoryTag extends IsarDomain {
  final String name;
  final Category? category;

  static CategoryTag? fromIsar(CategoryTagIsar? categoryTagIsar) {
    if (categoryTagIsar == null) {
      return null;
    }

    return CategoryTag._(
      categoryTagIsar.id,
      categoryTagIsar.name,
      Category.fromIsar(categoryTagIsar.categoryLink.value),
    );
  }

  const CategoryTag._(super.id, this.name, this.category);
}
