import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/summary/presentation/summary_card.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../theme_and_ui/icons.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          title: context.localize.summary,
          secondaryTitle: 'Cashflow: +900.000 VND',
          trailing: RoundedIconButton(
            iconPath: AppIcons.settings,
            iconColor: context.appTheme.onBackground,
            onTap: () => context.push(RoutePath.settings),
          ),
        ),
      ),
      children: [
        Gap.h16,
        SummaryCard(
          onTap: () => context.push(RoutePath.accounts),
          title: 'Accounts',
          icon: AppIcons.accounts,
        ),
        SummaryCard(
          onTap: () => context.push(RoutePath.categories),
          title: 'Category',
          icon: AppIcons.categories,
        ),
        SummaryCard(
          title: 'Budget',
          icon: AppIcons.budgets,
        ),
        SummaryCard(
          title: 'Saving',
          icon: AppIcons.savings,
        ),
        SummaryCard(
          title: 'Reports',
          icon: AppIcons.reports,
        ),
      ],
    );
  }
}
