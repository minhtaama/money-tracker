import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    Key? key,
    required this.icon,
    this.label,
    required this.backgroundColor,
    this.size,
    this.onTap,
    this.iconColor,
  }) : super(key: key);

  final IconData icon;
  final String? label;
  final Color backgroundColor;
  final Color? iconColor;
  final double? size;
  final VoidCallback? onTap;

  double _getSize(GlobalKey key, BuildContext context) {
    final iconRenderBox = key.currentContext?.findRenderObject() as RenderBox;
    return iconRenderBox.size.height;
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    return Column(
      mainAxisAlignment: label != null ? MainAxisAlignment.start : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CardItem(
          key: key,
          width: size,
          height: size,
          color: backgroundColor,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(1000),
          elevation: 0,
          isGradient: true,
          child: InkWell(
            onTap: onTap,
            splashColor: (iconColor ?? context.appTheme.primaryNegative).withAlpha(105),
            highlightColor: (iconColor ?? context.appTheme.primaryNegative).withAlpha(105),
            borderRadius: BorderRadius.circular(1000),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FittedBox(
                child: Icon(
                  icon,
                  color: iconColor ?? context.appTheme.primaryNegative,
                ),
              ),
            ),
          ),
        ),
        label != null
            ? Material(
                color: Colors.transparent,
                child: Text(
                  label!,
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.backgroundNegative,
                    fontSize: size != null ? size! / 4 : _getSize(key, context) / 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
