import 'package:money_tracker_app/persistent/isar_domain.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';

class CategoryTag extends IsarDomain {
  final String name;
  final Category category;

  CategoryTag(super.id, this.name, this.category);
}
