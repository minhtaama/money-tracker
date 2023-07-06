import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:reorderables/reorderables.dart';

class CustomSection extends StatefulWidget {
  const CustomSection({
    Key? key,
    required this.title,
    this.isWrapByCard = true,
    this.onReorder,
    required this.children,
  }) : super(key: key);
  final String title;
  final bool isWrapByCard;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final List<Widget> children;

  @override
  State<CustomSection> createState() => _CustomSectionState();
}

class _CustomSectionState extends State<CustomSection> {
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    _children = _generateTiles();
  }

  @override
  void didUpdateWidget(CustomSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children != oldWidget.children) {
      _children = _generateTiles();
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      Widget tile = _children.removeAt(oldIndex);
      _children.insert(newIndex, tile);
    });
  }

  List<SectionTile> _generateTiles() => List.generate(
        widget.children.length,
        (index) {
          if (index != widget.children.length - 1 && widget.isWrapByCard) {
            return SectionTile(
              key: ValueKey(index),
              isHasDivider: true,
              child: widget.children[index],
            );
          } else {
            return SectionTile(
              key: ValueKey(index),
              isHasDivider: false,
              child: widget.children[index],
            );
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: widget.isWrapByCard ? const EdgeInsets.only(left: 8.0) : EdgeInsets.zero,
            child: Text(
              widget.title,
              style: kHeader2TextStyle.copyWith(
                color: context.appTheme.backgroundNegative.withOpacity(0.85),
              ),
            ),
          ),
          CardItem(
            padding: widget.isWrapByCard ? const EdgeInsets.all(16) : EdgeInsets.zero,
            margin:
                widget.isWrapByCard ? const EdgeInsets.all(6) : const EdgeInsets.symmetric(vertical: 18),
            elevation: widget.isWrapByCard ? 1 : 0,
            color: widget.isWrapByCard ? null : Colors.transparent,
            child: widget.onReorder == null
                ? Column(
                    children: _children,
                  )
                : ReorderableColumn(
                    scrollController: ScrollController(),
                    draggingWidgetOpacity: 0,
                    // This callback build the widget when dragging is happening
                    buildDraggableFeedback: (context, constraint, feedback) {
                      Widget tile = Transform.scale(
                        scale: 1.05,
                        child: SectionTile(
                          isHasDivider: false,
                          child: (feedback as SectionTile).child,
                        ),
                      );
                      return Container(
                        constraints: constraint,
                        child: Material(color: Colors.transparent, child: tile),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      _onReorder(oldIndex, newIndex);
                      widget.onReorder!.call(oldIndex, newIndex);
                    },
                    children: _children,
                  ),
          )
        ],
      ),
    );
  }
}

class SectionTile extends StatelessWidget {
  const SectionTile({Key? key, required this.child, required this.isHasDivider}) : super(key: key);
  final bool isHasDivider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isHasDivider) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          Gap.h8,
          Gap.divider(context, indent: 2),
          Gap.h4,
        ],
      );
    } else {
      return child;
    }
  }
}
