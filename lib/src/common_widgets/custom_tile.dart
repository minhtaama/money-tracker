import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.title,
    this.titleSize = 15,
    this.secondaryTitle,
    this.secondarySize = 12,
    this.secondaryTitleOverflow = false,
    this.leading,
    this.trailing,
    this.onTap,
  });
  final String title;
  final double titleSize;
  final String? secondaryTitle;
  final double secondarySize;
  final bool secondaryTitleOverflow;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      inkColor: context.appTheme.onBackground.withOpacity(0.1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            leading ?? const SizedBox(),
            leading != null ? Gap.w12 : Gap.noGap,
            Expanded(
              child: secondaryTitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: kHeader2TextStyle.copyWith(
                            color: context.appTheme.onBackground,
                            fontSize: titleSize,
                          ),
                        ),
                        Text(
                          secondaryTitle!,
                          style: kNormalTextStyle.copyWith(
                            color: context.appTheme.onBackground,
                            fontSize: secondarySize,
                          ),
                          overflow: secondaryTitleOverflow ? TextOverflow.fade : null,
                          softWrap: secondaryTitleOverflow ? false : true,
                        )
                      ],
                    )
                  : Text(
                      title,
                      style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                        fontSize: titleSize,
                      ),
                    ),
            ),
            trailing != null ? Gap.w16 : const SizedBox(),
            trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
