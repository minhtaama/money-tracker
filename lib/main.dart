import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // need to add to pubspec.yaml as a dependency
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/theming/app_colors.dart';
import 'package:money_tracker_app/src/theming/app_theme.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

Future<void> main() async {
  usePathUrlStrategy(); //remove # character in web link
  await HiveDataStore.init();
  runApp(
    ProviderScope(
      overrides: [
        settingsHiveModelControllerProvider.overrideWith(
          (ref) => SettingsHiveModelController(HiveDataStore.getSettingsHiveModel),
        ),
      ],
      child: const MoneyTrackerApp(),
    ),
  );
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsHiveModelControllerProvider);

    return AppTheme(
      data: AppColors.allThemeData[settingsState.currentThemeIndex],
      child: Builder(
        builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppColors.allThemeData[settingsState.currentThemeIndex].overlayStyle.copyWith(
              systemNavigationBarColor: context.appTheme.background, //Same as BottomAppBarWithFab
              systemNavigationBarIconBrightness: Brightness.dark),
          child: MaterialApp.router(
            restorationScopeId: 'app',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: goRouter,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'WixMadeforDisplay',
            ),
          ),
        ),
      ),
    );
  }
}
