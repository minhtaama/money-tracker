import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../utils/constants.dart';

class SettingTileToggle extends StatefulWidget {
  const SettingTileToggle({
    Key? key,
    this.leading,
    required this.title,
    required this.onTap,
    required this.valuesCount,
    required this.initialValueIndex,
    this.valueLabels,
  }) : super(key: key);

  final Widget? leading;
  final String title;
  final int initialValueIndex;
  final List<String>? valueLabels;
  final ValueChanged<int> onTap;

  /// Last element in list represent Off
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
    return CustomInkWell(
      onTap: () {
        toggleIndexValues();
        widget.onTap(currentIndex);
      },
      inkColor: context.appTheme.backgroundNegative,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            widget.leading ?? const SizedBox(),
            Expanded(
              child: widget.valueLabels != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: kHeader2TextStyle.copyWith(
                            color: context.appTheme.backgroundNegative,
                          ),
                        ),
                        Text(
                          widget.valueLabels![currentIndex],
                          style: kHeader4TextStyle.copyWith(
                            color: context.appTheme.backgroundNegative,
                          ),
                        )
                      ],
                    )
                  : Text(
                      widget.title,
                      style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative,
                      ),
                    ),
            ),
            AnimatedToggle(
              currentValueIndex: currentIndex,
              valuesCount: widget.valuesCount,
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedToggle extends StatelessWidget {
  const AnimatedToggle({Key? key, required this.currentValueIndex, this.valuesCount = 2})
      : super(key: key);

  final int currentValueIndex;

  /// Last element in list represent OFF
  final int valuesCount;

  @override
  Widget build(BuildContext context) {
    final isOn = currentValueIndex != 0;
    final bgrColor = isOn ? context.appTheme.accent : Colors.grey;
    final togglePosition = currentValueIndex / (valuesCount - 1);
    const double widthRatio = 1.7;
    const double size = 30;
    return SizedBox(
      height: size,
      width: size * widthRatio,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: kBottomAppBarDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: bgrColor,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSlide(
              duration: kBottomAppBarDuration,
              offset: Offset((widthRatio - 1) * togglePosition, 0),
              child: SizedBox(
                height: size,
                width: size,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    //border: Border.all(color: bgrColor, width: 4),
                    color: context.appTheme.background,
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