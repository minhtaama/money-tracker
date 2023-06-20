import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theming/app_theme.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker(
      {Key? key, required this.colorsList, required this.onColorTap, required this.currentColorIndex})
      : super(key: key);
  final List<AppThemeData> colorsList;
  final ValueChanged<int> onColorTap;
  final int currentColorIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      children: List.generate(colorsList.length, (index) {
        return CircleColor(
          color1: colorsList[index].accent,
          color2: colorsList[index].isDuoColor ? colorsList[index].primary : null,
          isSelected: currentColorIndex == index,
          onTap: onColorTap,
          index: index,
        );
      }),
    );
  }
}

class CircleColor extends StatelessWidget {
  const CircleColor(
      {Key? key,
      required this.color1,
      this.color2,
      required this.isSelected,
      required this.onTap,
      required this.index})
      : super(key: key);
  final int index;
  final Color color1;
  final Color? color2;
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
                gradient: color2 != null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color1, color2!],
                        stops: const [0.5, 0.5],
                      )
                    : null,
                color: color2 != null ? null : color1,
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            AnimatedOpacity(
              duration: kBottomAppBarDuration,
              opacity: isSelected ? 1 : 0,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: context.appTheme.background.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.done,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
