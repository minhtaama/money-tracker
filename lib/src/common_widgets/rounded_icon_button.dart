import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
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
    this.iconPadding = 12,
    this.onTap,
    this.onLongPress,
    this.iconColor,
    this.inkColor,
    this.elevation = 0,
    this.reactImmediately = true,
  });

  final String iconPath;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? inkColor;
  final double? size;
  final double? labelSize;
  final double iconPadding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final bool reactImmediately;

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
      );

  @override
  Widget build(BuildContext context) {
    return label != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (size ?? 20) * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                roundedButton(context),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    label!,
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: labelSize ?? (size != null ? size! / 4 : 20),
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
  const _RoundedButton(
      {super.key,
      required this.iconPath,
      required this.backgroundColor,
      required this.iconColor,
      required this.inkColor,
      required this.iconPadding,
      required this.onTap,
      required this.onLongPress,
      required this.elevation,
      required this.reactImmediately});

  final String iconPath;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? inkColor;
  final double iconPadding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final bool reactImmediately;

  @override
  State<_RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<_RoundedButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null && widget.onLongPress == null
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
              setState(() {
                _scale = 0.8;
              });
              if (widget.reactImmediately) {
                Future.delayed(k100msDuration, () {
                  setState(() {
                    _scale = 1.0;
                  });
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
      child: AnimatedScale(
        scale: _scale,
        duration: k100msDuration,
        curve: Curves.fastOutSlowIn,
        child: CardItem(
          duration: k100msDuration,
          curve: Curves.fastOutSlowIn,
          color: widget.backgroundColor ?? context.appTheme.background0,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(1000),
          elevation: _scale < 1.0 ? 0 : widget.elevation,
          isGradient: false,
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
    );
  }
}
