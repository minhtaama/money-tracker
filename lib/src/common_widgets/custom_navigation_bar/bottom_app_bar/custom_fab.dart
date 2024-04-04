import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theme_and_ui/icons.dart';
import '../../rounded_icon_button.dart';
import 'dart:math' as math;

class FABItem {
  FABItem(
      {required this.icon, required this.label, this.backgroundColor, this.color, required this.onTap});

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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late List<Widget> Function(OverlayEntry overlayEntry) _buttonWidgets;
  late List<Widget> Function(OverlayEntry overlayEntry) _listWidgets;
  late Widget Function(OverlayEntry overlayEntry, Animation<double>? animation) _mainButtonOverlay;
  late double overlayBoxWidth;
  Size _floatingActionButtonSize = Size.zero;
  bool _isOverlayShowing = false;

  // GlobalKey is assigned to FloatingActionButton to get the RenderBox object
  // of the returned FloatingActionButton.
  final _globalKey = GlobalKey();
  final _globalKey2 = GlobalKey();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: k250msDuration,
      reverseDuration: k150msDuration,
    );
    _animation = CurveTween(curve: Curves.easeOut).animate(_animationController);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _floatingActionButtonSize = _globalKey.currentContext!.size!;
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    overlayBoxWidth = (MediaQuery.of(context).size.width / 1.2).clamp(0, 400);

    _buttonWidgets = (overlayEntry) {
      return List.generate(
        widget.roundedButtonItems.length,
        (index) {
          return SizedBox(
            width: overlayBoxWidth / 3,
            child: Column(
              //This is how the overlay buttons is aligned.
              mainAxisAlignment:
                  index == 0 || index == 2 ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                RoundedIconButton(
                  onTap: () async {
                    await _removeEntry(overlayEntry);
                    widget.roundedButtonItems[index].onTap();
                  },
                  iconPath: widget.roundedButtonItems[index].icon,
                  iconColor: context.appTheme.onBackground,
                  label: widget.roundedButtonItems[index].label,
                  backgroundColor: widget.roundedButtonItems[index].backgroundColor!.withOpacity(0.7),
                  size: 55,
                ),
              ],
            ),
          );
        },
      );
    };

    _listWidgets = (overlayEntry) {
      return widget.listItems != null
          ? List.generate(widget.listItems!.length, (index) {
              return Column(
                children: [
                  IconWithTextButton(
                    onTap: () async {
                      await _removeEntry(overlayEntry);
                      widget.listItems![index].onTap();
                    },
                    width: null,
                    height: null,
                    iconPath: widget.listItems![index].icon,
                    label: widget.listItems![index].label,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    labelSize: 15,
                    color: context.appTheme.onBackground.withOpacity(0.5),
                    backgroundColor: Colors.transparent,
                    border: Border.all(
                      color: context.appTheme.onBackground.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  Gap.h16,
                ],
              );
            })
          : [];
    };

    _mainButtonOverlay = (overlayEntry, animation) {
      return Transform.scale(
        scale: (animation?.isDismissed ?? false) ? (0.8 + 0.2 * animation!.value) : 1,
        child: RoundedIconButton(
          iconPath: widget.mainItem?.icon ?? AppIcons.add,
          iconColor: widget.mainItem?.color ?? widget.iconColor ?? context.appTheme.onAccent,
          backgroundColor: widget.mainItem?.backgroundColor ?? widget.color ?? context.appTheme.accent2,
          iconPadding: 48 - (36 * (animation?.value ?? 1)),
          onTap: () async {
            await _removeEntry(overlayEntry);
            widget.mainItem?.onTap();
          },
          size: _floatingActionButtonSize.width,
          noAnimation: true,
        ),
      );
    };

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    Future.delayed(
      k150msDuration,
      () => setState(() {
        _isOverlayShowing = true;
      }),
    );

    Offset fabPosition = _getRenderObjectCenterPosition(_globalKey, isTopCenterPoint: true);

    // Get OverlayState of the closest instance in context
    OverlayState overlayState = Overlay.of(context);

    // Create an OverlayEntry
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
        maintainState: true,
        builder: (_) {
          double overlayBoxHeight = 150;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              overlayBoxHeight = _globalKey2.currentContext!.size!.height;
            });
          });
          return AnimatedBuilder(
            animation: _animation,
            builder: (_, Widget? child) {
              return Stack(
                children: [
                  ModalBarrier(
                    onDismiss: () async => await _removeEntry(overlayEntry),
                    color: context.appTheme.background1.withOpacity(0.5 * _animation.value),
                  ),
                  Positioned(
                    top: fabPosition.dy - overlayBoxHeight,
                    left: fabPosition.dx - overlayBoxWidth / 2,
                    child: ScaleTransition(
                      scale: _animation,
                      alignment: Alignment.bottomCenter,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                        child: SizedBox(
                          key: _globalKey2,
                          width: overlayBoxWidth,
                          child: Column(
                            verticalDirection: VerticalDirection.up,
                            children: [
                              SizedBox(
                                height: 150,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: _buttonWidgets(overlayEntry),
                                ),
                              ),
                              Gap.h32,
                              ..._listWidgets(overlayEntry),
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
                    top: fabPosition.dy,
                    left: fabPosition.dx - 27.5,
                    child: widget.mainItem != null
                        ? Transform.rotate(
                            angle: math.pi * _animation.value,
                            alignment: Alignment.center,
                            child: Transform.rotate(
                              angle: -math.pi,
                              child: _mainButtonOverlay(overlayEntry, _animation),
                            ),
                          )
                        : Transform.rotate(
                            angle: (math.pi * 1 / 4) * _animation.value,
                            child: _mainButtonOverlay(overlayEntry, null),
                          ),
                  )
                ],
              );
            },
          );
        });

    // Insert the entry into overlay
    overlayState.insert(overlayEntry);

    // Play the animation of widgets in the entry
    _animationController.forward();
  }

  Future<void> _removeEntry(OverlayEntry entry) async {
    setState(() {
      _isOverlayShowing = false;
    });

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
    return FloatingActionButton(
      key: _globalKey,
      onPressed: null,
      shape: const CircleBorder(),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Opacity(
        opacity: _isOverlayShowing ? 0 : 1,
        child: RoundedIconButton(
          iconPath: AppIcons.add,
          iconColor: widget.iconColor ?? context.appTheme.onAccent,
          backgroundColor: widget.color ?? context.appTheme.accent2,
          size: double.infinity,
          onTap: _showOverlay,
          elevation: 10,
        ),
      ),
    );
  }
}
