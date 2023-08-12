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
        'Activities': _getFileNameListInFolderPath(_json, 'assets/svg/activity/'),
        'Food': _getFileNameListInFolderPath(_json, 'assets/svg/food/'),
        'Games': _getFileNameListInFolderPath(_json, 'assets/svg/game/'),
        'Households': _getFileNameListInFolderPath(_json, 'assets/svg/household/'),
        'Health': _getFileNameListInFolderPath(_json, 'assets/svg/health/'),
        'Buildings': _getFileNameListInFolderPath(_json, 'assets/svg/building/'),
        'Emoji': _getFileNameListInFolderPath(_json, 'assets/svg/emoji/'),
      };

  static String fromCategoryAndIndex(String iconCategory, int iconIndex) {
    return iconsWithCategories[iconCategory]?[iconIndex] ?? defaultIcon;
  }

  static String get home => 'assets/svg/app/home.svg';
  static String get summary => 'assets/svg/app/folder.svg';
  static String get income => 'assets/svg/app/income.svg';
  static String get expense => 'assets/svg/app/expense.svg';
  static String get transfer => 'assets/svg/app/swap.svg';
  static String get eye => 'assets/svg/app/show.svg';
  static String get eyeSlash => 'assets/svg/app/hide.svg';
  static String get arrowLeft => 'assets/svg/app/arrow-left.svg';
  static String get arrowRight => 'assets/svg/app/arrow-right.svg';
  static String get filter => 'assets/svg/app/no-filter.svg';
  static String get filterTick => 'assets/svg/app/filter.svg';
  static String get settings => 'assets/svg/app/setting.svg';
  static String get back => 'assets/svg/app/arrow-left.svg';
  static String get add => 'assets/svg/app/plus.svg';
  static String get edit => 'assets/svg/app/edit.svg';
  static String get delete => 'assets/svg/app/delete.svg';
  static String get done => 'assets/svg/app/check.svg';
  static String get accounts => 'assets/svg/app/accounts.svg';
  static String get categories => 'assets/svg/app/categories.svg';
  static String get budgets => 'assets/svg/app/budgets.svg';
  static String get savings => 'assets/svg/app/saving.svg';
  static String get reports => 'assets/svg/app/report.svg';
  static String get coins => 'assets/svg/app/coins.svg';
  static String get backspace => 'assets/svg/app/backspace.svg';
  static String get today => 'assets/svg/app/today.svg';
  static String get download => 'assets/svg/app/download.svg';
  static String get upload => 'assets/svg/app/upload.svg';
  static String get minus => 'assets/svg/app/minus.svg';

  static String get defaultIcon => 'assets/svg/app/default.svg';

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
