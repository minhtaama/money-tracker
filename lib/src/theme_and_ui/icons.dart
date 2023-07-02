import 'package:flutter/services.dart';
import 'dart:convert';

class AppIcons {
  static Map<String, dynamic> _json = {};

  /// This Map contain keys type `String` as category and
  /// values type `List<String>` as the name of each svg file
  /// in `assets/svg` folder.
  ///
  /// Remember everytime adding a new folder/category, add a
  /// asset path to that folder in pubspec.yaml.
  static Map<String, List<String>> get iconsWithCategories => <String, List<String>>{
        'Money': _getFileNameListInFolderPath(_json, 'assets/svg/money/'),
        'Business': _getFileNameListInFolderPath(_json, 'assets/svg/business/'),
      };

  static String fromCategoryAndIndex(String iconCategory, int iconIndex) {
    return iconsWithCategories[iconCategory]?[iconIndex] ?? _defaultIcon;
  }

  static String get home => 'assets/svg/app/home.svg';
  static String get summary => 'assets/svg/app/folder-open.svg';
  static String get income => 'assets/svg/app/money-receive.svg';
  static String get expense => 'assets/svg/app/money-send.svg';
  static String get transfer => 'assets/svg/app/money-change.svg';
  static String get eye => 'assets/svg/app/eye.svg';
  static String get eyeSlash => 'assets/svg/app/eye-slash.svg';
  static String get arrowLeft => 'assets/svg/app/arrow-left-1.svg';
  static String get arrowRight => 'assets/svg/app/arrow-right-1.svg';
  static String get filter => 'assets/svg/app/filter.svg';
  static String get filterTick => 'assets/svg/app/filter-tick.svg';
  static String get settings => 'assets/svg/app/setting-2.svg';
  static String get back => 'assets/svg/app/arrow-left-1.svg';
  static String get add => 'assets/svg/app/add.svg';
  static String get edit => 'assets/svg/app/edit-2.svg';
  static String get delete => 'assets/svg/app/trash.svg';
  static String get done => 'assets/svg/app/tick-circle.svg';
  static String get accounts => 'assets/svg/app/cards.svg';
  static String get categories => 'assets/svg/app/book-square.svg';
  static String get budgets => 'assets/svg/app/coin.svg';
  static String get savings => 'assets/svg/app/bank.svg';
  static String get reports => 'assets/svg/app/chart-square.svg';

  static String get _defaultIcon => 'assets/svg/app/box-1.svg';

  /// Call this function in `main()` method, before `runApp()`
  static Future<void> init() async {
    final assets = await rootBundle.loadString('AssetManifest.json');
    _json = jsonDecode(assets);
  }

  /// This function is used to get all the file name in folder path.
  /// __The path start from root path project__.
  /// For example, to take all files name in path "assets\svg\default" folder,
  /// you must assign the path is `assets/svg/default/`.
  static List<String> _getFileNameListInFolderPath(Map<String, dynamic> json, String path,
      {bool isOnlyFileName = false}) {
    List<String> list = json.keys.where((element) => element.startsWith(path)).toList();
    if (isOnlyFileName) {
      return list.map((e) => e.substring(path.length)).toList();
    } else {
      return list;
    }
  }
}
