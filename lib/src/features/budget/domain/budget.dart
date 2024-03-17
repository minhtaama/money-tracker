import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:realm/realm.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

sealed class BaseBudget extends BaseModel<BudgetDb> {
  final BudgetPeriodType periodType;

  final String name;
  final double amount;

  const BaseBudget(
    super._realmObject, {
    required this.periodType,
    required this.name,
    required this.amount,
  });

  static BaseBudget fromDatabase(BudgetDb budgetRealm) {
    return switch (BudgetType.fromDatabaseValue(budgetRealm.type)) {
      BudgetType.forAccount => AccountBudget._(
          budgetRealm,
          periodType: BudgetPeriodType.fromDatabaseValue(budgetRealm.periodType),
          name: budgetRealm.name,
          amount: budgetRealm.amount,
          accounts:
              budgetRealm.accounts.map((accountDb) => Account.fromDatabaseInfoOnly(accountDb)!).toList(),
        ),
      BudgetType.forCategory => CategoryBudget._(
          budgetRealm,
          periodType: BudgetPeriodType.fromDatabaseValue(budgetRealm.periodType),
          name: budgetRealm.name,
          amount: budgetRealm.amount,
          categories:
              budgetRealm.categories.map((categoryDb) => Category.fromDatabase(categoryDb)!).toList(),
        ),
    };
  }
}

@immutable
class AccountBudget extends BaseBudget {
  final List<AccountInfo> accounts;

  const AccountBudget._(
    super._realmObject, {
    required super.periodType,
    required super.name,
    required super.amount,
    required this.accounts,
  });
}

@immutable
class CategoryBudget extends BaseBudget {
  final List<Category> categories;

  const CategoryBudget._(
    super._realmObject, {
    required super.periodType,
    required super.name,
    required super.amount,
    required this.categories,
  });
}
