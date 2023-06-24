import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker_app/src/theme_and_ui/app_theme.dart';

// https://codewithandrea.com/articles/flutter-localization-build-context-extension/#buildcontext-extension-to-the-rescue

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get localize => AppLocalizations.of(this);
}

extension AppThemeBuildContext on BuildContext {
  AppThemeData get appTheme => AppTheme.of(this);
}
