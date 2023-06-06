import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'bottom_app_bar_with_fab.dart';

class BottomAppBarButton extends StatelessWidget {
  const BottomAppBarButton({
    Key? key,
    required this.index,
    required this.onTap,
    required this.item,
    required this.backgroundColor,
    required this.isLeft,
    required this.isSelected,
  }) : super(key: key);

  final int index;
  final ValueChanged<int> onTap;
  final bool isLeft;
  final Color backgroundColor;
  final bool isSelected;
  final BottomAppBarItem item;

  @override
  Widget build(BuildContext context) {
    // use isLeft to set padding for symmetric with centered FAB
    EdgeInsets buttonPadding = EdgeInsets.only(left: isLeft ? 35 : 30, right: isLeft ? 30 : 35);
    BorderRadius borderRadius = BorderRadius.circular(38);

    return Expanded(
      child: Padding(
        padding: buttonPadding,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: borderRadius,
          splashColor: backgroundColor.withAlpha(105),
          highlightColor: backgroundColor.withAlpha(105),
          child: CardItem(
            color: isSelected ? backgroundColor : Colors.transparent,
            borderRadius: borderRadius,
            margin: EdgeInsets.zero,
            isGradient: isSelected ? true : false,
            elevation: isSelected ? 1 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.iconData,
                  color: isSelected ? context.appTheme.primaryNegative : backgroundColor,
                ), //TODO: Implement Hive icon
                Gap.w8,
                Expanded(
                  child: FittedBox(
                    child: Text(
                      item.text,
                      style: kHeader4TextStyle.copyWith(
                        color: isSelected ? context.appTheme.primaryNegative : backgroundColor,
                        fontFamily: 'WixMadeforDisplay',
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
