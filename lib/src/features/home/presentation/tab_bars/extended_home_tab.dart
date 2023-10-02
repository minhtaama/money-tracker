import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../transactions/data/transaction_repo.dart';

class ExtendedHomeTab extends StatelessWidget {
  const ExtendedHomeTab({Key? key, required this.hideNumber, required this.onEyeTap}) : super(key: key);
  final bool hideNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      reverse: true,
      padding: EdgeInsets.zero,
      children: [
        TotalMoney(
          hideNumber: hideNumber,
          onEyeTap: onEyeTap,
        ),
        const WelcomeText(),
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

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, Tâm'.hardcoded,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.isDarkTheme ? context.appTheme.backgroundNegative : context.appTheme.secondaryNegative,
        fontSize: 18,
      ),
    );
  }
}

class TotalMoney extends ConsumerWidget {
  const TotalMoney({
    super.key,
    required this.hideNumber,
    required this.onEyeTap,
  });

  final bool hideNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepository = ref.watch(accountRepositoryProvider);

    double totalBalance = accountRepository.getTotalBalance();

    ref.watch(transactionChangesProvider(DateTimeRange(start: Calendar.minDate, end: Calendar.maxDate))).whenData((_) {
      totalBalance = accountRepository.getTotalBalance();
    });

    return Row(
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          context.currentSettings.currency.code,
          style: kHeader4TextStyle.copyWith(
            fontWeight: FontWeight.w100,
            color:
                context.appTheme.isDarkTheme ? context.appTheme.backgroundNegative : context.appTheme.secondaryNegative,
            fontSize: 36,
            letterSpacing: -2,
          ),
        ),
        Gap.w8,
        Expanded(
          child: EasyRichText(
            CalService.formatCurrency(totalBalance, hideNumber: hideNumber),
            defaultStyle: kHeader2TextStyle.copyWith(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.backgroundNegative
                  : context.appTheme.secondaryNegative,
              fontSize: 25,
            ),
            //textAlign: TextAlign.right,
            patternList: [
              EasyRichTextPattern(
                targetString: '^[0-9]+',
                style: kHeader1TextStyle.copyWith(
                  color: context.appTheme.isDarkTheme
                      ? context.appTheme.backgroundNegative
                      : context.appTheme.secondaryNegative,
                  fontSize: 36,
                ),
              ),
            ],
          ),
        ),
        Gap.w8,
        RoundedIconButton(
          iconPath: hideNumber ? AppIcons.eye : AppIcons.eyeSlash,
          backgroundColor: Colors.transparent,
          iconColor: context.appTheme.backgroundNegative,
          onTap: onEyeTap,
        ),
      ],
    );
  }
}
