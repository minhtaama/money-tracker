import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(
      {Key? key, required this.title, this.hasBackButton = false, this.trailing, this.secondaryTitle})
      : super(key: key);
  final String title;
  final bool hasBackButton;
  final Widget? trailing;
  final String? secondaryTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            hasBackButton
                ? RoundedIconButton(
                    icon: Icons.arrow_back_outlined,
                    backgroundColor: context.appTheme.background3,
                    iconColor: context.appTheme.backgroundNegative,
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
                        Gap.h8,
                        Text(
                          title,
                          style: kHeader1TextStyle.copyWith(
                            color: context.appTheme.backgroundNegative,
                          ),
                        ),
                        Text(
                          secondaryTitle!,
                          style: kHeader4TextStyle.copyWith(
                            color: context.appTheme.backgroundNegative.withOpacity(0.8),
                          ),
                        ),
                        Gap.h8,
                      ],
                    )
                  : Text(
                      title,
                      style: kHeader1TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative,
                      ),
                    ),
            ),
            trailing ?? const SizedBox(),
          ],
        ),
        const Expanded(child: SizedBox())
      ],
    );
  }
}
