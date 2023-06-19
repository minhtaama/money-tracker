import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/summary/presentation/summary_card.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theming/app_colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
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
            secondaryTitle: 'Cashflow: +900.000 VND',
            trailing: RoundedIconButton(
              icon: Icons.settings,
              backgroundColor: context.appTheme.background3,
              iconColor: AppColors.black,
              onTap: () => context.push(RoutePath.setting),
            ),
          ),
        ),
      ),
      children: [
        Gap.h16,
        SummaryCard(
          title: 'Accounts',
          icon: Icons.currency_exchange,
          child: Placeholder(),
        ),
        SummaryCard(
          title: 'Category',
          icon: Icons.category,
          child: Placeholder(),
        ),
        SummaryCard(
          title: 'Budget',
          icon: Icons.book,
          child: Placeholder(),
        ),
        SummaryCard(
          title: 'Saving',
          icon: Icons.savings,
          child: Placeholder(),
        ),
        SummaryCard(
          title: 'Reports',
          icon: Icons.pie_chart,
          child: Placeholder(),
        ),
      ],
    );
  }
}
