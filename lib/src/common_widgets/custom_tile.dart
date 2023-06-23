import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomTile extends StatelessWidget {
  const CustomTile(
      {Key? key,
      required this.title,
      this.secondaryTitle,
      required this.color,
      required this.icon,
      this.trailing,
      this.onTap})
      : super(key: key);
  final String title;
  final String? secondaryTitle;
  final Color color;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      inkColor: context.appTheme.backgroundNegative,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          Expanded(
            child: secondaryTitle != null
                ? Column(
                    children: [
                      Text(title),
                      Text(secondaryTitle!),
                    ],
                  )
                : Text(title),
          ),
          trailing ?? const SizedBox(),
        ],
      ),
    );
  }
}
