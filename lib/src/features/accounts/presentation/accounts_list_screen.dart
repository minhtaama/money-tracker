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
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_credit_checkpoint_modal_screen.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../common_widgets/modal_bottom_sheets.dart';
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
                return CustomInkWell(
                  onTap: () {
                    if (model is CreditAccount) {
                      context.push(RoutePath.creditAccountScreen, extra: model);
                    }
                    // TODO: Add regular account screen
                  },
                  child: CardItem(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: model.backgroundColor.addDark(context.appTheme.isDarkTheme ? 0.2 : 0.0),
                    height: 170,
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
                              opacity: 0.45,
                              child: SvgIcon(model.iconPath, size: 30),
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
                                  style: kHeader2TextStyle.copyWith(color: model.iconColor, fontSize: 22),
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                                Gap.w16,
                                // Account Type
                                model is CreditAccount
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: model.iconColor,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'Credit',
                                          style: kHeader4TextStyle.copyWith(color: model.backgroundColor, fontSize: 12),
                                        ),
                                      )
                                    : Gap.noGap,
                              ],
                            ),
                            const Expanded(child: SizedBox()),
                            Text(
                              'Current Balance:',
                              style: kHeader4TextStyle.copyWith(color: model.iconColor),
                            ),
                            Row(
                              // Account Current Balance
                              children: [
                                Text(
                                  context.currentSettings.currency.code,
                                  style: kHeader4TextStyle.copyWith(
                                      color: model.iconColor, fontSize: kHeader1TextStyle.fontSize),
                                ),
                                Gap.w8,
                                Expanded(
                                  child: Text(
                                    CalService.formatCurrency(context, model.availableAmount),
                                    style: kHeader1TextStyle.copyWith(color: model.iconColor),
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
                );
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
      backgroundColor: context.appTheme.background500,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            title: 'Accounts',
            hasBackButton: true,
            trailing: RoundedIconButton(
              iconPath: AppIcons.add,
              iconColor: context.appTheme.onBackground,
              backgroundColor: context.appTheme.background400,
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
