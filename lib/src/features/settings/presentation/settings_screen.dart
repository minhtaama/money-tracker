import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/settings/presentation/color_picker.dart';
import 'package:money_tracker_app/src/features/settings/presentation/setting_tile_toggle.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../data/settings_repo.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsController = ref.watch(settingsControllerProvider.notifier);
    final settingsObject = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPage(
        smallTabBar: const SmallTabBar(
          child: PageHeading(
            hasBackButton: true,
            title: 'Settings',
          ),
        ),
        children: [
          CustomSection(sections: [
            CustomTile(
              title: 'Set currency',
              secondaryTitle: settingsObject.currency.name,
              secondaryTitleOverflow: true,
              leading: SvgIcon(
                AppIcons.coins,
                color: context.appTheme.backgroundNegative,
              ),
              trailing: Row(
                children: [
                  Text(
                    settingsObject.currency.code,
                    style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                  ),
                  Gap.w8,
                  SvgIcon(
                    AppIcons.arrowRight,
                    color: context.appTheme.backgroundNegative,
                  ),
                ],
              ),
              onTap: () => context.push(RoutePath.setCurrency),
            ),
            SettingTileToggle(
              title: 'With decimal digits',
              onTap: (int index) {
                settingsController.set(showDecimalDigits: index == 0 ? false : true);
              },
              valuesCount: 2,
              initialValueIndex: settingsObject.showDecimalDigits ? 1 : 0,
            ),
          ]),
          CustomSection(
            title: 'Theme',
            sections: [
              ColorPicker(
                currentThemeType: context.appTheme.isDarkTheme ? ThemeType.dark : ThemeType.light,
                colorsList: AppColors.allThemeData,
                currentColorIndex: context.currentSettings.themeIndex,
                onColorTap: (int value) {
                  settingsController.set(themeIndex: value);
                },
              ),
              SettingTileToggle(
                title: 'Use dark mode',
                valueLabels: const [
                  'Off',
                  'On',
                  'System default',
                ],
                onTap: (int index) {
                  settingsController.set(themeType: ThemeType.values[index]);
                },
                valuesCount: ThemeType.values.length,
                initialValueIndex: ThemeType.values.indexOf(settingsObject.themeType),
              ),
            ],
          )
        ],
      ),
    );
  }
}
