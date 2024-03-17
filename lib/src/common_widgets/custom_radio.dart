import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomRadio<T> extends StatelessWidget {
  const CustomRadio({
    super.key,
    required this.label,
    this.subLabel,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.width,
  });
  final String label;
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
        title: Text(
          label,
          style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
        ),
        subtitle: subLabel != null
            ? Text(
                subLabel!,
                style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 12),
              )
            : null,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: context.appTheme.primary,
        hoverColor: context.appTheme.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        contentPadding: const EdgeInsets.only(right: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
