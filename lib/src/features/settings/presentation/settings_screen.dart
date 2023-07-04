import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/features/settings/presentation/color_picker.dart';
import 'package:money_tracker_app/src/features/settings/presentation/setting_tile_toggle.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../data/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
          CustomSection(
            title: 'Theme',
            children: [
              ColorPicker(
                currentThemeType: context.appTheme.isDarkTheme ? ThemeType.dark : ThemeType.light,
                colorsList: AppColors.allThemeData,
                currentColorIndex: settingsObject.currentThemeIndex,
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
