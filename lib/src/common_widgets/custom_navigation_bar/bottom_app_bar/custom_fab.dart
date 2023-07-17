import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theme_and_ui/icons.dart';
import '../../rounded_icon_button.dart';

class FABItem {
  FABItem({required this.icon, required this.label, required this.color, required this.onTap});

  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

// https://blog.logrocket.com/complete-guide-implementing-overlays-flutter/#example-2-a-floatingactionbutton-showing-three-other-buttons
// Create a custom FloatingActionButton that expands more buttons when tapped
class CustomFloatingActionButton extends StatefulWidget {
  const CustomFloatingActionButton({Key? key, required this.items}) : super(key: key);
  final List<FABItem> items;

  @override
  State<CustomFloatingActionButton> createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late List<Widget> Function(OverlayEntry overlayEntry) _widgets;
  late double overlayBoxWidth;
  late double overlayBoxHeight;

  // GlobalKey is assigned to FloatingActionButton to get the RenderBox object
  // of the returned FloatingActionButton.
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: kBottomAppBarDuration,
    );
    _animation = CurveTween(curve: Curves.easeOut).animate(_animationController);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    overlayBoxWidth = MediaQuery.of(context).size.width / 1.2;
    overlayBoxHeight = MediaQuery.of(context).size.height / 4.5;

    _widgets = (overlayEntry) {
      return List.generate(
        widget.items.length,
        (index) {
          return Column(
            //This is how the overlay buttons is aligned.
            mainAxisAlignment: index == 0 || index == widget.items.length - 1
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              RoundedIconButton(
                onTap: () {
                  widget.items[index].onTap();
                  _removeEntry(overlayEntry);
                },
                iconPath: widget.items[index].icon,
                iconColor: context.appTheme.backgroundNegative,
                label: widget.items[index].label,
                backgroundColor: widget.items[index].color,
                size: overlayBoxWidth / 5.5,
              ),
            ],
          );
        },
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
    Offset fabPosition = _getRenderObjectCenterPosition(globalKey, isTopCenterPoint: true);

    // Get OverlayState of the closest instance in context
    OverlayState overlayState = Overlay.of(context);

    // Create an OverlayEntry
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(builder: (_) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (_, Widget? child) {
          return Stack(
            children: [
              ModalBarrier(
                onDismiss: () => _removeEntry(overlayEntry),
                color: context.appTheme.background.withOpacity(kModalBarrierOpacity * _animation.value),
              ),
              Positioned(
                top: fabPosition.dy - overlayBoxHeight,
                left: fabPosition.dx - overlayBoxWidth / 2,
                child: ScaleTransition(
                  scale: _animation,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: overlayBoxWidth,
                    height: overlayBoxHeight,
                    //color: Colors.deepOrangeAccent,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _widgets(overlayEntry),
                    ),
                    // child: Row(
                    //   children: _widgets,
                    // ),
                  ),
                ),
              ),
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

  void _removeEntry(OverlayEntry entry) async {
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
      key: globalKey,
      onPressed: () {},
      shape: const CircleBorder(),
      elevation: 4,
      backgroundColor: Colors.transparent,
      child: RoundedIconButton(
        iconPath: AppIcons.add,
        iconColor: context.appTheme.accentNegative,
        backgroundColor: context.appTheme.accent,
        size: double.infinity,
        onTap: _showOverlay,
      ),
    );
  }
}
