import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../application/app_settings.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker(
      {super.key,
      required this.colorsList,
      required this.onColorTap,
      required this.currentColorIndex,
      required this.currentThemeType});
  final ThemeType currentThemeType;
  final List<Map<ThemeType, AppThemeData>> colorsList;
  final ValueChanged<int> onColorTap;
  final int currentColorIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 15,
        children: List.generate(colorsList.length, (index) {
          return CircleColor(
            color: colorsList[index][currentThemeType]!.accent1,
            isSelected: currentColorIndex == index,
            onTap: onColorTap,
            index: index,
          );
        }),
      ),
    );
  }
}

class CircleColor extends StatelessWidget {
  const CircleColor(
      {super.key, required this.color, required this.isSelected, required this.onTap, required this.index});
  final int index;
  final Color color;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: 45,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            AnimatedOpacity(
              duration: k150msDuration,
              opacity: isSelected ? 1 : 0,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Icon(
                  Icons.done,
                  size: 30,
                  color: context.appTheme.onAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
