import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
part 'category_tag_isar.g.dart';

@Collection()
class CategoryTagIsar extends IsarCollectionObject {
  final categoryLink = IsarLink<CategoryIsar>();

  /// name can be `null` by user remove action
  late String name;

  int? order;
}
