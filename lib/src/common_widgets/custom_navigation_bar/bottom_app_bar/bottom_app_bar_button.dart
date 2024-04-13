import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'custom_bottom_app_bar.dart';

class BottomAppBarButton extends StatelessWidget {
  const BottomAppBarButton({
    super.key,
    required this.index,
    required this.onTap,
    required this.item,
    required this.isLeft,
    required this.isSelected,
  });

  final int index;
  final ValueChanged<int> onTap;
  final bool isLeft;
  final bool isSelected;
  final BottomAppBarItem item;

  @override
  Widget build(BuildContext context) {
    // use isLeft to set padding for symmetric with centered FAB
    EdgeInsets buttonPadding = EdgeInsets.only(left: isLeft ? 35 : 30, right: isLeft ? 30 : 35);
    BorderRadius borderRadius = BorderRadius.circular(38);

    Color backgroundColor =
        context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background2;

    return Expanded(
      child: Padding(
        padding: buttonPadding,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: borderRadius,
          splashColor: backgroundColor.withAlpha(105),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: kBottomAppBarHeight - 28,
            decoration: BoxDecoration(
              color: isSelected ? backgroundColor : backgroundColor.withOpacity(0),
              borderRadius: borderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: SvgIcon(
                    item.iconData,
                    color: isSelected
                        ? (context.appTheme.isDarkTheme
                            ? context.appTheme.secondary1
                            : context.appTheme.onBackground)
                        : (context.appTheme.isDarkTheme
                            ? context.appTheme.secondary1
                            : context.appTheme.onBackground),
                  ),
                ),
                Gap.w4,
                Expanded(
                  flex: 5,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.text,
                      style: kNormalTextStyle.copyWith(
                        color: isSelected
                            ? (context.appTheme.isDarkTheme
                                ? context.appTheme.secondary1
                                : context.appTheme.onBackground)
                            : (context.appTheme.isDarkTheme
                                ? context.appTheme.secondary1
                                : context.appTheme.onBackground),
                        fontFamily: 'WixMadeforDisplay',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
