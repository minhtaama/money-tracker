import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/theming/app_colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      customTabBar: CustomTabBar(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            title: 'Summary',
            trailing: RoundedIconButton(
              icon: Icons.settings,
              backgroundColor: context.appTheme.background3,
              iconColor: AppColors.black,
              onTap: () => print('goétting'),
            ),
          ),
        ),
      ),
      children: [Placeholder()],
    );
  }
}
