import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/illustration.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../utils/constants.dart';
import '../domain/account_base.dart';

class AccountsListScreen extends ConsumerWidget {
  const AccountsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepository = ref.watch(accountRepositoryProvider);

    List<Account> accountList = accountRepository.getList([AccountType.regular, AccountType.credit]);
    List<SavingAccount> savingList =
        accountRepository.getList([AccountType.saving]).whereType<SavingAccount>().toList();

    ref.watch(accountsChangesProvider).whenData((_) {
      accountList = accountRepository.getList([AccountType.regular, AccountType.credit]);
      savingList = accountRepository.getList([AccountType.saving]).whereType<SavingAccount>().toList();
    });

    List<Widget> buildAccountCards(BuildContext context) {
      return accountList.isNotEmpty
          ? List.generate(
              accountList.length,
              (index) {
                Account model = accountList[index];
                return _AccountTile(model: model);
              },
            )
          : [
              Gap.h24,
              EmptyIllustration(
                AppIcons.walletLight,
                'No accounts available'.hardcoded,
              ),
              Gap.h16,
            ];
    }

    List<Widget> buildSavingCards(BuildContext context) {
      return savingList.isNotEmpty
          ? List.generate(
              savingList.length,
              (index) {
                SavingAccount model = savingList[index];
                return _SavingTile(model: model);
              },
            )
          : [
              Gap.h24,
              EmptyIllustration(
                AppIcons.savingsEmptyLight,
                'No saving accounts'.hardcoded,
              ),
              Gap.h16,
            ];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: CustomPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            title: 'Accounts',
            isTopLevelOfNavigationRail: true,
            trailing: RoundedIconButton(
              iconPath: AppIcons.addLight,
              iconColor: context.appTheme.onBackground,
              backgroundColor: context.appTheme.background0,
              onTap: () => context.push(RoutePath.addAccount),
            ),
          ),
        ),
        children: [
          Gap.h8,
          CustomSection(
            isWrapByCard: false,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            onReorder: (oldIndex, newIndex) =>
                accountRepository.reorder([AccountType.regular, AccountType.credit], oldIndex, newIndex),
            sections: buildAccountCards(context),
          ),
          CustomSection(
            title: 'Savings',
            isWrapByCard: false,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            onReorder: (oldIndex, newIndex) => accountRepository.reorder([AccountType.saving], oldIndex, newIndex),
            sections: buildSavingCards(context),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.model});

  final Account model;

  @override
  Widget build(BuildContext context) {
    final fgColor = context.appTheme.onBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => context.push(RoutePath.accountScreen, extra: model.databaseObject.id.hexString),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RoundedIconButton(
                    iconPath: model.iconPath,
                    backgroundColor: model.backgroundColor,
                    iconColor: model.iconColor,
                    iconPadding: 8,
                  ),
                  Gap.w10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 20),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Text(
                        model is CreditAccount ? 'Credit account' : 'Regular Account',
                        style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              model is CreditAccount ? _CreditDetails(model: model as CreditAccount) : Gap.h16,
              Text(
                model is RegularAccount ? 'Current Balance:' : 'Outstanding credit:',
                style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
              ),
              Row(
                // Account Current Balance
                children: [
                  Text(
                    context.appSettings.currency.code,
                    style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 23),
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      CalService.formatCurrency(context, model.availableAmount),
                      style: kHeader1TextStyle.copyWith(color: fgColor, fontSize: 23),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditDetails extends StatelessWidget {
  const _CreditDetails({required this.model});

  final CreditAccount model;

  String _dateBuilder(int day) {
    String suffix = 'th';

    if (day.toString().endsWith('1')) {
      suffix = 'st';
    } else if (day.toString().endsWith('2')) {
      suffix = 'nd';
    } else if (day.toString().endsWith('3')) {
      suffix = 'rd';
    }

    return '${day.toString()}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final fgColor = context.appTheme.onBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.h8,
        Text(
          'Statement: Day ${_dateBuilder(model.statementDay)}',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
        Text(
          'Payment due: Day ${_dateBuilder(model.paymentDueDay)}',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
        Gap.h8,
        _Bar(color: model.backgroundColor, percentage: model.availableAmount / model.creditLimit),
        Gap.h8,
      ],
    );
  }
}

class _SavingTile extends StatelessWidget {
  const _SavingTile({required this.model});

  final SavingAccount model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => context.push(RoutePath.accountScreen, extra: model.databaseObject.id.hexString),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: model.backgroundColor.lerpWithBg(context, 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Transform.translate(
                    offset: const Offset(-5, 0),
                    child: SvgIcon(
                      model.iconPath,
                      color: model.iconColor,
                      size: 60,
                    ),
                  ),
                  Gap.w4,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: kHeader2TextStyle.copyWith(color: model.iconColor, fontSize: 20),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 2,
                        ),
                        Text(
                          model.targetDate?.toLongDate(context) ?? '',
                          style: kHeader4TextStyle.copyWith(color: model.iconColor, fontSize: 13),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _SavingDetails(model: model),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingDetails extends StatelessWidget {
  const _SavingDetails({required this.model});

  final SavingAccount model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.h8,
        _Bar(
          color: model.backgroundColor,
          backgroundColor: context.appTheme.background0,
          percentage: model.availableAmount / model.targetAmount,
        ),
        Gap.h2,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MoneyAmount(
              amount: model.availableAmount,
              style: kHeader4TextStyle.copyWith(color: model.iconColor, fontSize: 12),
              overflow: TextOverflow.fade,
              noAnimation: true,
            ),
            MoneyAmount(
              amount: model.targetAmount,
              style: kHeader4TextStyle.copyWith(color: model.iconColor, fontSize: 12),
              overflow: TextOverflow.fade,
              noAnimation: true,
            ),
          ],
        )
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color, required this.percentage, this.backgroundColor});

  final double percentage;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: double.infinity,
      duration: k250msDuration,
      height: 18,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.greyBgr(context),
        gradient: LinearGradient(
          colors: [color, backgroundColor ?? AppColors.greyBgr(context)],
          stops: [percentage, percentage],
        ),
      ),
    );
  }
}
