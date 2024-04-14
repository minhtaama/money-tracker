import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_navigation_rail_shell.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theme_and_ui/icons.dart';
import '../../rounded_icon_button.dart';
import 'dart:math' as math;

class FABItem {
  FABItem({required this.icon, required this.label, this.backgroundColor, this.color, required this.onTap});

  final String icon;
  final String label;
  final Color? backgroundColor;
  final Color? color;
  final VoidCallback onTap;
}

// https://blog.logrocket.com/complete-guide-implementing-overlays-flutter/#example-2-a-floatingactionbutton-showing-three-other-buttons
// Create a custom FloatingActionButton that expands more buttons when tapped
class CustomFloatingActionButton extends StatefulWidget {
  const CustomFloatingActionButton({
    super.key,
    required this.roundedButtonItems,
    this.listItems,
    this.mainItem,
    this.color,
    this.iconColor,
  }) : assert(roundedButtonItems.length == 3);
  final List<FABItem> roundedButtonItems;
  final List<FABItem>? listItems;
  final FABItem? mainItem;
  final Color? color;
  final Color? iconColor;

  @override
  State<CustomFloatingActionButton> createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _animation;

  OverlayEntry? _overlayEntry;

  Size _fabSize = Size.zero;

  // GlobalKey is assigned to FloatingActionButton to get the RenderBox object
  // of the returned FloatingActionButton.
  final _buttonKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: k250msDuration,
      reverseDuration: k150msDuration,
    );
    _animation = CurveTween(curve: Curves.easeOut).animate(_animationController);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _fabSize = _buttonKey.currentContext!.size!;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _fabSize = _buttonKey.currentContext!.size!;
      });
      Future.delayed(k150msDuration, () => _overlayEntry?.markNeedsBuild());
    });
    super.didChangeMetrics();
  }

  void _showOverlay() {
    // Get OverlayState of the closest instance in context
    OverlayState overlayState = Overlay.of(navigationRailKey.currentContext!, rootOverlay: true);

    _overlayEntry = OverlayEntry(builder: buildOverlay);

    if (_overlayEntry != null) {
      // Insert the entry into overlay
      overlayState.insert(_overlayEntry!);

      // Play the animation of widgets in the entry
      _animationController.forward();
    }
  }

  Future<void> _removeEntry() async {
    // Reverse the animation
    await _animationController.reverse();

    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  Offset _getFabPosition({required bool isTopCenterPoint}) {
    // Find RenderBox of the widget using globalKey
    RenderBox renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox;

    //final ancestorRenderBox = navigationRailChildKey.currentContext?.findRenderObject();

    // Get the Offset position of the top-left point
    Offset topLeftPosition = renderBox.localToGlobal(Offset.zero);

    return isTopCenterPoint
        ? Offset(topLeftPosition.dx + _fabSize.width / 2, topLeftPosition.dy)
        : Offset(topLeftPosition.dx + _fabSize.width / 2, topLeftPosition.dy + _fabSize.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    GoRouterState.of(context).uri.toString();

    return FloatingActionButton(
      key: _buttonKey,
      onPressed: null,
      shape: const CircleBorder(),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: RoundedIconButton(
        iconPath: AppIcons.add,
        iconColor: widget.iconColor ?? context.appTheme.onAccent,
        backgroundColor: widget.color ?? context.appTheme.accent2,
        size: double.infinity,
        onTap: _showOverlay,
        elevation: 10,
      ),
    );
  }

  Widget buildOverlay(BuildContext builderContext) {
    double overlayBoxWidth = (Gap.screenWidth(context) / 1.2).clamp(0, 400);
    Offset fabPosition = _getFabPosition(isTopCenterPoint: false);

    List<Widget> buttonWidgets = List.generate(
      widget.roundedButtonItems.length,
      (index) {
        if (builderContext.isBigScreen) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.roundedButtonItems[index].label,
                  style: kHeader4TextStyle.copyWith(color: builderContext.appTheme.onBackground),
                ),
                Gap.w16,
                RoundedIconButton(
                  onTap: () async {
                    await _removeEntry();
                    widget.roundedButtonItems[index].onTap();
                  },
                  iconPath: widget.roundedButtonItems[index].icon,
                  iconColor: builderContext.appTheme.onBackground,
                  label: null,
                  backgroundColor: widget.roundedButtonItems[index].backgroundColor!.withOpacity(0.7),
                  useContainerInsteadOfInk: true,
                  size: 55,
                ),
              ],
            ),
          );
        }
        return SizedBox(
          width: overlayBoxWidth / 3,
          child: Column(
            //This is how the overlay buttons is aligned.
            mainAxisAlignment: index == 0 || index == 2 ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              RoundedIconButton(
                onTap: () async {
                  await _removeEntry();
                  widget.roundedButtonItems[index].onTap();
                },
                iconPath: widget.roundedButtonItems[index].icon,
                iconColor: builderContext.appTheme.onBackground,
                label: widget.roundedButtonItems[index].label,
                backgroundColor: widget.roundedButtonItems[index].backgroundColor!.withOpacity(0.7),
                useContainerInsteadOfInk: true,
                size: 55,
              ),
            ],
          ),
        );
      },
    );

    List<Widget> listWidgets = widget.listItems != null
        ? List.generate(widget.listItems!.length, (index) {
            if (builderContext.isBigScreen) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.listItems![index].label,
                      style: kHeader4TextStyle.copyWith(color: builderContext.appTheme.onBackground),
                    ),
                    Gap.w16,
                    RoundedIconButton(
                      onTap: () async {
                        await _removeEntry();
                        widget.listItems![index].onTap();
                      },
                      iconPath: widget.listItems![index].icon,
                      iconColor: builderContext.appTheme.onBackground,
                      label: null,
                      backgroundColor: Colors.transparent,
                      withBorder: true,
                      useContainerInsteadOfInk: true,
                      size: 55,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                IconWithTextButton(
                  onTap: () async {
                    await _removeEntry();
                    widget.listItems![index].onTap();
                  },
                  width: null,
                  height: null,
                  iconPath: widget.listItems![index].icon,
                  label: widget.listItems![index].label,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  labelSize: 15,
                  color: builderContext.appTheme.onBackground.withOpacity(0.5),
                  backgroundColor: Colors.transparent,
                  border: Border.all(
                    color: builderContext.appTheme.onBackground.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                Gap.h16,
              ],
            );
          })
        : [];

    mainButtonOverlay(Animation? animation) {
      return Transform.scale(
        scale: (animation?.isDismissed ?? false) ? (0.8 + 0.2 * animation!.value) : 1,
        child: RoundedIconButton(
          iconPath: widget.mainItem?.icon ?? AppIcons.add,
          iconColor: widget.mainItem?.color ?? widget.iconColor ?? builderContext.appTheme.onAccent,
          backgroundColor: widget.mainItem?.backgroundColor ?? widget.color ?? builderContext.appTheme.accent2,
          iconPadding: 48.0 - (36.0 * (animation?.value ?? 1.0)),
          onTap: () async {
            await _removeEntry();
            widget.mainItem?.onTap();
          },
          size: _fabSize.width,
          noAnimation: true,
          useContainerInsteadOfInk: true,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, Widget? child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              ModalBarrier(
                onDismiss: () async => await _removeEntry(),
                color: builderContext.appTheme.background1.withOpacity(0.5 * _animation.value),
              ),
              Positioned(
                bottom: Gap.screenHeight(context) - fabPosition.dy,
                left:
                    fabPosition.dx - (context.isBigScreen ? overlayBoxWidth - _fabSize.width / 2 : overlayBoxWidth / 2),
                child: ScaleTransition(
                  scale: _animation,
                  alignment: builderContext.isBigScreen ? Alignment.bottomRight : Alignment.bottomCenter,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                    child: SizedBox(
                      width: overlayBoxWidth,
                      child: Column(
                        crossAxisAlignment:
                            builderContext.isBigScreen ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                        children: [
                          ...listWidgets,
                          builderContext.isBigScreen ? Gap.noGap : Gap.h32,
                          SizedBox(
                            height: builderContext.isBigScreen ? null : 150,
                            child: builderContext.isBigScreen
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ...buttonWidgets,
                                      Gap.h24,
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: buttonWidgets,
                                  ),
                          ),
                        ],
                      ),
                      // child: Row(
                      //   children: _widgets,
                      // ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: fabPosition.dy - _fabSize.height / 2,
                left: fabPosition.dx - _fabSize.width / 2,
                child: widget.mainItem != null
                    ? Transform.rotate(
                        angle: math.pi * _animation.value,
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: -math.pi,
                          child: mainButtonOverlay(_animation),
                        ),
                      )
                    : Transform.rotate(
                        angle: (math.pi * 1 / 4) * _animation.value,
                        child: mainButtonOverlay(null),
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}

//TODO: change 100 to kNavigationRailWidth
