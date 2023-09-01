import 'dart:ui';

import 'package:money_tracker_app/persistent/isar_domain.dart';

import '../../../common_widgets/svg_icon.dart';
import '../../../utils/enums.dart';
import 'category_tag.dart';

class Category extends IsarDomain {
  late CategoryType type;

  final String name;
  final Color color;
  final SvgIcon icon;

  final List<CategoryTag> tags;

  Category(super.id, {required this.name, required this.color, required this.icon, required this.tags});
}
