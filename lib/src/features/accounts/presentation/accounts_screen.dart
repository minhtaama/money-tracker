import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../utils/constants.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepository = ref.watch(accountRepositoryProvider);
    final settingsRepository = ref.watch(settingsControllerProvider);

    List<AccountIsar> accountList = accountRepository.getList(null);

    ref.watch(accountsChangesProvider).whenData((_) {
      accountList = accountRepository.getList(null);
    });

    List<Widget> buildAccountCards(BuildContext context) {
      return accountList.isNotEmpty
          ? List.generate(
              accountList.length,
              (index) {
                AccountIsar model = accountList[index];
                return CardItem(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColors.allColorsUserCanPick[model.colorIndex][0]
                      .addDark(context.appTheme.isDarkTheme ? 0.2 : 0.0),
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
                            child:
                                SvgIcon(AppIcons.fromCategoryAndIndex(model.iconCategory, model.iconIndex), size: 30),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 150),
                                // Account Name
                                child: Text(
                                  model.name,
                                  style: kHeader2TextStyle.copyWith(
                                      color: AppColors.allColorsUserCanPick[model.colorIndex][1], fontSize: 22),
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                              ),
                              Gap.w16,
                              // Account Type
                              model.type == AccountType.credit
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.allColorsUserCanPick[model.colorIndex][1],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'Credit',
                                        style: kHeader4TextStyle.copyWith(
                                            color: AppColors.allColorsUserCanPick[model.colorIndex][0], fontSize: 12),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            'Current Balance:',
                            style:
                                kHeader4TextStyle.copyWith(color: AppColors.allColorsUserCanPick[model.colorIndex][1]),
                          ),
                          Row(
                            // Account Current Balance
                            children: [
                              Text(
                                settingsRepository.currency.code,
                                style: kHeader4TextStyle.copyWith(
                                    color: AppColors.allColorsUserCanPick[model.colorIndex][1],
                                    fontSize: kHeader1TextStyle.fontSize),
                              ),
                              Gap.w8,
                              Expanded(
                                child: Text(
                                  CalculatorService.formatCurrency(model.balance),
                                  style: kHeader1TextStyle.copyWith(
                                      color: AppColors.allColorsUserCanPick[model.colorIndex][1]),
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
                );
              },
            )
          : [
              Text(
                'Nothing in here.\nPlease add a new account',
                style: kHeader2TextStyle.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              )
            ];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            title: 'Accounts',
            hasBackButton: true,
            trailing: RoundedIconButton(
              iconPath: AppIcons.add,
              iconColor: context.appTheme.backgroundNegative,
              backgroundColor: context.appTheme.background3,
              onTap: () => context.push(RoutePath.addAccount),
            ),
          ),
        ),
        children: [
          CustomSection(
            isWrapByCard: false,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            onReorder: (oldIndex, newIndex) => accountRepository.reorder(accountList, oldIndex, newIndex),
            children: buildAccountCards(context),
          ),
        ],
      ),
    );
  }
}
