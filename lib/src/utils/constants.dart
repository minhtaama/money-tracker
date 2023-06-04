import 'package:flutter/material.dart';

// Value related to Text. To change more details, use .copyWith()
const kHeader1TextStyle = TextStyle(fontWeight: FontWeight.w900, fontSize: 28);
const kHeader2TextStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 21);
const kHeader3TextStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 18);
const kHeader4TextStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 15);

// Value related to CustomTabBar and CustomTabPage
const double kCustomTabBarHeight = 50;
const double kExtendedCustomTabBarHeight = 230;
const double kTriggerHeight = 10;
const Duration kAppBarExtendDuration = Duration(milliseconds: 10);

// Value related to BottomAppBar
const Duration kNavBarDuration = Duration(milliseconds: 200);

// Define Gaps
class Gap {
  static get w4 => const SizedBox(width: 4);
  static get w8 => const SizedBox(width: 8);
  static get w16 => const SizedBox(width: 16);
  static get w24 => const SizedBox(width: 24);
  static get w32 => const SizedBox(width: 32);
  static get w40 => const SizedBox(width: 40);
  static get w48 => const SizedBox(width: 48);

  static get h4 => const SizedBox(height: 4);
  static get h8 => const SizedBox(height: 8);
  static get h16 => const SizedBox(height: 16);
  static get h24 => const SizedBox(height: 24);
  static get h32 => const SizedBox(height: 32);
  static get h40 => const SizedBox(height: 40);
  static get h48 => const SizedBox(height: 48);

  static double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;
}
