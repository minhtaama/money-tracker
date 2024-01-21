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
    required this.sections,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String? title;
  final Widget? subTitle;
  final List<Widget>? subIcons;
  final bool isWrapByCard;
  final bool sectionsClipping;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final List<Widget> sections;
  final CrossAxisAlignment crossAxisAlignment;

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
          if (index != widget.sections.length - 1 && widget.isWrapByCard) {
            return SectionTile(
              key: ValueKey(index),
              isHasDivider: true,
              child: widget.sections[index],
            );
          } else {
            return SectionTile(
              key: ValueKey(index),
              isHasDivider: false,
              child: widget.sections[index],
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
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.title != null
                      ? Padding(
                          padding: widget.isWrapByCard ? const EdgeInsets.only(left: 8.0) : EdgeInsets.zero,
                          child: Text(
                            widget.title!,
                            style: kHeader2TextStyle.copyWith(
                              color: context.appTheme.onBackground.withOpacity(0.85),
                            ),
                          ),
                        )
                      : Gap.noGap,
                  widget.subTitle ?? Gap.noGap,
                ],
              ),
              const Spacer(),
              ...?widget.subIcons,
            ],
          ),
          CardItem(
            padding: widget.isWrapByCard ? const EdgeInsets.all(16) : EdgeInsets.zero,
            margin: widget.isWrapByCard ? const EdgeInsets.all(6) : const EdgeInsets.symmetric(vertical: 18),
            elevation: widget.isWrapByCard ? 1 : 0,
            color: widget.isWrapByCard ? null : Colors.transparent,
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
                                        color: AppColors.black.withOpacity(0.2),
                                        blurRadius: 13 * _animation.value,
                                        offset: Offset(2 * _animation.value, 30 * _animation.value),
                                        spreadRadius: -13,
                                      )
                                    ]),
                                    child: child!,
                                  ),
                                );
                              },
                              child: (feedback as SectionTile).child,
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
  const SectionTile({super.key, required this.child, required this.isHasDivider});
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
