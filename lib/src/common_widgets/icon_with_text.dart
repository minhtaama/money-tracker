import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class IconWithText extends StatelessWidget {
  const IconWithText({
    super.key,
    this.iconPath,
    this.header,
    this.onTap,
    this.color,
    this.iconSize,
    this.headerSize,
    this.text,
    this.textSize,
  });

  final String? iconPath;
  final double? iconSize;
  final String? header;
  final double? headerSize;
  final String? text;
  final double? textSize;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      inkColor: AppColors.grey(context),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            runAlignment: WrapAlignment.center,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SvgIcon(
                iconPath ?? AppIcons.minus,
                size: iconSize ?? 40,
                color: color ?? AppColors.grey(context),
              ),
              header != null ? Gap.w4 : Gap.noGap,
              header != null
                  ? Text(
                      header!,
                      style: kHeader2TextStyle.copyWith(
                          color: color ?? AppColors.grey(context), fontSize: headerSize ?? 14),
                      textAlign: TextAlign.center,
                    )
                  : Gap.noGap,
            ],
          ),
          text != null
              ? Text(
                  text!,
                  style: kHeader4TextStyle.copyWith(
                      color: color ?? AppColors.grey(context), fontSize: textSize ?? 13),
                  textAlign: TextAlign.center,
                )
              : Gap.noGap,
        ],
      ),
    );
  }
}
