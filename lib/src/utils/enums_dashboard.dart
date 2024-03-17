import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:realm/realm.dart';
import '../theme_and_ui/icons.dart';

enum DashboardWidgetType {
  menu(0),
  weeklyReport(1),
  monthlyExpense(2),
  monthlyIncome(3),
  budgets(4);

  final int databaseValue;

  const DashboardWidgetType(this.databaseValue);

  static DashboardWidgetType fromDatabaseValue(int value) {
    return DashboardWidgetType.values.firstWhere((e) => e.databaseValue == value);
  }

  String get iconPath {
    return switch (this) {
      DashboardWidgetType.menu => AppIcons.categories,
      DashboardWidgetType.weeklyReport => AppIcons.receiptDollar,
      DashboardWidgetType.monthlyExpense => AppIcons.reports,
      DashboardWidgetType.monthlyIncome => AppIcons.reports,
      DashboardWidgetType.budgets => AppIcons.budgets,
    };
  }

  String get name {
    return switch (this) {
      DashboardWidgetType.menu => 'Menu'.hardcoded,
      DashboardWidgetType.weeklyReport => 'Weekly Report'.hardcoded,
      DashboardWidgetType.monthlyExpense => 'Monthly Expense'.hardcoded,
      DashboardWidgetType.monthlyIncome => 'Monthly Income'.hardcoded,
      DashboardWidgetType.budgets => 'Budgets'.hardcoded,
    };
  }
}

// TODO: Add this
enum DWMenuType {
  icon(0),
  button(1);

  final int databaseValue;

  const DWMenuType(this.databaseValue);

  static DWMenuType fromDatabaseValue(int value) {
    return DWMenuType.values.firstWhere((e) => e.databaseValue == value);
  }
}
