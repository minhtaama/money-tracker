import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class IconWithText extends StatelessWidget {
  const IconWithText({super.key, this.iconPath, this.text, this.onTap, this.color, this.iconSize, this.textSize});

  final String? iconPath;
  final double? iconSize;
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
          SvgIcon(
            iconPath ?? AppIcons.minus,
            size: iconSize ?? 40,
            color: color ?? AppColors.grey(context),
          ),
          Text(
            text ?? '',
            style: kHeader2TextStyle.copyWith(color: color ?? AppColors.grey(context), fontSize: textSize ?? 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
