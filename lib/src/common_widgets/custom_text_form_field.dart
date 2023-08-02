import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.focusNode,
    this.withOutlineBorder = false,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.keyboardType,
    this.prefixIcon,
  }) : super(key: key);
  final ValueChanged<String> onChanged;
  final String hintText;
  final String? helperText;
  final Color focusColor;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool withOutlineBorder;
  final AutovalidateMode autovalidateMode;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: context.appTheme.backgroundNegative.withOpacity(0.1),
      style: withOutlineBorder
          ? kHeader3TextStyle.copyWith(
              color: context.appTheme.backgroundNegative,
              fontSize: 15,
            )
          : kHeader2TextStyle.copyWith(
              color: context.appTheme.backgroundNegative,
              fontSize: 18,
            ),
      validator: validator,
      maxLines: maxLines,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
      ],
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        contentPadding: withOutlineBorder ? const EdgeInsets.all(12) : null,
        focusColor: context.appTheme.primary,
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
        enabledBorder: withOutlineBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey, width: 1),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey, width: 1),
              ),
        focusedBorder: withOutlineBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: focusColor, width: 2),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: focusColor, width: 2),
              ),
        hintText: hintText,
        hintStyle: withOutlineBorder
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
