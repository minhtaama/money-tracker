import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
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

    List<AccountIsar> accountList = accountRepository.getList();

    ref.watch(accountsChangesProvider).whenData((_) {
      accountList = accountRepository.getList();
    });

    List<Widget> buildAccountCards(BuildContext context) {
      return accountList.isNotEmpty
          ? List.generate(
              accountList.length,
              (index) {
                AccountIsar model = accountList[index];
                return Placeholder();
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
        children: buildAccountCards(context),
      ),
    );
  }
}
