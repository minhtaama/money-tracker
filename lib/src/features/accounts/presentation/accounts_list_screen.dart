import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../utils/constants.dart';
import '../domain/account_base.dart';

class AccountsListScreen extends ConsumerWidget {
  const AccountsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepository = ref.watch(accountRepositoryProvider);

    List<Account> accountList = accountRepository.getList(null);

    ref.watch(accountsChangesProvider).whenData((_) {
      accountList = accountRepository.getList(null);
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
              Text(
                'Nothing in here.\nPlease add a new account',
                style: kHeader2TextStyle.copyWith(color: AppColors.grey(context)),
                textAlign: TextAlign.center,
              )
            ];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            title: 'Accounts',
            hasBackButton: true,
            trailing: RoundedIconButton(
              iconPath: AppIcons.add,
              iconColor: context.appTheme.onBackground,
              backgroundColor: context.appTheme.background0,
              onTap: () => context.push(RoutePath.addAccount),
            ),
          ),
        ),
        children: [
          CustomSection(
            isWrapByCard: false,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            onReorder: (oldIndex, newIndex) => accountRepository.reorder(null, oldIndex, newIndex),
            sections: buildAccountCards(context),
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
    final bgColor = model.backgroundColor.withOpacity(0.55);
    final fgColor = context.appTheme.onBackground;
    final iconColor = model.backgroundColor.addDark(0.2);

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
                        style: kHeader1TextStyle.copyWith(color: fgColor, fontSize: 24),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Text(
                        model is CreditAccount ? 'Credit account' : 'Regular Account',
                        style: kNormalTextStyle.copyWith(
                            color: context.appTheme.onBackground, fontSize: 13),
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
                      style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 23),
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
          'APR: ${model.apr.toString()} %',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
        Text(
          'Statement: Day ${_dateBuilder(model.statementDay)}',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
        Text(
          'Payment due: Day ${_dateBuilder(model.paymentDueDay)}',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
        Gap.h8,
      ],
    );
  }
}
