import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox(
      {super.key,
      required this.onChanged,
      required this.label,
      this.optionalWidget,
      this.optionalWidgetBackgroundColor,
      this.checkboxBackgroundColor});

  final String label;
  final ValueChanged<bool> onChanged;
  final Widget? optionalWidget;
  final Color? optionalWidgetBackgroundColor;
  final Color? checkboxBackgroundColor;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0.0, 10.0),
          child: AnimatedContainer(
            duration: k150msDuration,
            decoration: BoxDecoration(
              color: widget.checkboxBackgroundColor ?? (_value ? AppColors.grey : Colors.transparent),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    activeColor: context.appTheme.secondary,
                    focusColor: context.appTheme.secondary,
                    hoverColor: context.appTheme.secondary,
                    checkColor: context.appTheme.secondaryNegative,
                    overlayColor: MaterialStatePropertyAll<Color>(context.appTheme.secondary.withOpacity(0.1)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: BorderSide(color: context.appTheme.secondary.withOpacity(0.4), width: 1.5),
                    value: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value!;
                        widget.onChanged(_value);
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _value = !_value;
                        widget.onChanged(_value);
                      });
                    },
                    child: Text(
                      widget.label,
                      style: kHeader3TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: k150msDuration,
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: _value ? const EdgeInsets.all(16) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.optionalWidgetBackgroundColor ??
                (context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background),
            border: Border.all(
              color: context.appTheme.backgroundNegative.withOpacity(_value ? 0.3 : 0),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedSize(
            duration: k150msDuration,
            child: _value ? widget.optionalWidget ?? Gap.noGap : Gap.noGap,
          ),
        ),
      ],
    );
  }
}
