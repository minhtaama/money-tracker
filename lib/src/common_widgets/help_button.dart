import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../utils/constants.dart';

class HelpButton extends StatefulWidget {
  const HelpButton({
    super.key,
    required this.text,
    this.title,
    this.size = 22,
    this.yOffset = 0,
    this.iconPath,
  });

  final String? iconPath;
  final String? title;
  final String text;
  final double size;
  final double yOffset;

  @override
  State<HelpButton> createState() => _HelpButtonState();
}

class _HelpButtonState extends State<HelpButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final _buttonKey = GlobalKey();
  final _boxKey = GlobalKey();

  bool _showBoxUnderButton = false;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: k150msDuration);
    _animation = CurveTween(curve: Curves.easeOut).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    Offset buttonOffset = _getRenderObjectCenterPosition(_buttonKey, isTopCenterPoint: true);
    Size buttonSize = _buttonKey.currentContext!.size!;

    double helpBoxWidth = 0;
    double helpBoxHeight = 0;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        helpBoxHeight = _boxKey.currentContext!.size!.height;
        helpBoxWidth = _boxKey.currentContext!.size!.width;
      });
    });

    Offset helpBoxOffset() {
      double dx = buttonOffset.dx - helpBoxWidth / 2; // Makes center of help box sames as button
      double dy =
          buttonOffset.dy - helpBoxHeight - 10; // Make center of help box same as top-center of button

      if (helpBoxWidth / 2 >= Gap.screenWidth(context) - buttonOffset.dx) {
        double offset = helpBoxWidth / 2 - (Gap.screenWidth(context) - buttonOffset.dx);
        dx = dx - offset - 10;
      } else if (helpBoxWidth / 2 >= buttonOffset.dx) {
        double offset = helpBoxWidth / 2 - buttonOffset.dx;
        dx = dx + offset + 10;
      }

      if (helpBoxHeight > buttonOffset.dy) {
        dy = buttonOffset.dy + buttonSize.height + 10;
        _showBoxUnderButton = true;
      } else {
        _showBoxUnderButton = false;
      }

      return Offset(dx, dy);
    }

    // Get OverlayState of the closest instance in context
    OverlayState overlayState = Overlay.of(context);

    // Create an OverlayEntry
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(builder: (_) {
      return AnimatedBuilder(
          animation: _animation,
          builder: (_, Widget? child) {
            return BackButtonListener(
              onBackButtonPressed: () async {
                await _removeEntry(overlayEntry);
                return true;
              },
              child: Stack(children: [
                ModalBarrier(
                  onDismiss: () async => await _removeEntry(overlayEntry),
                ),
                Positioned(
                  left: buttonOffset.dx,
                  top: _showBoxUnderButton
                      ? buttonOffset.dy + buttonSize.height + 10
                      : buttonOffset.dy - 10,
                  child: Opacity(
                    opacity: _animation.value,
                    child: _Arrow(_showBoxUnderButton),
                  ),
                ),
                Positioned(
                  left: helpBoxOffset().dx,
                  top: helpBoxOffset().dy,
                  child: Opacity(
                    opacity: _animation.value,
                    child: _HelpBox(
                      key: _boxKey,
                      title: widget.title,
                      text: widget.text,
                    ),
                  ),
                ),
              ]),
            );
          });
    });

    // Insert the entry into overlay
    overlayState.insert(overlayEntry);

    _animationController.forward();
  }

  Future<void> _removeEntry(OverlayEntry entry) async {
    // Reverse the animation
    await _animationController.reverse();

    //When the animation is done, remove the entry from overlay
    entry.remove();
  }

  Offset _getRenderObjectCenterPosition(GlobalKey key, {required bool isTopCenterPoint}) {
    // Find RenderBox of the widget using globalKey
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;

    // Get the Offset position of the top-left point
    Offset topLeftPosition = renderBox.localToGlobal(Offset.zero);

    // Get Size of the RenderBox from GlobalKey
    Size? widgetSize = key.currentContext!.size;

    return isTopCenterPoint
        ? Offset(topLeftPosition.dx + widgetSize!.width / 2, topLeftPosition.dy)
        : Offset(topLeftPosition.dx + widgetSize!.width / 2, topLeftPosition.dy + widgetSize.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, widget.yOffset),
      child: RoundedIconButton(
        key: _buttonKey,
        iconPath: widget.iconPath ?? AppIcons.defaultIcon,
        iconPadding: 0,
        size: widget.size,
        iconColor: AppColors.grey(context),
        backgroundColor: Colors.transparent,
        onTap: _showOverlay,
      ),
    );
  }
}

class _HelpBox extends StatelessWidget {
  const _HelpBox({
    super.key,
    this.title,
    required this.text,
  });
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(minWidth: 30, maxWidth: Gap.screenWidth(context) - 50),
            decoration: BoxDecoration(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.accent1.withOpacity(0.7)
                  : context.appTheme.background2.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title != null
                    ? Text(
                        title!,
                        style: kHeader2TextStyle.copyWith(
                            color: context.appTheme.isDarkTheme
                                ? context.appTheme.onAccent
                                : context.appTheme.onBackground,
                            fontSize: 14),
                        textAlign: TextAlign.left,
                      )
                    : Gap.noGap,
                title != null ? Gap.h4 : Gap.noGap,
                Text(
                  text,
                  style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.isDarkTheme
                          ? context.appTheme.onAccent
                          : context.appTheme.onBackground,
                      fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow(this.showUnderButton);

  final bool showUnderButton;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: showUnderButton
          ? _UpArrowPainter(
              context.appTheme.isDarkTheme
                  ? context.appTheme.accent1.withOpacity(0.7)
                  : context.appTheme.background2.withOpacity(0.7),
            )
          : _DownArrowPainter(
              context.appTheme.isDarkTheme
                  ? context.appTheme.accent1.withOpacity(0.7)
                  : context.appTheme.background2.withOpacity(0.7),
            ),
    );
  }
}

class _DownArrowPainter extends CustomPainter {
  _DownArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1
    Paint paintFill0 = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.0
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path fillPath = Path();
    fillPath.moveTo(-6, -0.23);
    fillPath.lineTo(0, 6);
    fillPath.lineTo(6, -0.23);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _UpArrowPainter extends CustomPainter {
  _UpArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1
    Paint paintFill0 = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.0
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path fillPath = Path();
    fillPath.moveTo(-6, 0.23);
    fillPath.lineTo(0, -6);
    fillPath.lineTo(6, 0.23);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
