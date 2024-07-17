import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/card_item.dart';

class HomescreenTypeSelector extends StatelessWidget {
  const HomescreenTypeSelector({
    super.key,
    required this.onTypeTap,
    required this.currentType,
  });
  final HomescreenType currentType;
  final ValueChanged<HomescreenType> onTypeTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Homescreen type'.hardcoded,
            style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 15),
          ),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _TypeSelector(
                  svgPath: AppIcons.scrollableSheetLarge,
                  type: HomescreenType.scrollableSheet,
                  onTap: onTypeTap,
                ),
              ),
              Gap.w12,
              Expanded(
                child: _TypeSelector(
                  svgPath: AppIcons.pageViewLarge,
                  type: HomescreenType.pageView,
                  onTap: onTypeTap,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    super.key,
    required this.svgPath,
    required this.type,
    required this.onTap,
  });

  final String svgPath;
  final HomescreenType type;
  final ValueSetter<HomescreenType> onTap;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: context.appTheme.primary.withOpacity(context.appSettings.homescreenType == type ? 0.15 : 0),
      // border: Border.all(
      //   color: context.appTheme.primary.withOpacity(context.appSettings.homescreenType == type ? 0.5 : 0),
      // ),
      onTap: () => onTap(type),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.8,
            child: SvgIcon(
              svgPath,
              size: 150,
              height: 110,
              color: context.appTheme.primary.withOpacity(1),
            ),
          ),
          CardItem(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: context.appTheme.onBackground,
            ),
            child: CardItem(
              margin: const EdgeInsets.all(2),
              color: context.appTheme.primary.withOpacity(context.appSettings.homescreenType == type ? 1 : 0),
              height: 10,
              width: 10,
            ),
          )
        ],
      ),
    );
  }
}
