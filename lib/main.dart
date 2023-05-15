import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // need to add to pubspec.yaml as a dependency
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  usePathUrlStrategy(); //remove # character in web link
  runApp(const ProviderScope(child: MoneyTrackerApp()));
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: goRouter,
      theme:
          ThemeData(brightness: Brightness.light, useMaterial3: true, fontFamily: 'WixMadeforDisplay'),
      darkTheme:
          ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: 'WixMadeforDisplay'),
      themeMode: ThemeMode.light, //TODO: Implement Theme
    );
  }
}
