import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.focusColor,
    required this.onChanged,
    this.autofocus = true,
  }) : super(key: key);
  final ValueChanged<String> onChanged;
  final String hintText;
  final Color focusColor;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      cursorColor: context.appTheme.backgroundNegative.withOpacity(0.1),
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.backgroundNegative,
      ),
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
      ),
      onChanged: onChanged,
    );
  }
}
