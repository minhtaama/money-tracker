import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class EmptyInfo extends StatelessWidget {
  const EmptyInfo({super.key, this.iconPath, this.infoText, this.onTap, this.iconSize, this.textSize});

  final String? iconPath;
  final double? iconSize;
  final String? infoText;
  final double? textSize;
  final VoidCallback? onTap;

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
            color: AppColors.grey(context),
          ),
          Text(
            infoText ?? '',
            style: kHeader2TextStyle.copyWith(color: AppColors.grey(context), fontSize: textSize ?? 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
