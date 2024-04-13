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

  late List<Widget> _buttonWidgets = List.generate(
    widget.roundedButtonItems.length,
    (index) {
      if (context.isBigScreen) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            children: [
              RoundedIconButton(
                onTap: () async {
                  await _removeEntry();
                  widget.roundedButtonItems[index].onTap();
                },
                iconPath: widget.roundedButtonItems[index].icon,
                iconColor: context.appTheme.onBackground,
                label: null,
                backgroundColor: widget.roundedButtonItems[index].backgroundColor!.withOpacity(0.7),
                useContainerInsteadOfInk: true,
                size: 55,
              ),
              Gap.w16,
              Text(
                widget.roundedButtonItems[index].label,
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        width: _overlayBoxWidth / 3,
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
              iconColor: context.appTheme.onBackground,
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

  late List<Widget> _listWidgets = widget.listItems != null
      ? List.generate(widget.listItems!.length, (index) {
          if (context.isBigScreen) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  RoundedIconButton(
                    onTap: () async {
                      await _removeEntry();
                      widget.listItems![index].onTap();
                    },
                    iconPath: widget.listItems![index].icon,
                    iconColor: context.appTheme.onBackground,
                    label: null,
                    backgroundColor: Colors.transparent,
                    withBorder: true,
                    useContainerInsteadOfInk: true,
                    size: 55,
                  ),
                  Gap.w16,
                  Text(
                    widget.listItems![index].label,
                    style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
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

  late Widget Function(Animation<double>? animation) _mainButtonOverlay = (animation) {
    return Transform.scale(
      scale: (animation?.isDismissed ?? false) ? (0.8 + 0.2 * animation!.value) : 1,
      child: RoundedIconButton(
        iconPath: widget.mainItem?.icon ?? AppIcons.add,
        iconColor: widget.mainItem?.color ?? widget.iconColor ?? context.appTheme.onAccent,
        backgroundColor: widget.mainItem?.backgroundColor ?? widget.color ?? context.appTheme.accent2,
        iconPadding: 48 - (36 * (animation?.value ?? 1)),
        onTap: () async {
          await _removeEntry();
          widget.mainItem?.onTap();
        },
        size: _fabSize.width,
        noAnimation: true,
        useContainerInsteadOfInk: true,
      ),
    );
  };

  late double _overlayBoxWidth;

  OverlayEntry? _overlayEntry;

  Size _fabSize = Size.zero;

  late Offset _fabPosition = _getRenderObjectCenterPosition(_globalKey, isTopCenterPoint: true);

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
      _fabSize = _globalKey.currentContext!.size!;
    });

    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _fabPosition = _getRenderObjectCenterPosition(_globalKey, isTopCenterPoint: true);
        _fabSize = _globalKey.currentContext!.size!;
        _overlayBoxWidth = (MediaQuery.of(context).size.width / 1.2).clamp(0, 400);

        _buttonWidgets = List.generate(
          widget.roundedButtonItems.length,
          (index) {
            if (context.isBigScreen) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  children: [
                    RoundedIconButton(
                      onTap: () async {
                        await _removeEntry();
                        widget.roundedButtonItems[index].onTap();
                      },
                      iconPath: widget.roundedButtonItems[index].icon,
                      iconColor: context.appTheme.onBackground,
                      label: null,
                      backgroundColor:
                          widget.roundedButtonItems[index].backgroundColor!.withOpacity(0.7),
                      useContainerInsteadOfInk: true,
                      size: 55,
                    ),
                    Gap.w16,
                    Text(
                      widget.roundedButtonItems[index].label,
                      style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
                    ),
                  ],
                ),
              );
            }
            return SizedBox(
              width: _overlayBoxWidth / 3,
              child: Column(
                //This is how the overlay buttons is aligned.
                mainAxisAlignment:
                    index == 0 || index == 2 ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  RoundedIconButton(
                    onTap: () async {
                      await _removeEntry();
                      widget.roundedButtonItems[index].onTap();
                    },
                    iconPath: widget.roundedButtonItems[index].icon,
                    iconColor: context.appTheme.onBackground,
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

        _listWidgets = widget.listItems != null
            ? List.generate(widget.listItems!.length, (index) {
                if (context.isBigScreen) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      children: [
                        RoundedIconButton(
                          onTap: () async {
                            await _removeEntry();
                            widget.listItems![index].onTap();
                          },
                          iconPath: widget.listItems![index].icon,
                          iconColor: context.appTheme.onBackground,
                          label: null,
                          backgroundColor: Colors.transparent,
                          withBorder: true,
                          useContainerInsteadOfInk: true,
                          size: 55,
                        ),
                        Gap.w16,
                        Text(
                          widget.listItems![index].label,
                          style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
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

        _mainButtonOverlay = (animation) {
          return Transform.scale(
            scale: (animation?.isDismissed ?? false) ? (0.8 + 0.2 * animation!.value) : 1,
            child: RoundedIconButton(
              iconPath: widget.mainItem?.icon ?? AppIcons.add,
              iconColor: widget.mainItem?.color ?? widget.iconColor ?? context.appTheme.onAccent,
              backgroundColor:
                  widget.mainItem?.backgroundColor ?? widget.color ?? context.appTheme.accent2,
              iconPadding: 48 - (36 * (animation?.value ?? 1)),
              onTap: () async {
                await _removeEntry();
                widget.mainItem?.onTap();
              },
              size: _fabSize.width,
              noAnimation: true,
              useContainerInsteadOfInk: true,
            ),
          );
        };

        _overlayEntry?.markNeedsBuild();
      });
    });

    super.didChangeDependencies();
  }

  @override
  void deactivate() async {
    await _removeEntry();
    super.deactivate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    super.dispose();
  }

  void _showOverlay() {
    print('${_globalKey.toString()}   $_fabPosition');
    // Get OverlayState of the closest instance in context
    OverlayState overlayState = Overlay.of(navigationRailKey.currentContext!);

    _overlayEntry = OverlayEntry(builder: (_) {
      double overlayBoxHeight = 150;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            overlayBoxHeight = _globalKey2.currentContext!.size!.height;
          });
        }
      });
      return AnimatedBuilder(
        animation: _animation,
        builder: (_, Widget? child) {
          return Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                ModalBarrier(
                  onDismiss: () async => await _removeEntry(),
                  color: context.appTheme.background1.withOpacity(0.5 * _animation.value),
                ),
                Positioned(
                  top: _fabPosition.dy - overlayBoxHeight,
                  left: context.isBigScreen ? 50 - 55 / 2 : _fabPosition.dx - _overlayBoxWidth / 2,
                  child: ScaleTransition(
                    scale: _animation,
                    alignment: context.isBigScreen ? Alignment.bottomLeft : Alignment.bottomCenter,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                      child: SizedBox(
                        key: _globalKey2,
                        width: _overlayBoxWidth,
                        child: Column(
                          verticalDirection: VerticalDirection.up,
                          children: [
                            SizedBox(
                              height: context.isBigScreen ? null : 150,
                              child: context.isBigScreen
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: _buttonWidgets,
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: _buttonWidgets,
                                    ),
                            ),
                            context.isBigScreen ? Gap.noGap : Gap.h32,
                            ..._listWidgets,
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
                  top: _fabPosition.dy,
                  left: _fabPosition.dx - 27.5,
                  child: widget.mainItem != null
                      ? Transform.rotate(
                          angle: math.pi * _animation.value,
                          alignment: Alignment.center,
                          child: Transform.rotate(
                            angle: -math.pi,
                            child: _mainButtonOverlay(_animation),
                          ),
                        )
                      : Transform.rotate(
                          angle: (math.pi * 1 / 4) * _animation.value,
                          child: _mainButtonOverlay(null),
                        ),
                )
              ],
            ),
          );
        },
      );
    });

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

  Offset _getRenderObjectCenterPosition(GlobalKey key, {required bool isTopCenterPoint}) {
    // Find RenderBox of the widget using globalKey
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;

    //final ancestorRenderBox = navigationRailChildKey.currentContext?.findRenderObject();

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
    GoRouterState.of(context).uri.toString();

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
}

//TODO: change 100 to kNavigationRailWidth
