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
    this.autofocus = true,
  }) : super(key: key);
  final ValueChanged<String> onChanged;
  final String hintText;
  final String? helperText;
  final Color focusColor;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: context.appTheme.backgroundNegative.withOpacity(0.1),
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.backgroundNegative,
      ),
      validator: validator,
      decoration: InputDecoration(
        focusColor: context.appTheme.primary,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: focusColor, width: 2),
        ),
        hintText: hintText,
        hintStyle: kHeader2TextStyle.copyWith(
          color: context.appTheme.backgroundNegative.withOpacity(0.5),
          fontSize: 18,
        ),
        errorStyle: kHeader4TextStyle.copyWith(fontSize: 12),
        helperText: helperText ?? '',
      ),
      onChanged: onChanged,
    );
  }
}
