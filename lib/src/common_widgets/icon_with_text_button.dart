import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class IconWithTextButton extends StatelessWidget {
  const IconWithTextButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.size = 55,
    this.onTap,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      height: size,
      width: 150,
      color: backgroundColor,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: onTap,
        borderCircularRadiusValue: 1000,
        inkColor: color ?? context.appTheme.primaryNegative,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Icon(
                  icon,
                  color: color ?? context.appTheme.accentNegative,
                ),
              ),
              Gap.w8,
              Expanded(
                flex: 5,
                child: FittedBox(
                  child: Text(
                    label,
                    style: kHeader2TextStyle.copyWith(
                      color: color ?? context.appTheme.accentNegative,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
