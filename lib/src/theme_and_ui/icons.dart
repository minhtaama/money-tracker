import 'package:flutter/material.dart';

class AppIcons {
  static Map<String, List<IconData>> get iconsWithCategories => <String, List<IconData>>{
        'Default': [
          Icons.home,
          Icons.favorite,
          Icons.access_time,
          Icons.account_balance_wallet,
          Icons.home,
          Icons.add,
          Icons.access_time,
          Icons.account_balance_wallet,
          Icons.home,
          Icons.add,
          Icons.access_time,
          Icons.account_balance_wallet,
        ],
        'Money': [
          Icons.home,
          Icons.add,
          Icons.access_time,
          Icons.account_balance_wallet,
          Icons.home,
          Icons.add,
          Icons.access_time,
          Icons.account_balance_wallet,
          Icons.home,
          Icons.add,
          Icons.access_time,
          Icons.account_balance_wallet,
        ]
      };

  static IconData get home => Icons.home;
  static IconData get summary => Icons.folder_copy;
  static IconData get income => Icons.arrow_downward;
  static IconData get expense => Icons.arrow_upward;
  static IconData get transfer => Icons.compare_arrows;
  static IconData get eye => Icons.remove_red_eye;
  static IconData get arrowLeft => Icons.keyboard_arrow_left;
  static IconData get arrowRight => Icons.keyboard_arrow_right;
  static IconData get filter => Icons.filter_alt;
  static IconData get settings => Icons.settings;
  static IconData get back => Icons.arrow_back_outlined;
  static IconData get add => Icons.add;
  static IconData get edit => Icons.edit;
  static IconData get delete => Icons.delete_forever;

  static IconData get _defaultIcon => Icons.question_mark_rounded;

  static IconData fromCategoryAndIndex(String iconCategory, int iconIndex) {
    return iconsWithCategories[iconCategory]?[iconIndex] ?? _defaultIcon;
  }
}
