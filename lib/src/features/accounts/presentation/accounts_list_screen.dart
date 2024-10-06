import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/illustration.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/saving/edit_modal.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
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
                context.loc.noAccountsAvailable,
              ),
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
              EmptyIllustration(
                AppIcons.savingsEmptyLight,
                context.loc.noSavingsAvailable,
              ),
            ];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: CustomPage(
        smallTabBar: SmallTabBar(
          firstChild: PageHeading(
            title: context.loc.accounts,
            isTopLevelOfNavigationRail: true,
            trailing: RoundedIconButton(
              iconPath: AppIcons.addLight,
              iconColor: context.appTheme.onBackground,
              backgroundColor: context.appTheme.background0,
              onTap: () => context.go(RoutePath.addAccount),
            ),
          ),
        ),
        children: [
          Gap.h8,
          CustomSection(
            isWrapByCard: false,
            sectionsClipping: false,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            onReorder: (oldIndex, newIndex) =>
                accountRepository.reorder([AccountType.regular, AccountType.credit], oldIndex, newIndex),
            sections: buildAccountCards(context),
          ),
          Gap.h8,
          CustomSection(
            title: context.loc.savings,
            isWrapByCard: false,
            sectionsClipping: false,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            onReorder: (oldIndex, newIndex) => accountRepository.reorder([AccountType.saving], oldIndex, newIndex),
            sections: buildSavingCards(context),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.model});

  final Account model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fgColor = context.appTheme.onBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => context.pushThenChangeBrightnessToDefaultWhenPop(
          ref,
          RoutePath.accountScreen,
          extra: model.databaseObject.id.hexString,
        ),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          elevation: 1,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: model.backgroundColor,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgIcon(
                      model.iconPath,
                      color: model.iconColor,
                      size: 50,
                    ),
                    Gap.w10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: kHeader2TextStyle.copyWith(color: model.iconColor, fontSize: 20),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        Text(
                          model is CreditAccount ? context.loc.creditAccount : context.loc.regularAccount,
                          style: kNormalTextStyle.copyWith(color: model.iconColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    model is CreditAccount
                        ? Expanded(child: _CreditDetails(model: model as CreditAccount))
                        : const Spacer(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            model is RegularAccount ? context.loc.currentBalance : context.loc.outstandingCredit,
                            style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
                          ),
                          MoneyAmount(
                            noAnimation: true,
                            amount: model.availableAmount,
                            style: kHeader1TextStyle.copyWith(color: fgColor, fontSize: 23),
                            symbolStyle: kHeader3TextStyle.copyWith(color: fgColor, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              model is CreditAccount
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0),
                      child: _Bar(
                          color: model.backgroundColor,
                          percentage: model.availableAmount / (model as CreditAccount).creditLimit),
                    )
                  : Gap.noGap,
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

  @override
  Widget build(BuildContext context) {
    final fgColor = context.appTheme.onBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statement: ${context.loc.dateOrdinal(model.statementDay.toString())}',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
        Text(
          'Payment due: ${context.loc.dateOrdinal(model.paymentDueDay.toString())}',
          style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
        ),
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
        onTap: () => context.go(RoutePath.savingModalScreen, extra: model.databaseObject.id.hexString),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RoundedIconButton(
                      iconPath: AppIcons.editLight,
                      backgroundColor: Colors.transparent,
                      iconColor: model.iconColor,
                      size: 30,
                      iconPadding: 5,
                      onTap: () => showCustomModal(
                        context: context,
                        child: EditSavingModalScreen(model),
                      ),
                    ),
                  )
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
