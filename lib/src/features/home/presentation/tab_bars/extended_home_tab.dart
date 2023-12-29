import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/custom_line_chart.dart';
import '../../../../common_widgets/money_carousel.dart';
import '../../../../common_widgets/rounded_icon_button.dart';

class ExtendedHomeTab extends ConsumerWidget {
  const ExtendedHomeTab({
    super.key,
    required this.carouselController,
    required this.initialPageIndex,
    required this.displayDate,
    required this.showNumber,
    required this.onEyeTap,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onDateTap,
  });
  final PageController carouselController;
  final int initialPageIndex;
  final DateTime displayDate;
  final bool showNumber;
  final VoidCallback onEyeTap;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _WelcomeText(),
        Gap.h16,
        MoneyCarousel(
          controller: carouselController,
          initialPageIndex: initialPageIndex,
          leftIconPath: AppIcons.switchIcon,
          rightIconPath: showNumber ? AppIcons.eye : AppIcons.eyeSlash,
          onTapRightIcon: onEyeTap,
          onTapLeftIcon: () {},
        ),
        Expanded(
            child: CustomLineChart(
          currentMonthView: displayDate,
          values: [
            // TODO: Make value dynamic
            CLCData(day: 1, amount: 3500000),
            CLCData(day: 8, amount: 0),
            CLCData(day: 15, amount: 5398458),
            CLCData(day: 23, amount: 4030898),
            CLCData(day: 31, amount: 5873483),
          ],
        )),
        _DateSelector(
          dateDisplay: displayDate.getFormattedDate(hasDay: false, type: DateTimeType.ddmmmmyyyy),
          onDateTap: onDateTap,
          onTapLeft: onTapLeft,
          onTapRight: onTapRight,
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    super.key,
    required this.dateDisplay,
    this.onTapLeft,
    this.onTapRight,
    this.onDateTap,
  });

  final String dateDisplay;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Gap.screenWidth(context),
      height: 64,
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: context.appTheme.background0,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundedIconButton(
            iconPath: AppIcons.arrowLeft,
            iconColor: context.appTheme.onBackground,
            onTap: onTapLeft,
            size: 23,
            iconPadding: 2,
          ),
          Gap.w8,
          GestureDetector(
            onTap: onDateTap,
            child: SizedBox(
              width: 145,
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
                      color: context.appTheme.onBackground,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gap.w8,
          RoundedIconButton(
            iconPath: AppIcons.arrowRight,
            iconColor: context.appTheme.onBackground,
            onTap: onTapRight,
            size: 23,
            iconPadding: 2,
          ),
        ],
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Money Tracker'.hardcoded,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
        fontSize: 14,
      ),
    );
  }
}

// class _TotalMoney extends ConsumerWidget {
//   const _TotalMoney({
//     super.key,
//     required this.showNumber,
//     required this.onEyeTap,
//   });
//
//   final bool showNumber;
//   final VoidCallback onEyeTap;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final accountRepository = ref.watch(accountRepositoryProvider);
//
//     double totalBalance = accountRepository.getTotalBalance();
//
//     ref
//         .watch(transactionChangesRealmProvider(DateTimeRange(start: Calendar.minDate, end: Calendar.maxDate)))
//         .whenData((_) {
//       totalBalance = accountRepository.getTotalBalance();
//     });
//
//     return SizedBox(
//       height: 38,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Spacer(),
//           Transform.translate(
//             offset: const Offset(-7, 2),
//             child: Text(
//               context.currentSettings.currency.symbol ?? context.currentSettings.currency.code,
//               style: kHeader4TextStyle.copyWith(
//                 color: context.appTheme.isDarkTheme
//                     ? context.appTheme.onBackground.withOpacity(0.6)
//                     : context.appTheme.onSecondary.withOpacity(0.6),
//                 fontSize: 20,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//           EasyRichText(
//             CalService.formatCurrency(context, totalBalance),
//             defaultStyle: kHeader4TextStyle.copyWith(
//                 color: context.appTheme.isDarkTheme
//                     ? context.appTheme.onBackground.withOpacity(0.6)
//                     : context.appTheme.onSecondary.withOpacity(0.6),
//                 fontSize: 18,
//                 letterSpacing: 1),
//             textAlign: TextAlign.right,
//             patternList: [
//               EasyRichTextPattern(
//                 targetString: r'[0-9]+',
//                 style: kHeader3TextStyle.copyWith(
//                   color: context.appTheme.isDarkTheme
//                       ? context.appTheme.onBackground.withOpacity(0.8)
//                       : context.appTheme.onSecondary.withOpacity(0.8),
//                   fontSize: 20,
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: Row(
//               children: [
//                 const Spacer(),
//                 Transform.translate(
//                   offset: const Offset(0, 1),
//                   child: RoundedIconButton(
//                     iconPath: !showNumber ? AppIcons.eye : AppIcons.eyeSlash,
//                     //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
//                     size: 25,
//                     iconPadding: 4,
//                     iconColor:
//                     context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
//                     onTap: onEyeTap,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
