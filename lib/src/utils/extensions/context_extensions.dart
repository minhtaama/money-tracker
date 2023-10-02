import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker_app/src/theme_and_ui/app_theme.dart';

import '../../theme_and_ui/colors.dart';
import '../enums.dart';

// https://codewithandrea.com/articles/flutter-localization-build-context-extension/#buildcontext-extension-to-the-rescue

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get localize => AppLocalizations.of(this);
}

extension AppThemeBuildContext on BuildContext {
  ThemeType getThemeType(ThemeType currentThemeType) {
    if (currentThemeType == ThemeType.system) {
      return MediaQuery.of(this).platformBrightness == Brightness.light ? ThemeType.light : ThemeType.dark;
    } else {
      return currentThemeType;
    }
  }

  SettingsData get currentSettings => AppSettings.of(this);

  AppThemeData get appTheme =>
      AppColors.allThemeData[currentSettings.themeIndex][getThemeType(currentSettings.themeType)]!;
}
