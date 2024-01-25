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
    required this.dateDisplay,
    this.onTapLeft,
    this.onTapRight,
    this.onTapGoToCurrentDate,
  });
  final Account account;
  final String dateDisplay;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapGoToCurrentDate;

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
              iconColor: context.appTheme.onBackground,
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
          ],
        ),
        const Spacer(),
        _StatementSelector(
          dateDisplay: dateDisplay,
          onTapLeft: onTapLeft,
          onTapRight: onTapRight,
          onTapGoToCurrentDate: onTapGoToCurrentDate,
        ),
      ],
    );
  }
}

class _StatementSelector extends StatelessWidget {
  const _StatementSelector({
    super.key,
    required this.dateDisplay,
    this.onTapLeft,
    this.onTapRight,
    this.onTapGoToCurrentDate,
  });

  final String dateDisplay;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapGoToCurrentDate;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Container(
        width: Gap.screenWidth(context),
        height: 85,
        padding: const EdgeInsets.only(top: 10, bottom: 35),
        decoration: BoxDecoration(
          color: context.appTheme.background0,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, 1),
              child: RoundedIconButton(
                iconPath: AppIcons.arrowLeft,
                iconColor: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
                //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
                onTap: onTapLeft,
                size: 35,
                iconPadding: 6,
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
                          ? context.appTheme.onBackground.withOpacity(0.7)
                          : context.appTheme.onSecondary.withOpacity(0.7),
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
                                ? context.appTheme.onBackground
                                : context.appTheme.onSecondary,
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
                iconColor: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,

                //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
                onTap: onTapRight,
                size: 35,
                iconPadding: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
