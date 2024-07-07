import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class CustomSliderToggle<T> extends StatefulWidget {
  /// This widget takes `values` argument and a generic type T,
  /// which contains the values that can be returned by `onTap` function
  /// The `labels` argument list must has the same length with the `values`,
  /// which display the name of each value.
  const CustomSliderToggle({
    super.key,
    this.toggleColor,
    required this.values,
    required this.iconPaths,
    required this.labels,
    this.height = 45,
    this.fontSize,
    this.initialValueIndex = 0,
    required this.onTap,
    this.onToggleColor,
    this.onBackgroundColor,
  });

  final Color? toggleColor;
  final Color? onToggleColor;
  final Color? onBackgroundColor;
  final int initialValueIndex;
  final List<T> values;
  final List<String> labels;
  final List<String> iconPaths;
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
      setState(() {
        _rootSizedBoxWidth = _rootSizedBoxKey.currentContext!.size!.width;
      });
    });
    currentValueIndex = widget.initialValueIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _rootSizedBoxWidth = _rootSizedBoxKey.currentContext!.size!.width;
          });
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox(
          key: _rootSizedBoxKey,
          height: widget.height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.appTheme.onBackground.withOpacity(0.065),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSlide(
                  duration: k150msDuration,
                  curve: Curves.fastOutSlowIn,
                  offset: Offset(currentValueIndex.toDouble(), 0),
                  child: SizedBox(
                    height: widget.height,
                    width: _rootSizedBoxWidth / widget.values.length,
                    child: CardItem(
                      margin: EdgeInsets.zero,
                      elevation: 1.5,
                      isGradient: true,
                      borderRadius: BorderRadius.circular(7),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgIcon(
                                  widget.iconPaths[index],
                                  color: currentValueIndex == index
                                      ? widget.onToggleColor ?? context.appTheme.onAccent
                                      : widget.onBackgroundColor ?? context.appTheme.onBackground,
                                  size: 20,
                                ),
                                HideableContainer(
                                  hide: currentValueIndex != index,
                                  axis: Axis.horizontal,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        widget.labels[index],
                                        style: kHeader3TextStyle.copyWith(
                                          fontSize: widget.fontSize ?? 14,
                                          color: currentValueIndex == index
                                              ? widget.onToggleColor ?? context.appTheme.onAccent
                                              : widget.onBackgroundColor ?? context.appTheme.onBackground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
