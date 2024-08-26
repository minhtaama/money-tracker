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
  static Map<String, List<String>> iconsWithCategories = <String, List<String>>{};

  static String fromCategoryAndIndex(String iconCategory, int iconIndex) {
    return iconsWithCategories[iconCategory]?[iconIndex] ?? defaultIcon;
  }

  static String get homeBulk => 'assets/svg/app/home.svg';
  static String get summaryBulk => 'assets/svg/app/folder.svg';
  static String get incomeLight => 'assets/svg/app/income.svg';
  static String get expenseLight => 'assets/svg/app/expense.svg';
  static String get transferLight => 'assets/svg/app/swap.svg';
  static String get eyeBulk => 'assets/svg/app/show.svg';
  static String get eyeSlashBulk => 'assets/svg/app/hide.svg';
  static String get arrowLeftLight => 'assets/svg/app/arrow-left.svg';
  static String get arrowRightLight => 'assets/svg/app/arrow-right.svg';
  static String get arrowBendDownLight => 'assets/svg/app/arrow-bend-down.svg';
  static String get filterBulk => 'assets/svg/app/no-filter.svg';
  static String get filterTickBulk => 'assets/svg/app/filter.svg';
  static String get settingsBulk => 'assets/svg/app/setting.svg';
  static String get backLight => 'assets/svg/app/arrow-left.svg';
  static String get addLight => 'assets/svg/app/plus.svg';
  static String get editLight => 'assets/svg/app/edit.svg';
  static String get deleteLight => 'assets/svg/app/delete.svg';
  static String get doneLight => 'assets/svg/app/check.svg';
  static String get accountsBulk => 'assets/svg/app/accounts.svg';
  static String get categoriesBulk => 'assets/svg/app/categories.svg';
  static String get budgetsBulk => 'assets/svg/app/budgets.svg';
  static String get savingsBulk => 'assets/svg/app/saving.svg';
  static String get savingsEmptyLight => 'assets/svg/app/saving-empty.svg';
  static String get savingsLight => 'assets/svg/app/saving-bag.svg';
  static String get reportsBulk => 'assets/svg/app/report.svg';
  static String get coinsBulk => 'assets/svg/app/coins.svg';
  static String get backspaceLight => 'assets/svg/app/backspace.svg';
  static String get downloadLight => 'assets/svg/app/download.svg';
  static String get uploadLight => 'assets/svg/app/upload.svg';
  static String get minusLight => 'assets/svg/app/minus.svg';
  static String get closeLight => 'assets/svg/app/close.svg';
  static String get installmentTwoTone => 'assets/svg/app/installment.svg';
  static String get todayLight => 'assets/svg/app/fullPayment.svg';
  static String get handCoinTwoTone => 'assets/svg/app/hand_coin.svg';
  static String get receiptCheckBulk => 'assets/svg/app/receipt_check.svg';
  static String get receiptDollarBulk => 'assets/svg/app/receipt_dollar.svg';
  static String get receiptEditLight => 'assets/svg/app/receipt_edit.svg';
  static String get noteLight => 'assets/svg/app/note.svg';
  static String get creditLight => 'assets/svg/app/credit.svg';
  static String get statementCheckpointBulk => 'assets/svg/app/statement_checkpoint.svg';
  static String get sadFaceBulk => 'assets/svg/app/sad_face.svg';
  static String get fykFaceBulk => 'assets/svg/app/fyk_face.svg';
  static String get switchTwoTone => 'assets/svg/app/switch.svg';
  static String get turnTwoTone => 'assets/svg/app/turn.svg';
  static String get heartLight => 'assets/svg/app/heart-outline.svg';
  static String get heartBulk => 'assets/svg/app/heart-fill.svg';
  static String get recurrenceBulk => 'assets/svg/app/recurrence.svg';
  static String get walletLight => 'assets/svg/app/wallet.svg';
  static String get monthlyLight => 'assets/svg/app/monthly.svg';
  static String get weeklyLight => 'assets/svg/app/weekly.svg';
  static String get bookmarkBulk => 'assets/svg/app/bookmark.svg';

  static String get alienTwoTone => 'assets/svg/app/alien.svg';
  static String get starTwoTone => 'assets/svg/app/star.svg';
  static String get heartBreakTwoTone => 'assets/svg/app/heart-break.svg';
  static String get cartTwoTone => 'assets/svg/app/cart.svg';
  static String get deliveryTwoTone => 'assets/svg/app/delivery.svg';
  static String get bagsTwoTone => 'assets/svg/app/bag.svg';

  static String get defaultIcon => 'assets/svg/app/default.svg';

  static String get pageViewLarge => 'assets/svg/app/page-view.svg';
  static String get scrollableSheetLarge => 'assets/svg/app/scrollable-sheet.svg';

  /// Call this function in `main()` method, before `runApp()`
  static Future<void> init() async {
    final assets = await rootBundle.loadString('AssetManifest.json');

    _json = jsonDecode(assets);

    iconsWithCategories = <String, List<String>>{
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
