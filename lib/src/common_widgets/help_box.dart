import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class HelpBox extends StatefulWidget {
  const HelpBox({
    super.key,
    this.bottomWidget,
    this.constraints,
    this.backgroundColor,
    this.color,
    this.margin,
    required this.iconPath,
    required this.header,
    required this.isShow,
    this.text,
    this.onCloseTap,
  });

  final bool isShow;
  final Widget? bottomWidget;
  final Color? backgroundColor;
  final Color? color;
  final String iconPath;
  final String header;
  final String? text;
  final EdgeInsets? margin;
  final BoxConstraints? constraints;
  final VoidCallback? onCloseTap;

  @override
  State<HelpBox> createState() => _HelpBoxState();
}

class _HelpBoxState extends State<HelpBox> {
  late bool _isShow = widget.isShow;

  @override
  void didUpdateWidget(covariant HelpBox oldWidget) {
    setState(() {
      _isShow = widget.isShow;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return HideableContainer(
      hide: !_isShow,
      child: AnimatedContainer(
        duration: k250msDuration,
        curve: Curves.fastOutSlowIn,
        width: double.infinity,
        margin: _isShow ? widget.margin : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? context.appTheme.negative,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: widget.constraints ?? const BoxConstraints.tightForFinite(),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  children: [
                    const Spacer(),
                    RoundedIconButton(
                      iconPath: AppIcons.close,
                      iconColor: widget.color ?? context.appTheme.onNegative,
                      backgroundColor: Colors.transparent,
                      size: 35,
                      iconPadding: 9,
                      onTap: () {
                        setState(() {
                          _isShow = !_isShow;
                        });
                        widget.onCloseTap?.call();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Gap.h16,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconWithText(
                        header: widget.header,
                        text: widget.text,
                        iconPath: widget.iconPath,
                        color: widget.color ?? context.appTheme.onNegative,
                      ),
                    ),
                    widget.bottomWidget ?? Gap.noGap,
                    Gap.h16,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
