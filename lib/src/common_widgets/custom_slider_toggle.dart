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
      {super.key,
      this.toggleColor,
      required this.values,
      required this.labels,
      this.height = 45,
      this.fontSize,
      this.initialValueIndex = 0,
      required this.onTap,
      this.labelsOnToggleColor,
      this.labelsOnBackgroundColor});
  final Color? toggleColor;
  final Color? labelsOnToggleColor;
  final Color? labelsOnBackgroundColor;
  final int initialValueIndex;
  final List<T> values;
  final List<String> labels;
  final double height;
  final ValueChanged<T> onTap;
  final double? fontSize;

  @override
  State<CustomSliderToggle<T>> createState() => _CustomSliderToggleState<T>();
}

class _CustomSliderToggleState<T> extends State<CustomSliderToggle<T>> {
  final _rootSizedBoxKey = GlobalKey();
  double _rootSizedBoxWidth = 0;
  late int currentValueIndex;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _rootSizedBoxWidth = _rootSizedBoxKey.currentContext!.size!.width;
      setState(() {});
    });
    currentValueIndex = widget.initialValueIndex;
  }

  @override
  Widget build(BuildContext context) {
    double togglePosition = currentValueIndex / (widget.values.length - 1);
    return SizedBox(
      key: _rootSizedBoxKey,
      height: widget.height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.greyBgr(context),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSlide(
              duration: k150msDuration,
              curve: Curves.fastOutSlowIn,
              offset: Offset(togglePosition, 0),
              child: SizedBox(
                height: widget.height,
                width: _rootSizedBoxWidth / widget.values.length,
                child: CardItem(
                  margin: EdgeInsets.zero,
                  elevation: 1.5,
                  isGradient: true,
                  borderRadius: BorderRadius.circular(100),
                  color: widget.toggleColor ?? context.appTheme.accent1,
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(
                widget.values.length,
                (index) => Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            currentValueIndex = index;
                            widget.onTap(widget.values[currentValueIndex]);
                          });
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: k150msDuration,
                            curve: Curves.fastOutSlowIn,
                            style: kHeader2TextStyle.copyWith(
                              fontSize: widget.fontSize ?? 16,
                              fontFamily: 'WixMadeforDisplay',
                              color: currentValueIndex == index
                                  ? widget.labelsOnToggleColor ?? context.appTheme.onAccent
                                  : widget.labelsOnBackgroundColor ?? context.appTheme.onBackground,
                            ),
                            child: Text(widget.labels[index]),
                          ),
                        ),
                      ),
                    )),
          )
        ],
      ),
    );
  }
}
