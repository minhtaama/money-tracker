import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/application/app_persistent.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/application/app_settings.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import '../../theme_and_ui/colors.dart';
import '../enums.dart';

// https://codewithandrea.com/articles/flutter-localization-build-context-extension/#buildcontext-extension-to-the-rescue

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}

extension MediaQueryBuildContext on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  bool get isBigScreen => MediaQuery.of(this).size.width >= kSmallWidthBreakpoint;
}

extension AppSettingsBuildContext on BuildContext {
  ThemeType _getThemeType(ThemeType currentThemeType) {
    if (currentThemeType == ThemeType.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light
          ? ThemeType.light
          : ThemeType.dark;
    } else {
      return currentThemeType;
    }
  }

  AppSettingsData get appSettings => AppSettings.of(this);

  AppPersistentValues get appPersistentValues => AppPersistent.of(this);

  AppThemeData get appTheme =>
      AppColors.allThemeData[appSettings.themeIndex][_getThemeType(appSettings.themeType)]!;
}

extension LanguageName on Locale {
  String get languageName => switch (languageCode) {
        'en' => 'English',
        'vi' => 'Tiếng Việt',
        _ => '',
      };
}
