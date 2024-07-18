import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../theme_and_ui/icons.dart';
import '../../utils/constants.dart';
import '../rounded_icon_button.dart';
import '../svg_icon.dart';

class CustomPageToolBar extends StatelessWidget {
  const CustomPageToolBar({
    super.key,
    required this.displayDate,
    this.onTapLeft,
    this.onTapRight,
    this.onDateTap,
    required this.topTitle,
    required this.title,
    this.optionalButton,
    this.isToday,
  });

  final DateTime displayDate;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onDateTap;
  final String topTitle;
  final String title;
  final Widget? optionalButton;
  final bool? isToday;

  @override
  Widget build(BuildContext context) {
    bool today = displayDate.onlyYearMonth.isAtSameMomentAs(DateTime.now().onlyYearMonth);

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Gap.w12,
          Flexible(
            flex: 3,
            child: GestureDetector(
              onTap: onDateTap,
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
                child: Column(
                  key: ValueKey(displayDate.toLongDate(context, noDay: true)),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(
                        topTitle,
                        style: kHeader3TextStyle.copyWith(
                          color: context.appTheme.onBackground.withOpacity(0.9),
                          fontSize: 13,
                          letterSpacing: 0.5,
                          height: 0.99,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: kHeader1TextStyle.copyWith(
                                color: context.appTheme.onBackground.withOpacity(0.9),
                                fontSize: 22,
                                letterSpacing: 0.6,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Gap.w8,
                        isToday ?? today
                            ? Gap.noGap
                            : Transform.translate(
                                offset: const Offset(0, 2),
                                child: SvgIcon(
                                  AppIcons.turnTwoTone,
                                  color: context.appTheme.onBackground,
                                  size: 20,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          optionalButton != null
              ? Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: optionalButton!),
                      Gap.verticalDivider(context, indent: 10),
                      Expanded(
                        child: RoundedIconButton(
                          iconPath: AppIcons.arrowLeftLight,
                          iconColor: context.appTheme.onBackground,
                          backgroundColor: Colors.transparent,
                          onTap: onTapLeft,
                          size: 30,
                          iconPadding: 5,
                        ),
                      ),
                      Expanded(
                        child: RoundedIconButton(
                          iconPath: AppIcons.arrowRightLight,
                          iconColor: context.appTheme.onBackground,
                          backgroundColor: Colors.transparent,
                          onTap: onTapRight,
                          size: 30,
                          iconPadding: 5,
                        ),
                      ),
                    ],
                  ),
                )
              : Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RoundedIconButton(
                        iconPath: AppIcons.arrowLeftLight,
                        iconColor: context.appTheme.onBackground,
                        backgroundColor: Colors.transparent,
                        onTap: onTapLeft,
                        size: 30,
                        iconPadding: 5,
                      ),
                      Gap.w8,
                      RoundedIconButton(
                        iconPath: AppIcons.arrowRightLight,
                        iconColor: context.appTheme.onBackground,
                        backgroundColor: Colors.transparent,
                        onTap: onTapRight,
                        size: 30,
                        iconPadding: 5,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
