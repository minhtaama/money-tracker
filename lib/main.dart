import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // need to add to pubspec.yaml as a dependency
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/application/app_persistent.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/data/persistent_repo.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/data/settings_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/application/app_settings.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); //remove # character in web link

  // initialize REALM database
  final realmDataStore = RealmDataStore();
  realmDataStore.init();

  // initialize app icons
  await AppIcons.init();

  runApp(
    ProviderScope(
      overrides: [
        realmDataStoreProvider.overrideWithValue(realmDataStore),
      ],
      child: const MaterialApp(home: MoneyTrackerApp()),
    ),
  );
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemIconBrightness = ref.watch(systemIconBrightnessProvider);
    final appSettings = ref.watch(settingsControllerProvider);
    final appPersistentValues = ref.watch(persistentControllerProvider);

    return AppPersistent(
      data: appPersistentValues,
      child: AppSettings(
        data: appSettings,
        child: Builder(
          builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: context.appTheme.background1,
              systemNavigationBarIconBrightness: context.appTheme.isDarkTheme ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: systemIconBrightness,
            ),
            child: MaterialApp.router(
              restorationScopeId: 'app',
              locale: context.appSettings.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: goRouter,
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'WixMadeforDisplay',
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: ZoomPageTransitionsBuilder(
                      allowEnterRouteSnapshotting: false,
                    ),
                  },
                ),
                // For showDatePicker2 colors
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(surfaceTint: Colors.transparent, primary: context.appTheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
