import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/txn_components.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/modal_bottom_sheets.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../transactions/data/transaction_repo.dart';
import '../../../transactions/presentation/screens/add_credit_checkpoint_modal_screen.dart';
import '../../domain/account_base.dart';

class ExtendedAccountTab extends ConsumerWidget {
  const ExtendedAccountTab({super.key, required this.account});
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textBaseline: TextBaseline.alphabetic,
          children: [
            RoundedIconButton(
              onTap: () => context.pop(),
              backgroundColor: Colors.transparent,
              iconColor: context.appTheme.backgroundNegative,
              iconPath: AppIcons.back,
            ),
            Text(
              account.name,
              style: kHeader2TextStyle.copyWith(
                color: account.iconColor,
                fontSize: 18,
              ),
            ),
            Gap.w8,
            const TxnCreditIcon(
              size: 22,
            ),
            // TODO: Move this into Account screen
            account is CreditAccount
                ? RoundedIconButton(
                    iconPath: AppIcons.add,
                    onTap: () {
                      showCustomModalBottomSheet(
                          context: context, child: AddCreditCheckpointModalScreen(account: account as CreditAccount));
                    },
                  )
                : Gap.noGap,
          ],
        ),
      ],
    );
  }
}

class StatementSelector extends StatelessWidget {
  const StatementSelector({
    super.key,
    required this.dateDisplay,
    this.onTapLeft,
    this.onTapRight,
    this.onTapGoToCurrentDate,
    required this.showGoToCurrentDateButton,
  });

  final String dateDisplay;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapGoToCurrentDate;
  final bool showGoToCurrentDateButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          duration: k150msDuration,
          opacity: showGoToCurrentDateButton ? 1 : 0,
          child: CardItem(
            height: kExtendedTabBarOuterChildHeight,
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: onTapGoToCurrentDate,
              child: SvgIcon(
                AppIcons.today,
                color: context.appTheme.backgroundNegative,
              ),
            ),
          ),
        ),
        Gap.w16,
        CardItem(
          height: kExtendedTabBarOuterChildHeight,
          margin: EdgeInsets.zero,
          color: context.appTheme.isDarkTheme ? context.appTheme.background3 : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTapLeft,
                child: SvgIcon(
                  AppIcons.arrowLeft,
                  color: context.appTheme.backgroundNegative,
                ),
              ),
              Gap.w4,
              SizedBox(
                width: 125,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: k150msDuration,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: Tween<double>(
                          begin: 0,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: Text(
                      key: ValueKey(dateDisplay),
                      dateDisplay,
                      style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                    ),
                  ),
                ),
              ),
              Gap.w4,
              GestureDetector(
                onTap: onTapRight,
                child: SvgIcon(
                  AppIcons.arrowRight,
                  color: context.appTheme.backgroundNegative,
                ),
              ),
            ],
          ),
        ),
        Gap.w16,
        CardItem(
          height: kExtendedTabBarOuterChildHeight,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () {}, //TODO: FILTER
            child: SvgIcon(
              AppIcons.filter,
              color: context.appTheme.backgroundNegative,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}
