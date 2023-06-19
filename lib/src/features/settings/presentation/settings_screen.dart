import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsHiveModelControllerProvider);
    final settingsController = ref.watch(settingsHiveModelControllerProvider.notifier);
    return Scaffold(
      body: CustomTabPage(
        customTabBar: const CustomTabBar(
          smallTabBar: SmallTabBar(
            child: PageHeading(
              hasBackButton: true,
              title: 'Settings',
            ),
          ),
        ),
        children: [
          const Placeholder(),
          ElevatedButton(
              onPressed: () {
                settingsController.changeTheme(2);
              },
              child: Text('change to 1')),
          Text(settingsState.toString()),
        ],
      ),
    );
  }
}
