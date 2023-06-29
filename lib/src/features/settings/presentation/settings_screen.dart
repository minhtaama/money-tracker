import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/features/settings/presentation/color_picker.dart';
import 'package:money_tracker_app/src/features/settings/presentation/setting_tile_toggle.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsHiveModelControllerProvider);
    final settingsController = ref.watch(settingsHiveModelControllerProvider.notifier);

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
          CustomSection(
            title: 'Theme',
            children: [
              ColorPicker(
                currentThemeType: context.appTheme.isDarkTheme ? ThemeType.dark : ThemeType.light,
                colorsList: AppColors.allThemeData,
                currentColorIndex: settingsState.currentThemeIndex,
                onColorTap: (int value) {
                  settingsController.setThemeColor(value);
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
                  settingsController.setThemeType(ThemeType.values[index]);
                },
                valuesCount: ThemeType.values.length,
                initialValueIndex: ThemeType.values.indexOf(settingsState.themeType),
              ),
              Text(
                HiveDataStore.getSettingsHiveModel.toString(),
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
