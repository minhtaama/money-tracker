import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class CustomSliderToggle<T> extends StatefulWidget {
  /// This widget takes `values` argument and a generic type T,
  /// which contains the values that can be returned by `onTap` function
  /// The `labels` argument list must has the same length with the `values`,
  /// which display the name of each value.
  const CustomSliderToggle(
      {Key? key,
      this.toggleColor,
      required this.values,
      required this.labels,
      this.height = 45,
      required this.onTap,
      this.labelsOnToggleColor,
      this.labelsOnBackgroundColor})
      : super(key: key);
  final Color? toggleColor;
  final Color? labelsOnToggleColor;
  final Color? labelsOnBackgroundColor;
  final List<T> values;
  final List<String> labels;
  final double height;
  final ValueChanged<T> onTap;

  @override
  State<CustomSliderToggle<T>> createState() => _CustomSliderToggleState<T>();
}

class _CustomSliderToggleState<T> extends State<CustomSliderToggle<T>> {
  final _rootSizedBoxKey = GlobalKey();
  double _rootSizedBoxWidth = 0;
  int currentValueIndex = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _rootSizedBoxWidth = _rootSizedBoxKey.currentContext!.size!.width;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double togglePosition = currentValueIndex / (widget.values.length - 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              key: _rootSizedBoxKey,
              height: widget.height,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.grey,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSlide(
                      duration: kBottomAppBarDuration,
                      curve: Curves.easeOut,
                      offset: Offset(togglePosition, 0),
                      child: SizedBox(
                        height: widget.height,
                        width: _rootSizedBoxWidth / widget.values.length,
                        child: CardItem(
                          margin: EdgeInsets.zero,
                          elevation: 1.5,
                          isGradient: true,
                          borderRadius: BorderRadius.circular(100),
                          color: widget.toggleColor ?? context.appTheme.accent,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                        widget.values.length,
                        (index) => Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentValueIndex = index;
                                    widget.onTap(widget.values[currentValueIndex]);
                                  });
                                },
                                child: SizedBox(
                                  height: widget.height,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        widget.labels[index],
                                        style: kHeader2TextStyle.copyWith(
                                          color: currentValueIndex == index
                                              ? widget.labelsOnToggleColor ??
                                                  context.appTheme.accentNegative
                                              : widget.labelsOnBackgroundColor ??
                                                  context.appTheme.backgroundNegative,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
