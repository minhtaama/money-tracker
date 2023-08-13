import 'package:isar/isar.dart';
import '../../../utils/enums.dart';
import 'category_tag_isar.dart';

//// flutter pub run build_runner build --delete-conflicting-outputs
part 'category_isar.g.dart';

@Collection()
class CategoryIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late CategoryType type;

  /// __tags can be null as user delete a tag from list__
  List<String?> tags = List.empty(growable: true);

  // @Backlink(to: 'category')
  // final tags = IsarLinks<CategoryTagIsar>;
  //TODO: Change to IsarLinks

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;
}
