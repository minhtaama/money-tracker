import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_card.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/expense_pie_chart_widget.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../theme_and_ui/icons.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          title: context.localize.dashboard,
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
        DashboardWidget(title: 'Monthly Expense', child: ExpensePieChartWidget()),
        DashboardCard(
          onTap: () => context.push(RoutePath.accounts),
          title: 'Accounts',
          icon: AppIcons.accounts,
        ),
        DashboardCard(
          onTap: () => context.push(RoutePath.categories),
          title: 'Category',
          icon: AppIcons.categories,
        ),
        DashboardCard(
          title: 'Budget',
          icon: AppIcons.budgets,
        ),
        DashboardCard(
          title: 'Saving',
          icon: AppIcons.savings,
        ),
        DashboardCard(
          title: 'Reports',
          icon: AppIcons.reports,
        ),
      ],
    );
  }
}
