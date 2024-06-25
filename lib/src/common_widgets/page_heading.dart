import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../theme_and_ui/icons.dart';

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    this.isTopLevelOfNavigationRail = false,
    this.trailing,
    this.secondaryTitle,
    this.leadingTitle,
  });
  final String? leadingTitle;
  final String title;
  final bool isTopLevelOfNavigationRail;
  final Widget? trailing;
  final String? secondaryTitle;

  @override
  Widget build(BuildContext context) {
    final canPop = context.isBigScreen ? !isTopLevelOfNavigationRail : true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        secondaryTitle != null ? Gap.h8 : Gap.h16,
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              canPop && ModalRoute.of(context)!.canPop
                  ? RoundedIconButton(
                      iconPath: AppIcons.backLight,
                      backgroundColor: Colors.transparent,
                      iconColor: context.appTheme.onBackground,
                      onTap: () => context.pop(),
                    )
                  : const SizedBox(),
              Gap.w8,
              Expanded(
                flex: 5,
                child: secondaryTitle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leadingTitle != null
                              ? Row(
                                  children: [
                                    Text(
                                      leadingTitle!,
                                      style: kNormalTextStyle.copyWith(
                                          color: context.appTheme.onBackground, fontSize: kHeader1TextStyle.fontSize),
                                    ),
                                    Gap.w8,
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: kHeader1TextStyle.copyWith(
                                          color: context.appTheme.onBackground,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  title,
                                  style: kHeader1TextStyle.copyWith(
                                    color: context.appTheme.onBackground,
                                  ),
                                ),
                          Text(
                            secondaryTitle!,
                            style: kNormalTextStyle.copyWith(
                              color: context.appTheme.onBackground.withOpacity(0.8),
                            ),
                          ),
                          Gap.h8,
                        ],
                      )
                    : Text(
                        title,
                        style: kHeader1TextStyle.copyWith(
                          color: context.appTheme.onBackground,
                        ),
                      ),
              ),
              trailing ?? const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
