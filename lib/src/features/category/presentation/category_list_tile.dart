import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../utils/constants.dart';

class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    Key? key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.name,
    required this.onMenuTap,
  }) : super(key: key);
  final String icon;
  final Color backgroundColor;
  final Color iconColor;
  final String name;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundedIconButton(
          icon: icon,
          iconPadding: 8,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          onTap: null,
        ),
        Gap.w16,
        Expanded(
          child: Text(
            name,
            style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative),
          ),
        ),
        Gap.w8,
        RoundedIconButton(
          icon: AppIcons.edit,
          backgroundColor: Colors.transparent,
          iconColor: context.appTheme.backgroundNegative,
          onTap: onMenuTap,
        ),
      ],
    );
  }
}
