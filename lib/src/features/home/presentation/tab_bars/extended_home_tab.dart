import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../transactions/data/transaction_repo.dart';

class ExtendedHomeTab extends StatelessWidget {
  const ExtendedHomeTab(
      {super.key,
      required this.showNumber,
      required this.onEyeTap,
      required this.dateDisplay,
      this.onTapLeft,
      this.onTapRight,
      this.onTapGoToCurrentDate,
      required this.showGoToCurrentDateButton});
  final bool showNumber;
  final VoidCallback onEyeTap;
  final String dateDisplay;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapGoToCurrentDate;
  final bool showGoToCurrentDateButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const WelcomeText(),
        Gap.h16,
        TotalMoney(
          showNumber: showNumber,
          onEyeTap: onEyeTap,
        ),
        DateSelector(
          dateDisplay: dateDisplay,
          showGoToCurrentDateButton: showGoToCurrentDateButton,
          onTapGoToCurrentDate: onTapGoToCurrentDate,
          onTapLeft: onTapLeft,
          onTapRight: onTapRight,
        )
      ],
    );
  }
}

class DateSelector extends StatelessWidget {
  const DateSelector({
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: const Offset(0, 1),
          child: RoundedIconButton(
            iconPath: AppIcons.arrowLeft,
            iconColor:
                context.appTheme.isDarkTheme ? context.appTheme.backgroundNegative : context.appTheme.secondaryNegative,
            //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
            onTap: onTapLeft,
            size: 20,
            iconPadding: 2,
          ),
        ),
        GestureDetector(
          onTap: onTapGoToCurrentDate,
          child: SizedBox(
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
                  style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.isDarkTheme
                        ? context.appTheme.backgroundNegative.withOpacity(0.7)
                        : context.appTheme.secondaryNegative.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 1),
          child: RoundedIconButton(
            iconPath: AppIcons.arrowRight,
            iconColor:
                context.appTheme.isDarkTheme ? context.appTheme.backgroundNegative : context.appTheme.secondaryNegative,

            //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
            onTap: onTapRight,
            size: 20,
            iconPadding: 2,
          ),
        ),
      ],
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Money Tracker'.hardcoded,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.isDarkTheme ? context.appTheme.backgroundNegative : context.appTheme.secondaryNegative,
        fontSize: 14,
      ),
    );
  }
}

class TotalMoney extends ConsumerWidget {
  const TotalMoney({
    super.key,
    required this.showNumber,
    required this.onEyeTap,
  });

  final bool showNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepository = ref.watch(accountRepositoryProvider);

    double totalBalance = accountRepository.getTotalBalance();

    ref
        .watch(transactionChangesRealmProvider(DateTimeRange(start: Calendar.minDate, end: Calendar.maxDate)))
        .whenData((_) {
      totalBalance = accountRepository.getTotalBalance();
    });

    return SizedBox(
      height: 38,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Transform.translate(
            offset: const Offset(-7, 2),
            child: Text(
              context.currentSettings.currency.symbol ?? context.currentSettings.currency.code,
              style: kHeader3TextStyle.copyWith(
                color: context.appTheme.isDarkTheme
                    ? context.appTheme.backgroundNegative.withOpacity(0.6)
                    : context.appTheme.secondaryNegative.withOpacity(0.6),
                fontSize: 23,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          EasyRichText(
            CalService.formatCurrency(context, totalBalance),
            defaultStyle: kHeader3TextStyle.copyWith(
                color: context.appTheme.isDarkTheme
                    ? context.appTheme.backgroundNegative
                    : context.appTheme.secondaryNegative,
                fontSize: 23,
                letterSpacing: 1),
            textAlign: TextAlign.right,
            patternList: [
              EasyRichTextPattern(
                targetString: r'[0-9]+',
                style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.isDarkTheme
                      ? context.appTheme.backgroundNegative
                      : context.appTheme.secondaryNegative,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Transform.translate(
                  offset: const Offset(0, 1),
                  child: RoundedIconButton(
                    iconPath: !showNumber ? AppIcons.eye : AppIcons.eyeSlash,
                    //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
                    size: 25,
                    iconPadding: 4,
                    iconColor: context.appTheme.isDarkTheme
                        ? context.appTheme.backgroundNegative
                        : context.appTheme.secondaryNegative,
                    onTap: onEyeTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
