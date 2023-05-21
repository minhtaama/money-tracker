import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class FABItem {
  FABItem({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

// UI class of overlay buttons
class _FABOverlayButton extends StatelessWidget {
  const _FABOverlayButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.height,
  }) : super(key: key);
  final IconData icon;
  final String label;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon),
          Material(color: Colors.transparent, child: Text(label)),
        ],
      ),
    );
  }
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
  late List<Widget> _widgets;
  late double overlayBoxWidth;
  late double overlayBoxHeight;

  // GlobalKey is assigned to FloatingActionButton to get the RenderBox object
  // of the returned FloatingActionButton.
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: kAppBarExtendDuration,
    );
    _animation = CurveTween(curve: Curves.easeOut).animate(_animationController);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    overlayBoxWidth = MediaQuery.of(context).size.width / 1.2;
    overlayBoxHeight = MediaQuery.of(context).size.height / 5;

    _widgets = List.generate(widget.items.length, (index) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            //This is how the overlay buttons is aligned.
            mainAxisAlignment: index == 0 || index == widget.items.length - 1
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.items[index].onTap,
                child: _FABOverlayButton(
                  icon: widget.items[index].icon,
                  label: widget.items[index].label,
                  color: widget.items[index].color,
                  height: overlayBoxHeight / 1.7,
                ),
              ),
            ],
          ),
        ),
      );
    });
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
                color: Colors.black.withAlpha((125 * _animation.value).toInt()),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _widgets,
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
      onPressed: _showOverlay,
      child: const Icon(Icons.add),
    );
  }
}
