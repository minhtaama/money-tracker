import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

/// Value related to Text. To change more details, use .copyWith()
const kHeaderTransparent = TextStyle(color: Colors.transparent);

/// Value related to Text. To change more details, use .copyWith()
const kHeader1TextStyle = TextStyle(fontWeight: FontWeight.w900, fontSize: 28);

/// Value related to Text. To change more details, use .copyWith()
const kHeader2TextStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 21);

/// Value related to Text. To change more details, use .copyWith()
const kHeader3TextStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 18);

/// Value related to Text. To change more details, use .copyWith()
const kHeader4TextStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 15);

/// Value related to CustomTabBar and CustomTabPage
const double kCustomTabBarHeight = 80;

/// Value related to CustomTabBar and CustomTabPage
const double kExtendedCustomTabBarHeight = 380;

const double kMoneyCarouselViewFraction = 0.55;

// Durations
const Duration kNoDuration = Duration(milliseconds: 0);
const Duration k1msDuration = Duration(milliseconds: 1);
const Duration k150msDuration = Duration(milliseconds: 150);
const Duration k250msDuration = Duration(milliseconds: 250);
const Duration k350msDuration = Duration(milliseconds: 350);
const Duration k550msDuration = Duration(milliseconds: 550);

/// Value related to BottomAppBar
const double kBottomAppBarHeight = 75.0;

/// [Gap] is a quick way to display a [SizedBox] widget
class Gap {
  static get noGap => const SizedBox();

  static get w4 => const SizedBox(width: 4);
  static get w8 => const SizedBox(width: 8);
  static get w12 => const SizedBox(width: 12);
  static get w16 => const SizedBox(width: 16);
  static get w24 => const SizedBox(width: 24);
  static get w32 => const SizedBox(width: 32);
  static get w40 => const SizedBox(width: 40);
  static get w48 => const SizedBox(width: 48);

  static get h4 => const SizedBox(height: 4);
  static get h8 => const SizedBox(height: 8);
  static get h12 => const SizedBox(height: 12);
  static get h16 => const SizedBox(height: 16);
  static get h24 => const SizedBox(height: 24);
  static get h32 => const SizedBox(height: 32);
  static get h40 => const SizedBox(height: 40);
  static get h48 => const SizedBox(height: 48);

  static divider(BuildContext context, {double? indent}) => Divider(
        color: context.appTheme.onBackground.withOpacity(0.2),
        indent: indent,
        endIndent: indent,
      );

  static verticalDivider(BuildContext context, {double? indent}) => VerticalDivider(
        color: context.appTheme.onBackground.withOpacity(0.25),
        thickness: 1,
        indent: indent,
        endIndent: indent,
      );

  static get expanded => const Expanded(child: SizedBox());

  static double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}

class Calendar {
  static final DateTime epochDate = DateTime(1970);
  static final DateTime maxDate = DateTime(275759);
  static final DateTime minDate = DateTime(-271819);
}
