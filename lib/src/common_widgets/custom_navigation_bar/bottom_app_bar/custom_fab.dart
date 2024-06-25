import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
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

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late double overlayBoxWidth = (Gap.screenWidth(context) / 1.2).clamp(0, 400);

  bool _visible = false;

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        overlayBoxWidth = (Gap.screenWidth(context) / 1.2).clamp(0, 400);
      });
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPortal() {
    _animationController.forward();
    setState(() {
      _visible = true;
    });
  }

  Future<void> _hidePortal() async {
    await _animationController.reverse();
    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _visible,
      portalFollower: _Backdrop(
        _hidePortal,
        animation: _animation,
      ),
      child: PortalTarget(
        visible: _visible,
        anchor: const Aligned(
          follower: Alignment.center,
          target: Alignment.center,
        ),
        portalFollower: _MainButtons(
          widget.mainItem,
          _hidePortal,
          animation: _animation,
          color: widget.color,
          iconColor: widget.iconColor,
        ),
        child: PortalTarget(
          visible: _visible,
          anchor: Aligned(
            follower: context.isBigScreen ? Alignment.bottomRight : Alignment.bottomCenter,
            target: context.isBigScreen ? Alignment.topRight : Alignment.topCenter,
          ),
          portalFollower: FittedBox(
            fit: BoxFit.scaleDown,
            child: _PortalFollower(
              animation: _animation,
              primaryItems: widget.roundedButtonItems,
              listItems: widget.listItems,
              mainItem: widget.mainItem,
              hideModalFunction: _hidePortal,
            ),
          ),
          child: RoundedIconButton(
            iconPath: AppIcons.addLight,
            iconColor: widget.iconColor ?? context.appTheme.onAccent,
            backgroundColor: widget.color ?? context.appTheme.accent2,
            size: 55,
            onTap: _showPortal,
            elevation: 10,
          ),
        ),
      ),
    );
  }
}

class _PortalFollower extends AnimatedWidget {
  const _PortalFollower({
    required Animation<double> animation,
    required this.primaryItems,
    required this.listItems,
    required this.mainItem,
    required this.hideModalFunction,
  }) : super(listenable: animation);

  final List<FABItem> primaryItems;
  final List<FABItem>? listItems;
  final FABItem? mainItem;
  final Future<void> Function() hideModalFunction;

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      alignment: context.isBigScreen ? Alignment.bottomRight : Alignment.bottomCenter,
      scale: _progress,
      child: Column(
        crossAxisAlignment: context.isBigScreen ? CrossAxisAlignment.end : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ListButtons(listItems ?? [], hideModalFunction),
          context.isBigScreen ? Gap.noGap : Gap.h32,
          SizedBox(
            height: context.isBigScreen ? null : 150,
            child: context.isBigScreen
                ? _PrimaryButtonsOnBigScreen(primaryItems, hideModalFunction)
                : _PrimaryButtonsOnSmallScreen(primaryItems, hideModalFunction),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButtonsOnSmallScreen extends StatelessWidget {
  const _PrimaryButtonsOnSmallScreen(this.primaryItems, this.hideModalFunction);
  final Future<void> Function() hideModalFunction;

  final List<FABItem> primaryItems;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        primaryItems.length,
        (index) {
          return SizedBox(
            width: 120,
            child: Column(
              //This is how the overlay buttons is aligned.
              mainAxisAlignment: index == 0 || index == 2 ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                RoundedIconButton(
                  onTap: () async {
                    await hideModalFunction();
                    primaryItems[index].onTap();
                  },
                  iconPath: primaryItems[index].icon,
                  iconColor: context.appTheme.onBackground,
                  label: primaryItems[index].label,
                  backgroundColor: primaryItems[index].backgroundColor!.withOpacity(0.7),
                  useContainerInsteadOfInk: true,
                  size: 55,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrimaryButtonsOnBigScreen extends StatelessWidget {
  const _PrimaryButtonsOnBigScreen(this.primaryItems, this.hideModalFunction);

  final List<FABItem> primaryItems;
  final Future<void> Function() hideModalFunction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        primaryItems.length,
        (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  primaryItems[index].label,
                  style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
                ),
                Gap.w16,
                RoundedIconButton(
                  onTap: () async {
                    await hideModalFunction();
                    primaryItems[index].onTap();
                  },
                  iconPath: primaryItems[index].icon,
                  iconColor: context.appTheme.onBackground,
                  label: null,
                  backgroundColor: primaryItems[index].backgroundColor!.withOpacity(0.7),
                  useContainerInsteadOfInk: true,
                  size: 55,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ListButtons extends StatelessWidget {
  const _ListButtons(this.listItems, this.hideModalFunction);

  final List<FABItem> listItems;
  final Future<void> Function() hideModalFunction;

  Widget buttonOnSmallScreen(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: IconWithTextButton(
        onTap: () async {
          await hideModalFunction();
          listItems[index].onTap();
        },
        width: null,
        height: null,
        iconPath: listItems[index].icon,
        label: listItems[index].label,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        labelSize: 15,
        color: context.appTheme.onBackground.withOpacity(0.5),
        backgroundColor: Colors.transparent,
        border: Border.all(
          color: context.appTheme.onBackground.withOpacity(0.4),
          width: 1.5,
        ),
      ),
    );
  }

  Widget buttonOnBigScreen(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            listItems[index].label,
            style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
          ),
          Gap.w16,
          RoundedIconButton(
            onTap: () async {
              await hideModalFunction();
              listItems[index].onTap();
            },
            iconPath: listItems[index].icon,
            iconColor: context.appTheme.onBackground,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: context.isBigScreen ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      children: List.generate(listItems.length, (index) {
        if (context.isBigScreen) {
          return buttonOnBigScreen(context, index);
        }

        return buttonOnSmallScreen(context, index);
      }),
    );
  }
}

class _MainButtons extends AnimatedWidget {
  const _MainButtons(
    this.mainItem,
    this.hideModalFunction, {
    required Animation<double> animation,
    this.iconColor,
    this.color,
  }) : super(listenable: animation);

  final FABItem? mainItem;
  final Color? iconColor;
  final Color? color;
  final Future<void> Function() hideModalFunction;

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    Widget child() => Transform.scale(
          scale: _progress.isDismissed ? (0.8 + 0.2 * _progress.value) : 1,
          child: RoundedIconButton(
            iconPath: mainItem?.icon ?? AppIcons.addLight,
            iconColor: mainItem?.color ?? iconColor ?? context.appTheme.onAccent,
            backgroundColor: mainItem?.backgroundColor ?? color ?? context.appTheme.accent2,
            iconPadding: 48.0 - (36.0 * _progress.value),
            onTap: () async {
              await hideModalFunction();
              mainItem?.onTap();
            },
            size: 55,
            noAnimation: true,
            useContainerInsteadOfInk: true,
          ),
        );

    return mainItem != null
        ? Transform.rotate(
            angle: math.pi * _progress.value,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -math.pi,
              child: child(),
            ),
          )
        : Transform.rotate(
            angle: (math.pi * 1 / 4) * _progress.value,
            child: child(),
          );
  }
}

class _Backdrop extends AnimatedWidget {
  const _Backdrop(
    this.hideModalFunction, {
    required Animation<double> animation,
  }) : super(listenable: animation);

  final Future<void> Function() hideModalFunction;

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    Widget child() => FadeTransition(
          opacity: _progress,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async => await hideModalFunction(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
              child: Container(
                color: context.appTheme.background1.withOpacity(0.5),
              ),
            ),
          ),
        );

    return child();
  }
}
