import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.focusColor,
    required this.onChanged,
    this.controller,
    this.helperText,
    this.validator,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autofocus = true,
    this.enabled = true,
    this.focusNode,
    this.withOutlineBorder = false,
    this.disableErrorText = false,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onTapOutside,
    this.contentPadding,
    this.textAlign = TextAlign.start,
    this.initialValue,
    this.style,
  });
  final String hintText;
  final String? helperText;
  final TextEditingController? controller;
  final Color focusColor;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String> onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTapOutside;
  final bool withOutlineBorder;
  final bool disableErrorText;
  final AutovalidateMode autovalidateMode;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? contentPadding;
  final TextAlign textAlign;
  final String? initialValue;
  final TextStyle? style;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();

  @override
  void initState() {
    if (widget.initialValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _controller.text = widget.initialValue!;
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    if (widget.initialValue != null && widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _controller.text = widget.initialValue!;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: TextFormField(
        controller: _controller,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        textAlign: widget.textAlign,
        autovalidateMode: widget.autovalidateMode,
        onFieldSubmitted: widget.onFieldSubmitted,
        cursorColor: context.appTheme.onBackground.withOpacity(0.1),
        style: widget.style ??
            (widget.withOutlineBorder
                ? kHeader3TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 15,
                  )
                : kHeader2TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 18,
                  )),
        validator: widget.validator,
        maxLines: widget.maxLines,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
          widget.onTapOutside?.call();
        },
        onEditingComplete: () {
          widget.onEditingComplete?.call();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(
          contentPadding:
              widget.contentPadding ?? (widget.withOutlineBorder ? const EdgeInsets.all(12) : null),
          isDense: widget.contentPadding != null ? true : null,
          focusColor: context.appTheme.primary,
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          suffixIcon: widget.suffixIcon,
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
          focusedErrorBorder: widget.withOutlineBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: widget.focusColor, width: 2),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.focusColor, width: 2),
                ),
          errorBorder: widget.withOutlineBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: context.appTheme.negative, width: 1),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(color: context.appTheme.negative, width: 1),
                ),
          enabledBorder: widget.withOutlineBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: context.appTheme.onBackground.withOpacity(widget.enabled ? 0.4 : 0.2),
                      width: 1),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: context.appTheme.onBackground.withOpacity(widget.enabled ? 0.4 : 0.2),
                      width: 1),
                ),
          focusedBorder: widget.withOutlineBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: widget.focusColor, width: 2),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.focusColor, width: 2),
                ),
          hintText: widget.hintText,
          hintStyle: widget.style?.copyWith(
                color: widget.style?.color?.withOpacity(0.5),
              ) ??
              (widget.withOutlineBorder
                  ? kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(widget.enabled ? 0.5 : 0.2),
                      fontSize: 15,
                    )
                  : kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.5),
                      fontSize: 18,
                    )),
          errorStyle: widget.disableErrorText
              ? const TextStyle(height: 0.1, color: Colors.transparent, fontSize: 0)
              : kNormalTextStyle.copyWith(fontSize: 12, color: context.appTheme.negative),
          helperText: widget.helperText,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
