import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // need to add to pubspec.yaml as a dependency
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/settings/domain/settings_isar.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/app_theme.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); //remove # character in web link
  final isarDataStore = IsarDataStore();
  await isarDataStore.init();
  await AppIcons.init();
  runApp(
    ProviderScope(
      overrides: [
        isarDataStoreProvider.overrideWithValue(isarDataStore),
      ],
      child: const MaterialApp(home: MoneyTrackerApp()),
    ),
  );
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({Key? key}) : super(key: key);

  ThemeType getThemeType(BuildContext context, ThemeType currentThemeType) {
    if (currentThemeType == ThemeType.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.light
          ? ThemeType.light
          : ThemeType.dark;
    } else {
      return currentThemeType;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsObject = ref.watch(settingsControllerProvider);

    final currentTheme = AppColors.allThemeData[settingsObject.currentThemeIndex]
        [getThemeType(context, settingsObject.themeType)];

    return AppTheme(
      data: currentTheme!,
      child: Builder(
        builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: currentTheme.overlayStyle.copyWith(
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
