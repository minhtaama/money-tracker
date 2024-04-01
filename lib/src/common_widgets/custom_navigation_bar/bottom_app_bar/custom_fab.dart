import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theme_and_ui/icons.dart';
import '../../rounded_icon_button.dart';

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
  const CustomFloatingActionButton(
      {super.key, required this.roundedButtonItems, this.listItems, this.color, this.iconColor})
      : assert(roundedButtonItems.length == 3);
  final List<FABItem> roundedButtonItems;
  final List<FABItem>? listItems;
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
  late double overlayBoxWidth;

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

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showOverlay() {
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
                    child: Opacity(
                      opacity: _animation.value,
                      child: RoundedIconButton(
                        iconPath: AppIcons.fykFace,
                        iconColor: context.appTheme.onAccent,
                        backgroundColor: context.appTheme.accent2,
                        size: 55,
                      ),
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
