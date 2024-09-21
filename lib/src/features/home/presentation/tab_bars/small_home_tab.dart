import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_navigation_rail_shell.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/accounts/application/account_services.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../transactions/data/transaction_repo.dart';
import '../../../transactions/domain/transaction_base.dart';

class SmallHomeTab extends ConsumerWidget {
  const SmallHomeTab({
    super.key,
    required this.secondaryTitle,
    required this.showNumber,
    required this.onEyeTap,
  });

  final String secondaryTitle;
  final bool showNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountService = ref.watch(accountServicesProvider);

    double totalBalance = accountService.getTotalBalance();

    ref.watch(transactionsChangesStreamProvider).whenData((_) {
      totalBalance = accountService.getTotalBalance();
    });

    return PageHeading(
      leadingTitle: context.appSettings.currency.code,
      title: CalService.formatCurrency(
        context,
        totalBalance,
      ),
      secondaryTitle: secondaryTitle,
      trailing: RoundedIconButton(
        iconPath: !showNumber ? AppIcons.eyeBulk : AppIcons.eyeSlashBulk,
        backgroundColor: Colors.transparent,
        iconColor: context.appTheme.onBackground,
        onTap: onEyeTap,
      ),
    );
  }
}

class MultiSelectionTab extends StatelessWidget {
  const MultiSelectionTab({
    super.key,
    this.backgroundColor,
    this.isTopNavigation = true,
    required this.selectedTransactions,
    required this.onConfirmDelete,
    required this.onClear,
  });

  final Color? backgroundColor;
  final bool isTopNavigation;
  final List<BaseTransaction> selectedTransactions;
  final VoidCallback onConfirmDelete;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kCustomTabBarHeight + Gap.statusBarHeight(context),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 1],
          colors: [
            backgroundColor?.withOpacity(0.05) ?? context.appTheme.primary.withOpacity(0.05),
            backgroundColor?.withOpacity(context.appTheme.isDarkTheme ? 0.25 : 0.15) ??
                context.appTheme.primary.withOpacity(context.appTheme.isDarkTheme ? 0.25 : 0.15),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: Gap.statusBarHeight(context),
          ),
          Expanded(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Gap.w12,
                  Expanded(
                    child: EasyRichText(
                      context.loc.nTransactionsSelected(selectedTransactions.length),
                      defaultStyle: kHeader3TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 2,
                      patternList: [
                        EasyRichTextPattern(
                          targetString: r"[0-9]+",
                          style: kHeader1TextStyle.copyWith(
                            color: context.appTheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RoundedIconButton(
                    iconPath: AppIcons.deleteLight,
                    iconColor: context.appTheme.onBackground,
                    backgroundColor: Colors.transparent,
                    onTap: () => showConfirmModal(
                      context: context,
                      isOnTopNavigation: isTopNavigation,
                      label: context.loc.deleteNTransactionConfirm(selectedTransactions.length),
                      onConfirm: onConfirmDelete,
                    ),
                  ),
                  Gap.w2,
                  RoundedIconButton(
                    iconPath: AppIcons.closeLight,
                    iconColor: context.appTheme.onBackground,
                    backgroundColor: Colors.transparent,
                    onTap: onClear,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
