import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomRadio<T> extends StatelessWidget {
  const CustomRadio({
    super.key,
    this.label,
    this.labelWidget,
    this.subLabel,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.width,
  }) : assert(label != null || labelWidget != null);

  final String? label;
  final Widget? labelWidget;
  final String? subLabel;
  final T value;
  final T groupValue;
  final void Function(T?)? onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: RadioListTile(
        title: label != null
            ? Text(
                label!,
                style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
              )
            : labelWidget!,
        subtitle: subLabel != null
            ? Text(
                subLabel!,
                style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 12),
              )
            : null,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        hoverColor: context.appTheme.primary,
        overlayColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed)) {
              return context.appTheme.primary.withOpacity(0.25);
            }

            return null;
          },
        ),
        fillColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return context.appTheme.primary;
            }
            return context.appTheme.onBackground.withOpacity(0.65);
          },
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        contentPadding: const EdgeInsets.only(right: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
