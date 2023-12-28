import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class CustomTile extends StatelessWidget {
  const CustomTile({
    Key? key,
    required this.title,
    this.titleSize = 17,
    this.secondaryTitle,
    this.secondaryTitleOverflow = false,
    this.leading,
    this.trailing,
    this.onTap,
  }) : super(key: key);
  final String title;
  final double titleSize;
  final String? secondaryTitle;
  final bool secondaryTitleOverflow;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      inkColor: context.appTheme.onBackground,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
        child: Row(
          children: [
            leading ?? const SizedBox(),
            leading != null ? Gap.w16 : const SizedBox(),
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
                          style: kHeader4TextStyle.copyWith(
                            color: context.appTheme.onBackground,
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
