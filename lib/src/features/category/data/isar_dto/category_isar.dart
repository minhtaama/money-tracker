import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import '../../../../utils/enums.dart';
import 'category_tag_isar.dart';

//// flutter pub run build_runner build --delete-conflicting-outputs
part 'category_isar.g.dart';

@Collection()
class CategoryIsar extends IsarCollectionObject {
  @enumerated
  late CategoryType type;

  @Backlink(to: 'categoryLink')
  final tags = IsarLinks<CategoryTagIsar>();

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;
}
