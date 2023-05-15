import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// https://codewithandrea.com/articles/flutter-localization-build-context-extension/#buildcontext-extension-to-the-rescue

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get localize => AppLocalizations.of(this);
}
