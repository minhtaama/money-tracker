import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: CustomTabPage(
        smallTabBar: const SmallTabBar(
          child: PageHeading(
            hasBackButton: true,
            title: 'Settings',
          ),
        ),
        children: [
          CustomSection(
            sections: [
              CustomTile(
                title: 'Set currency',
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
                      style: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 18),
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
              Gap.divider(context),
              SettingTileToggle(
                title: 'With decimal digits:',
                onTap: (int index) {
                  settingsController.set(showDecimalDigits: index == 0 ? false : true);
                },
                valuesCount: 2,
                initialValueIndex: currentSettings.showDecimalDigits ? 1 : 0,
              ),
              SettingTileDropDown<CurrencyType>(
                title: 'Display style:'.hardcoded,
                initialValue: currentSettings.currencyType,
                values: [
                  (CurrencyType.symbolBefore, '$currSymbol $currAmount'),
                  (CurrencyType.symbolAfter, '$currAmount $currSymbol'),
                ],
                onChanged: (type) => settingsController.set(currencyType: type),
              ),
            ],
          ),
          CustomSection(
            title: 'Date format'.hardcoded,
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
              Gap.divider(context),
              SettingTileDropDown<LongDateType>(
                title: 'Long date:'.hardcoded,
                initialValue: currentSettings.longDateType,
                values: LongDateType.values.map((e) => (e, e.name)).toList(),
                onChanged: (type) => settingsController.set(longDateType: type),
              ),
              SettingTileDropDown<ShortDateType>(
                title: 'Short date:'.hardcoded,
                initialValue: currentSettings.shortDateType,
                values: ShortDateType.values.map((e) => (e, e.name)).toList(),
                onChanged: (type) => settingsController.set(shortDateType: type),
              ),
            ],
          ),
          CustomSection(
            title: 'Theme',
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
              Gap.divider(context),
              SettingTileToggle(
                title: 'Use dark mode'.hardcoded,
                valueLabels: const ['Off', 'On', 'System default'],
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
          )
        ],
      ),
    );
  }
}
