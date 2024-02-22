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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: CustomInkWell(
            onTap: () => context.push(RoutePath.accountScreen, extra: model.databaseObject.id.hexString),
            inkColor: bgColor,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                height: 190,
                decoration: BoxDecoration(
                    //color: bgColor.addDark(context.appTheme.isDarkTheme ? 0.2 : 0.0),
                    border: Border.all(
                        width: 1.5, color: bgColor.addDark(context.appTheme.isDarkTheme ? 0.2 : 0.3)),
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        bgColor.addDark(context.appTheme.isDarkTheme ? 0.2 : 0.0),
                        bgColor.withOpacity(0)
                      ],
                      stops: const [0, 1],
                    )),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..translate(-28.0, 35.0)
                          ..scale(7.0),
                        origin: const Offset(15, 15),
                        child: Opacity(
                          opacity: 0.4,
                          child: SvgIcon(model.iconPath, size: 30, color: iconColor),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              model.name,
                              style: kHeader1TextStyle.copyWith(color: fgColor, fontSize: 28),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                            Gap.w16,
                            // Account Type
                            model is CreditAccount
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: model.backgroundColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Credit',
                                      style: kNormalTextStyle.copyWith(
                                          color: model.iconColor, fontSize: 12),
                                    ),
                                  )
                                : Gap.noGap,
                          ],
                        ),
                        model is CreditAccount
                            ? _CreditDetails(model: model as CreditAccount)
                            : Gap.noGap,
                        const Spacer(),
                        Text(
                          model is RegularAccount ? 'Current Balance:' : 'Outstanding credit:',
                          style: kNormalTextStyle.copyWith(color: fgColor),
                        ),
                        Row(
                          // Account Current Balance
                          children: [
                            Text(
                              context.appSettings.currency.code,
                              style: kNormalTextStyle.copyWith(
                                  color: fgColor, fontSize: kHeader1TextStyle.fontSize),
                            ),
                            Gap.w8,
                            Expanded(
                              child: Text(
                                CalService.formatCurrency(context, model.availableAmount),
                                style: kHeader1TextStyle.copyWith(color: fgColor),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
      children: [
        Gap.h4,
        Row(
          children: [
            Text(
              'APR:'.hardcoded,
              style: kHeader3TextStyle.copyWith(color: fgColor, fontSize: 13),
            ),
            Text(
              ' ${model.apr.toString()} %',
              style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 13),
            ),
          ],
        ),
        Gap.h2,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
                offset: const Offset(-2, 0), child: SvgIcon(AppIcons.budgets, color: fgColor, size: 20)),
            Text(
              ': Day ${_dateBuilder(model.statementDay)}',
              style: kHeader3TextStyle.copyWith(color: fgColor, fontSize: 13),
            ),
            Gap.w16,
            SvgIcon(AppIcons.handCoin, color: fgColor, size: 20),
            Text(
              ': Day ${_dateBuilder(model.paymentDueDay)}',
              style: kHeader3TextStyle.copyWith(color: fgColor, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
