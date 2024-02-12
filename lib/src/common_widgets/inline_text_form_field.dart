import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import 'custom_text_form_field.dart';

class InlineTextFormField extends StatelessWidget {
  const InlineTextFormField(
      {super.key,
      this.validator,
      this.onChanged,
      this.prefixText,
      this.suffixText,
      this.textSize,
      this.suffixWidget,
      this.widget,
      this.width,
      this.maxLength = 3,
      this.initialValue,
      this.hintText});
  final String? prefixText;
  final String? suffixText;
  final Widget? suffixWidget;
  final double? textSize;
  final Widget? widget;
  final double? width;
  final int? maxLength;
  final String? initialValue;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        prefixText != null
            ? Text(
                prefixText!,
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: textSize),
              )
            : Gap.noGap,
        prefixText != null ? Gap.w8 : Gap.noGap,
        widget != null
            ? Expanded(child: widget!)
            : width != null
                ? SizedBox(
                    width: width,
                    child: CustomTextFormField(
                      hintText: hintText ?? '',
                      focusColor: context.appTheme.secondary1,
                      autofocus: false,
                      disableErrorText: true,
                      maxLength: maxLength,
                      maxLines: 1,
                      initialValue: initialValue,
                      contentPadding: EdgeInsets.zero,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      validator: validator,
                      onChanged: onChanged ?? (value) {},
                    ),
                  )
                : Expanded(
                    child: CustomTextFormField(
                      hintText: hintText ?? '',
                      focusColor: context.appTheme.secondary1,
                      autofocus: false,
                      disableErrorText: true,
                      maxLength: 3,
                      initialValue: initialValue,
                      contentPadding: EdgeInsets.zero,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      validator: validator,
                      onChanged: onChanged ?? (value) {},
                    ),
                  ),
        suffixText != null ? Gap.w8 : Gap.noGap,
        suffixText != null
            ? Text(
                suffixText!,
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: textSize),
              )
            : Gap.noGap,
        suffixWidget != null ? Gap.w16 : Gap.noGap,
        suffixWidget ?? Gap.noGap,
      ],
    );
  }
}
