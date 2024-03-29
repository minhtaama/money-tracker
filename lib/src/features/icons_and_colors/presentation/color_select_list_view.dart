import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../utils/constants.dart';

class ColorSelectListView extends StatefulWidget {
  /// This class `onColorTap` returns index of `List<Color>` in [AppColors.allColorsUserCanPick]
  const ColorSelectListView({
    Key? key,
    this.size = 75,
    this.spacing = 12,
    required this.onColorTap,
    this.initialColorIndex = 0,
  }) : super(key: key);
  final ValueChanged<int> onColorTap;
  final double size;
  final double spacing;
  final int initialColorIndex;

  @override
  State<ColorSelectListView> createState() => _ColorSelectListViewState();
}

class _ColorSelectListViewState extends State<ColorSelectListView> {
  late int currentColorIndex;

  @override
  void initState() {
    currentColorIndex = widget.initialColorIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.allColorsUserCanPick.length,
        itemBuilder: (context, index) => Padding(
          padding:
              EdgeInsets.only(right: widget.spacing * 2, top: widget.spacing, bottom: widget.spacing),
          child: CircleColor(
              color: AppColors.allColorsUserCanPick[index][0],
              isSelected: currentColorIndex == index,
              size: widget.size - widget.spacing * 2,
              onTap: (index) {
                setState(() {
                  currentColorIndex = index;
                });
                widget.onColorTap(currentColorIndex);
              },
              index: index),
        ),
      ),
    );
  }
}

class CircleColor extends StatelessWidget {
  const CircleColor(
      {Key? key,
      required this.color,
      required this.isSelected,
      required this.onTap,
      required this.size,
      required this.index})
      : super(key: key);
  final int index;
  final Color color;
  final double size;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
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
                  color: context.appTheme.background1.withOpacity(0.5),
                ),
                child: Transform.scale(
                  scale: 0.7,
                  child: SvgIcon(AppIcons.done),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
