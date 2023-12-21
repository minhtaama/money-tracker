import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/txn_components.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../domain/account_base.dart';

class ExtendedAccountTab extends ConsumerWidget {
  const ExtendedAccountTab({
    super.key,
    required this.account,
  });
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: const Offset(0, 1),
          child: RoundedIconButton(
            iconPath: AppIcons.arrowLeft,
            iconColor: context.appTheme.isDarkTheme
                ? context.appTheme.backgroundNegative
                : context.appTheme.secondaryNegative,
            //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
            onTap: onTapLeft,
            size: 25,
            iconPadding: 2,
          ),
        ),
        GestureDetector(
          onTap: onTapGoToCurrentDate,
          child: Column(
            children: [
              Text(
                'Statement date',
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.isDarkTheme
                      ? context.appTheme.backgroundNegative.withOpacity(0.7)
                      : context.appTheme.secondaryNegative.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
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
                      style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.isDarkTheme
                            ? context.appTheme.backgroundNegative
                            : context.appTheme.secondaryNegative,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 1),
          child: RoundedIconButton(
            iconPath: AppIcons.arrowRight,
            iconColor: context.appTheme.isDarkTheme
                ? context.appTheme.backgroundNegative
                : context.appTheme.secondaryNegative,

            //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
            onTap: onTapRight,
            size: 25,
            iconPadding: 2,
          ),
        ),
      ],
    );
  }
}
