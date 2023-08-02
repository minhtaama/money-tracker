import 'package:isar/isar.dart';
import '../../../utils/enums.dart';

//// flutter pub run build_runner build --delete-conflicting-outputs
part 'category_isar.g.dart';

@Collection()
class CategoryIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late CategoryType type;

  final List<String> tags = [];

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;
}
