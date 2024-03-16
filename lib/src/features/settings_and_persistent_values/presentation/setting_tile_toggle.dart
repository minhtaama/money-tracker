import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../utils/constants.dart';

class SettingTileToggle extends StatefulWidget {
  const SettingTileToggle({
    super.key,
    this.leading,
    required this.title,
    required this.onTap,
    required this.valuesCount,
    required this.initialValueIndex,
    this.valueLabels,
  });

  final Widget? leading;
  final String title;
  final int initialValueIndex;
  final List<String>? valueLabels;

  /// Index 0 means off
  final ValueChanged<int> onTap;

  /// First element in list represent Off
  final int valuesCount;

  @override
  State<SettingTileToggle> createState() => _SettingTileToggleState();
}

class _SettingTileToggleState extends State<SettingTileToggle> {
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialValueIndex;
    super.initState();
  }

  void toggleIndexValues() {
    if (currentIndex == widget.valuesCount - 1) {
      setState(() {
        currentIndex = 0;
      });
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      title: widget.title,
      secondaryTitle: widget.valueLabels?[currentIndex],
      trailing: _AnimatedToggle(
        currentValueIndex: currentIndex,
        valuesCount: widget.valuesCount,
      ),
      onTap: () {
        toggleIndexValues();
        widget.onTap(currentIndex);
      },
    );
  }
}

class _AnimatedToggle extends StatelessWidget {
  const _AnimatedToggle({super.key, required this.currentValueIndex, this.valuesCount = 2});

  final int currentValueIndex;

  /// Last element in list represent OFF
  final int valuesCount;

  @override
  Widget build(BuildContext context) {
    final isOn = currentValueIndex != 0;
    final bgrColor = isOn ? context.appTheme.accent1 : context.appTheme.onBackground.withOpacity(0.35);
    final togglePosition = currentValueIndex / (valuesCount - 1);
    const double widthRatio = 1.7;
    const double size = 30;
    return SizedBox(
      height: size,
      width: size * widthRatio,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: k150msDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: bgrColor,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSlide(
              duration: k150msDuration,
              offset: Offset((widthRatio - 1) * togglePosition, 0),
              child: SizedBox(
                height: size,
                width: size,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    //border: Border.all(color: bgrColor, width: 4),
                    color: context.appTheme.background1,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
