import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/summary/presentation/summary_card.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../theme_and_ui/icons.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          title: context.localize.summary,
          secondaryTitle: 'Cashflow: +900.000 VND',
          trailing: RoundedIconButton(
            icon: AppIcons.settings,
            backgroundColor: context.appTheme.background3,
            iconColor: context.appTheme.backgroundNegative,
            onTap: () => context.push(RoutePath.settings),
          ),
        ),
      ),
      children: [
        Gap.h16,
        const SummaryCard(
          title: 'Accounts',
          icon: Icons.currency_exchange,
          child: SizedBox(
            height: 300,
          ),
        ),
        SummaryCard(
          onTap: () => context.push(RoutePath.categories),
          title: 'Category',
          icon: Icons.category,
          child: const SizedBox(
            height: 300,
          ),
        ),
        const SummaryCard(
          title: 'Budget',
          icon: Icons.book,
          child: SizedBox(
            height: 300,
          ),
        ),
        const SummaryCard(
          title: 'Saving',
          icon: Icons.savings,
          child: SizedBox(
            height: 300,
          ),
        ),
        const SummaryCard(
          title: 'Reports',
          icon: Icons.pie_chart,
          child: SizedBox(
            height: 300,
          ),
        ),
      ],
    );
  }
}
