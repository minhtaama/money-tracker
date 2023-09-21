import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../common_widgets/page_heading.dart';
import '../../../utils/constants.dart';
import '../data/settings_controller.dart';

class SelectCurrencyScreen extends ConsumerWidget {
  const SelectCurrencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPage(
        smallTabBar: const SmallTabBar(
          child: PageHeading(
            hasBackButton: true,
            title: 'Set Currency',
          ),
        ),
        children: [
          CustomSection(
            isWrapByCard: true,
            sections: List.generate(
                Currency.values.length,
                (index) => CustomTile(
                      title: Currency.values[index].name,
                      trailing: Text(
                        Currency.values[index].code,
                        style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                      ),
                      onTap: () {
                        final settingController = ref.read(settingsControllerProvider.notifier);
                        settingController.set(currency: Currency.values[index]);
                        context.pop();
                      },
                    )),
          ),
        ],
      ),
    );
  }
}
