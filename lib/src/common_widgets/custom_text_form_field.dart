import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    required this.hintText,
    required this.focusColor,
    required this.onChanged,
    this.helperText,
    this.validator,
    this.onFieldSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autofocus = true,
    this.isMultiLine = false,
  }) : super(key: key);
  final ValueChanged<String> onChanged;
  final String hintText;
  final String? helperText;
  final Color focusColor;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool isMultiLine;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: context.appTheme.backgroundNegative.withOpacity(0.1),
      style: isMultiLine
          ? kHeader3TextStyle.copyWith(
              color: context.appTheme.backgroundNegative,
              fontSize: 15,
            )
          : kHeader2TextStyle.copyWith(
              color: context.appTheme.backgroundNegative,
              fontSize: 18,
            ),
      validator: validator,
      maxLines: isMultiLine ? 3 : 1,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        contentPadding: isMultiLine ? const EdgeInsets.all(12) : null,
        focusColor: context.appTheme.primary,
        enabledBorder: isMultiLine
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey, width: 1),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey, width: 1),
              ),
        focusedBorder: isMultiLine
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: focusColor, width: 2),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: focusColor, width: 2),
              ),
        hintText: hintText,
        hintStyle: isMultiLine
            ? kHeader3TextStyle.copyWith(
                color: context.appTheme.backgroundNegative.withOpacity(0.5),
                fontSize: 18,
              )
            : kHeader2TextStyle.copyWith(
                color: context.appTheme.backgroundNegative.withOpacity(0.5),
                fontSize: 18,
              ),
        errorStyle: kHeader4TextStyle.copyWith(fontSize: 12),
        helperText: helperText,
      ),
      onChanged: onChanged,
    );
  }
}
