import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import 'hideable_container.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    super.key,
    required this.onChanged,
    required this.label,
    this.labelSuffix,
    this.optionalWidget,
    this.optionalWidgetBackgroundColor,
    this.checkboxBackgroundColor,
    this.labelStyle,
    this.optionalWidgetDecoration = true,
    this.showOptionalWidgetWhenValueIsFalse = false,
    this.initialValue = false,
  });

  final String label;
  final Widget? labelSuffix;
  final TextStyle? labelStyle;
  final ValueChanged<bool> onChanged;
  final Widget? optionalWidget;
  final Color? optionalWidgetBackgroundColor;
  final Color? checkboxBackgroundColor;
  final bool optionalWidgetDecoration;
  final bool showOptionalWidgetWhenValueIsFalse;
  final bool initialValue;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _value = widget.initialValue;

  late Widget? _child = _value
      ? widget.showOptionalWidgetWhenValueIsFalse
          ? Gap.noGap
          : widget.optionalWidget
      : widget.showOptionalWidgetWhenValueIsFalse
          ? widget.optionalWidget
          : Gap.noGap;

  void _modifyChild() {
    if (widget.optionalWidget == null) {
      return;
    }

    if (!_value) {
      if (widget.showOptionalWidgetWhenValueIsFalse) {
        setState(() {
          _child = widget.optionalWidget;
        });
      } else {
        Future.delayed(
            k350msDuration,
            () => setState(() {
                  _child = Gap.noGap;
                }));
      }
    } else {
      if (widget.showOptionalWidgetWhenValueIsFalse) {
        Future.delayed(
            k350msDuration,
            () => setState(() {
                  _child = Gap.noGap;
                }));
      } else {
        setState(() {
          _child = widget.optionalWidget;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: !widget.optionalWidgetDecoration
              ? const Offset(-11.0, 6.0)
              : Offset(
                  widget.optionalWidget != null ? 0.0 : -11.0,
                  widget.optionalWidget != null ? 10.0 : 0.0,
                ),
          child: AnimatedContainer(
            duration: k150msDuration,
            decoration: widget.optionalWidgetDecoration
                ? BoxDecoration(
                    color: widget.optionalWidget != null &&
                                !widget.showOptionalWidgetWhenValueIsFalse &&
                                _value ||
                            widget.showOptionalWidgetWhenValueIsFalse && !_value
                        ? (widget.checkboxBackgroundColor ?? AppColors.greyBgr(context))
                        : (widget.checkboxBackgroundColor?.withOpacity(0) ??
                            AppColors.greyBgr(context).withOpacity(0)),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  )
                : null,
            child: Padding(
              padding: widget.optionalWidget != null
                  ? EdgeInsets.only(bottom: widget.optionalWidgetDecoration ? 8.0 : 0.0, right: 12)
                  : EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    activeColor: context.appTheme.secondary1,
                    focusColor: context.appTheme.secondary1,
                    hoverColor: context.appTheme.secondary1,
                    checkColor: context.appTheme.onSecondary,
                    overlayColor:
                        MaterialStatePropertyAll<Color>(context.appTheme.secondary1.withOpacity(0.1)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: widget.optionalWidget == null
                        ? const VisualDensity(horizontal: 0, vertical: -3)
                        : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: context.appTheme.onBackground.withOpacity(0.4), width: 1.5),
                    value: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value!;
                        widget.onChanged(_value);
                      });

                      _modifyChild();
                    },
                  ),
                  Flexible(
                    child: Transform.translate(
                      offset: Offset(0, widget.optionalWidget != null ? 9 : 3),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _value = !_value;
                            widget.onChanged(_value);
                          });

                          _modifyChild();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.label,
                                style: widget.labelStyle ??
                                    kHeader3TextStyle.copyWith(
                                        fontSize: 15,
                                        color: context.appTheme.onBackground.withOpacity(0.6)),
                              ),
                            ),
                            Gap.w8,
                            widget.labelSuffix ?? Gap.noGap
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _child != null
            ? AnimatedContainer(
                duration: k150msDuration,
                width: double.infinity,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: widget.optionalWidgetBackgroundColor ?? context.appTheme.background0,
                  border: widget.optionalWidgetDecoration
                      ? Border.all(
                          color: context.appTheme.onBackground.withOpacity(
                            !widget.showOptionalWidgetWhenValueIsFalse && !_value ||
                                    widget.showOptionalWidgetWhenValueIsFalse && _value
                                ? 0
                                : 0.3,
                          ),
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HideableContainer(
                  hide: !widget.showOptionalWidgetWhenValueIsFalse && !_value,
                  child: Column(
                    children: [
                      !widget.optionalWidgetDecoration &&
                              (widget.showOptionalWidgetWhenValueIsFalse && !_value ||
                                  !widget.showOptionalWidgetWhenValueIsFalse && _value)
                          ? Gap.divider(context)
                          : Gap.noGap,
                      _child!,
                    ],
                  ),
                ),
              )
            : Gap.noGap,
      ],
    );
  }
}
