import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    super.key,
    required this.iconPath,
    this.label,
    this.labelSize,
    this.backgroundColor,
    this.size,
    this.withBorder = false,
    this.borderColor,
    this.borderWidth = 1.5,
    this.iconPadding = 12,
    this.onTap,
    this.onLongPress,
    this.iconColor,
    this.inkColor,
    this.elevation = 0,
    this.reactImmediately = true,
    this.noAnimation = false,
    this.useContainerInsteadOfInk = false,
  });

  final String iconPath;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? inkColor;
  final double? size;
  final bool withBorder;
  final Color? borderColor;
  final double borderWidth;
  final double? labelSize;
  final double iconPadding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final bool reactImmediately;
  final bool noAnimation;
  final bool useContainerInsteadOfInk;

  Widget roundedButton(BuildContext context) => _RoundedButton(
        iconPath: iconPath,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        inkColor: inkColor,
        iconPadding: iconPadding,
        onTap: onTap,
        onLongPress: onLongPress,
        elevation: elevation,
        reactImmediately: reactImmediately,
        borderColor: borderColor,
        withBorder: withBorder,
        borderWidth: borderWidth,
        noAnimation: noAnimation,
        useContainerInsteadOfInk: useContainerInsteadOfInk,
      );

  @override
  Widget build(BuildContext context) {
    return label != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (size ?? 48) * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: size ?? 48,
                  height: size ?? 48,
                  child: roundedButton(context),
                ),
                Gap.h4,
                Material(
                  color: Colors.transparent,
                  child: Text(
                    label!,
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: labelSize ?? (size != null ? size! / 4 : 48 / 4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          )
        : SizedBox(
            width: size ?? 48,
            height: size ?? 48,
            child: roundedButton(context),
          );
  }
}

class _RoundedButton extends StatefulWidget {
  const _RoundedButton({
    super.key,
    required this.withBorder,
    this.borderColor,
    this.useContainerInsteadOfInk = false,
    required this.borderWidth,
    required this.iconPath,
    required this.backgroundColor,
    required this.iconColor,
    required this.inkColor,
    required this.iconPadding,
    required this.onTap,
    required this.onLongPress,
    required this.elevation,
    required this.reactImmediately,
    required this.noAnimation,
  });

  final bool withBorder;
  final Color? borderColor;
  final double borderWidth;
  final String iconPath;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? inkColor;
  final double iconPadding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final bool reactImmediately;
  final bool noAnimation;
  final bool useContainerInsteadOfInk;

  @override
  State<_RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<_RoundedButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: k100msDuration,
      curve: Curves.fastOutSlowIn,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? context.appTheme.background0,
          borderRadius: BorderRadius.circular(1000),
          border: widget.withBorder
              ? Border.all(
                  color: widget.borderColor ?? widget.iconColor ?? context.appTheme.onBackground,
                  width: widget.borderWidth)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(1000),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            highlightColor: widget.iconColor?.withOpacity(0.2),
            splashColor: widget.iconColor?.withOpacity(0.2),
            // highlightColor: widget.iconColor?.withOpacity(
            //   widget.backgroundColor == Colors.transparent || widget.backgroundColor?.opacity == 0 ? 0.2 : 0.0,
            // ),
            onTapDown: widget.onTap == null && widget.onLongPress == null || widget.noAnimation
                ? null
                : (_) => setState(() {
                      _scale = 0.8;
                    }),
            onTapUp: (_) => setState(() {
              _scale = 1.0;
            }),
            onTapCancel: () => setState(() {
              _scale = 1.0;
            }),
            onTap: widget.onTap == null && widget.onLongPress == null
                ? null
                : () async {
                    if (!widget.noAnimation) {
                      setState(() {
                        _scale = 0.8;
                      });
                    }
                    if (widget.reactImmediately) {
                      Future.delayed(k100msDuration, () {
                        if (mounted) {
                          setState(() {
                            _scale = 1.0;
                          });
                        }
                      });
                      widget.onTap?.call();
                    } else {
                      await Future.delayed(k100msDuration, () {
                        setState(() {
                          _scale = 1.0;
                        });
                      });
                      await Future.delayed(k100msDuration, () {
                        widget.onTap?.call();
                      });
                    }
                  },
            onLongPress: widget.onLongPress,
            child: Padding(
              padding: EdgeInsets.all(widget.iconPadding),
              child: FittedBox(
                child: SvgIcon(
                  widget.iconPath,
                  color: widget.iconColor ?? context.appTheme.onBackground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
