import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'custom_navigation_rail.dart';

class NavigationRailButton extends StatelessWidget {
  const NavigationRailButton({
    super.key,
    required this.index,
    required this.onTap,
    required this.item,
    required this.isSelected,
  });

  final int index;
  final ValueChanged<int> onTap;
  final bool isSelected;
  final NavigationRailItem item;

  @override
  Widget build(BuildContext context) {
    // use isLeft to set padding for symmetric with centered FAB
    EdgeInsets buttonPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8);
    BorderRadius borderRadius = BorderRadius.circular(16);

    Color backgroundColor = context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background2;

    return Padding(
      padding: buttonPadding,
      child: SizedBox(
        width: 60,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onTap(index),
            borderRadius: borderRadius,
            splashColor: backgroundColor.withAlpha(105),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: k150msDuration,
              padding: const EdgeInsets.all(6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSelected ? backgroundColor : backgroundColor.withOpacity(0),
                borderRadius: borderRadius,
              ),
              child: Column(
                children: [
                  SvgIcon(
                    item.iconData,
                    size: 27,
                    color: isSelected
                        ? (context.appTheme.isDarkTheme ? context.appTheme.secondary1 : context.appTheme.onBackground)
                        : (context.appTheme.isDarkTheme ? context.appTheme.secondary1 : context.appTheme.onBackground),
                  ),
                  HideableContainer(
                    hide: !isSelected,
                    child: Center(
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
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
