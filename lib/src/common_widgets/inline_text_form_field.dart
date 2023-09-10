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
      this.widget,
      this.width = 50,
      this.initialValue});
  final String? prefixText;
  final String? suffixText;
  final Widget? widget;
  final double? width;
  final String? initialValue;
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
                style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
              )
            : Gap.noGap,
        prefixText != null ? Gap.w8 : Gap.noGap,
        widget != null
            ? Expanded(child: widget!)
            : width != null
                ? SizedBox(
                    width: width,
                    child: CustomTextFormField(
                      hintText: '',
                      focusColor: context.appTheme.secondary,
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
                  )
                : Expanded(
                    child: CustomTextFormField(
                      hintText: '',
                      focusColor: context.appTheme.secondary,
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
                style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
              )
            : Gap.noGap,
      ],
    );
  }
}
