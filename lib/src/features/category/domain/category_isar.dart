import 'package:isar/isar.dart';
import '../../../utils/enums.dart';
part 'category_isar.g.dart';

@Collection()
class CategoryIsar {
  Id id = Isar.autoIncrement;
  @enumerated
  late CategoryType type;
  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;
  int? order;
}
