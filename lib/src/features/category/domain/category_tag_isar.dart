import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
part 'category_tag_isar.g.dart';

@Collection()
class CategoryTagIsar {
  Id id = Isar.autoIncrement;

  final category = IsarLink<CategoryIsar>();

  String? name;
}
