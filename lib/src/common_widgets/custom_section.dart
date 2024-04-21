import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:math' as math;

import '../theme_and_ui/colors.dart';

class CustomSection extends StatefulWidget {
  const CustomSection({
    super.key,
    this.title,
    this.subTitle,
    this.subIcons,
    this.isWrapByCard = true,
    this.sectionsClipping = true,
    this.onReorder,
    this.margin,
    required this.sections,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.holdToReorder = true,
  });

  final String? title;
  final Widget? subTitle;
  final List<Widget>? subIcons;
  final bool isWrapByCard;
  final bool sectionsClipping;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final List<Widget> sections;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets? margin;
  final bool holdToReorder;

  @override
  State<CustomSection> createState() => _CustomSectionState();
}

class _CustomSectionState extends State<CustomSection> with SingleTickerProviderStateMixin {
  late List<Widget> _children = _generateTiles();

  late final _controller = AnimationController(vsync: this, duration: k250msDuration);

  late final _animation = _controller.drive(CurveTween(curve: Curves.easeOutBack));

  @override
  void didUpdateWidget(CustomSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sections != oldWidget.sections) {
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
        widget.sections.length,
        (index) {
          return SectionTile(
            key: ValueKey(index),
            child: widget.sections[index],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.title != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              widget.title!,
                              style: kHeader1TextStyle.copyWith(
                                color: context.appTheme.onBackground.withOpacity(0.85),
                                fontSize: 22,
                              ),
                            ),
                          )
                        : Gap.noGap,
                    widget.subTitle != null
                        ? IntrinsicWidth(
                            child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: widget.subTitle,
                          ))
                        : Gap.noGap,
                  ],
                ),
              ),
              ...?widget.subIcons,
            ],
          ),
          widget.title != null ? Gap.h16 : Gap.noGap,
          CardItem(
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
            padding: widget.isWrapByCard ? const EdgeInsets.all(8) : EdgeInsets.zero,
            margin: widget.isWrapByCard ? const EdgeInsets.all(6) : const EdgeInsets.only(bottom: 24),
            color: widget.isWrapByCard ? null : Colors.transparent,
            borderRadius: widget.isWrapByCard ? null : BorderRadius.zero,
            clip: widget.sectionsClipping,
            child: widget.onReorder == null
                ? Center(
                    child: Column(
                      crossAxisAlignment: widget.crossAxisAlignment,
                      children: _children,
                    ),
                  )
                : ReorderableColumn(
                    crossAxisAlignment: widget.crossAxisAlignment,
                    scrollController: ScrollController(),
                    draggingWidgetOpacity: 0,
                    needsLongPressDraggable: widget.holdToReorder,
                    reorderAnimationDuration: k250msDuration,
                    onReorderStarted: (_) => _controller.forward(from: 0),
                    // This callback build the widget when dragging is happening
                    buildDraggableFeedback: (context, constraint, feedback) {
                      return ConstrainedBox(
                        constraints: constraint,
                        child: Material(
                            color: Colors.transparent,
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(1.0 + 0.04 * _animation.value)
                                    ..rotateZ(math.pi * 0.025 * _animation.value),
                                  child: Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(0.1),
                                        blurRadius: 13 * _animation.value,
                                        offset: Offset(2 * _animation.value, 30 * _animation.value),
                                        spreadRadius: -13,
                                      )
                                    ]),
                                    child: (feedback as SectionTile).child,
                                  ),
                                );
                              },
                            )),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      _controller.reverse(from: 1);
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
  const SectionTile({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
