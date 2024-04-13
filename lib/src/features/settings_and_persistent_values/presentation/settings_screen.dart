import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/presentation/components/color_picker.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/presentation/components/setting_tile_dropdown.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/presentation/components/setting_tile_toggle.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../data/settings_repo.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsController = ref.watch(settingsControllerProvider.notifier);
    final statusBarBrightness = ref.read(systemIconBrightnessProvider.notifier);

    final currentSettings = context.appSettings;
    final currSymbol = currentSettings.currency.symbol;
    final currAmount = CalService.formatCurrency(context, 2000);

    final today = DateTime.now();

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            isTopLevelOfNavigationRail: true,
            title: context.localize.settings,
          ),
        ),
        children: [
          CustomSection(
            crossAxisAlignment: CrossAxisAlignment.start,
            sections: [
              ColorPicker(
                currentThemeType: context.appTheme.isDarkTheme ? ThemeType.dark : ThemeType.light,
                colorsList: AppColors.allThemeData,
                currentColorIndex: context.appSettings.themeIndex,
                onColorTap: (int value) {
                  settingsController.set(themeIndex: value);
                  statusBarBrightness.state = context.appTheme.systemIconBrightnessOnSmallTabBar;
                },
              ),
              Gap.divider(context, indent: 6),
              SettingTileToggle(
                title: context.localize.useDarkMode,
                valueLabels: [context.localize.off, context.localize.on, context.localize.systemDefault],
                onTap: (int index) {
                  settingsController.set(themeType: ThemeType.values[index]);
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    statusBarBrightness.state = context.appTheme.systemIconBrightnessOnSmallTabBar;
                  });
                },
                valuesCount: ThemeType.values.length,
                initialValueIndex: ThemeType.values.indexOf(currentSettings.themeType),
              ),
            ],
          ),
          CustomSection(
            sections: [
              Gap.h4,
              CustomTile(
                title: context.localize.setCurrency,
                secondaryTitle: currentSettings.currency.name,
                secondaryTitleOverflow: true,
                leading: SvgIcon(
                  AppIcons.coins,
                  color: context.appTheme.onBackground,
                ),
                trailing: Row(
                  children: [
                    Text(
                      currentSettings.currency.code,
                      style:
                          kHeader1TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 18),
                    ),
                    Gap.w4,
                    SvgIcon(
                      AppIcons.arrowRight,
                      color: context.appTheme.onBackground,
                      size: 17,
                    ),
                  ],
                ),
                onTap: () => context.push(RoutePath.setCurrency),
              ),
              Gap.divider(context, indent: 6),
              SettingTileDropDown<CurrencyType>(
                title: context.localize.currencyFormat,
                initialValue: currentSettings.currencyType,
                values: [
                  (CurrencyType.symbolBefore, '$currSymbol $currAmount'),
                  (CurrencyType.symbolAfter, '$currAmount $currSymbol'),
                ],
                onChanged: (type) => settingsController.set(currencyType: type),
              ),
              SettingTileToggle(
                title: context.localize.withDecimalDigits,
                onTap: (int index) {
                  settingsController.set(showDecimalDigits: index == 0 ? false : true);
                },
                valuesCount: 2,
                initialValueIndex: currentSettings.showDecimalDigits ? 1 : 0,
              ),
            ],
          ),
          CustomSection(
            sections: [
              SettingTileDropDown<Locale>(
                title: context.localize.language,
                initialValue: currentSettings.locale,
                values: AppLocalizations.supportedLocales.map((e) => (e, e.languageName)).toList(),
                onChanged: (type) => settingsController.set(locale: type),
              ),
              SettingTileDropDown<LongDateType>(
                title: context.localize.longDateFormat,
                initialValue: currentSettings.longDateType,
                values:
                    LongDateType.values.map((e) => (e, today.toLongDate(context, custom: e))).toList(),
                onChanged: (type) => settingsController.set(longDateType: type),
              ),
              SettingTileDropDown<ShortDateType>(
                title: context.localize.shortDateFormat,
                initialValue: currentSettings.shortDateType,
                values:
                    ShortDateType.values.map((e) => (e, today.toShortDate(context, custom: e))).toList(),
                onChanged: (type) => settingsController.set(shortDateType: type),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
