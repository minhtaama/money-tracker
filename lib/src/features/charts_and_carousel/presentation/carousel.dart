import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../calculator_input/application/calculator_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';

class TextCarousel extends StatefulWidget {
  const TextCarousel({
    super.key,
    required this.controller,
    required this.initialPageIndex,
    this.leftIconPath,
    this.rightIconPath,
    this.onTapRightIcon,
    this.onTapLeftIcon,
    required this.textBuilder,
    this.subTextBuilder,
    this.onPageChanged,
    this.physics,
  });

  final PageController controller;
  final int initialPageIndex;
  final String? leftIconPath;
  final String? rightIconPath;
  final VoidCallback? onTapRightIcon;
  final VoidCallback? onTapLeftIcon;
  final void Function(int)? onPageChanged;
  final String Function(int pageIndex) textBuilder;
  final String? Function(int pageIndex)? subTextBuilder;
  final ScrollPhysics? physics;

  @override
  State<TextCarousel> createState() => _TextCarouselState();
}

class _TextCarouselState extends State<TextCarousel> {
  late int _currentPageIndex = widget.controller.initialPage;
  late double _betweenButtonsGap = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          PageView.builder(
            physics: widget.physics,
            controller: widget.controller,
            onPageChanged: (page) {
              setState(() {
                _currentPageIndex = page;
              });
              widget.onPageChanged?.call(_currentPageIndex);
            },
            itemBuilder: (context, pageIndex) {
              return AnimatedSwitcher(
                duration: k250msDuration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: Tween<double>(
                      begin: 0,
                      end: 1,
                    ).animate(animation),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _CarouselContent(
                  key: ValueKey(widget.textBuilder(pageIndex)),
                  isActive: _currentPageIndex == pageIndex,
                  text: widget.textBuilder(pageIndex),
                  subText: widget.subTextBuilder?.call(pageIndex),
                  onChange: (width) {
                    setState(() {
                      _betweenButtonsGap = width.clamp(70, 195) + 10;
                    });
                  },
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.leftIconPath != null
                      ? RoundedIconButton(
                          iconPath: widget.leftIconPath!,
                          size: 38,
                          iconPadding: 8,
                          iconColor: context.appTheme.onBackground.withOpacity(0.65),
                          inkColor: context.appTheme.onBackground.withOpacity(0.25),
                          backgroundColor: Colors.transparent,
                          onTap: widget.onTapLeftIcon,
                        )
                      : Gap.noGap,
                  AnimatedContainer(
                    duration: k250msDuration,
                    curve: Curves.easeOutBack,
                    width: _betweenButtonsGap,
                  ),
                  widget.rightIconPath != null
                      ? RoundedIconButton(
                          iconPath: widget.rightIconPath!,
                          iconPadding: 8,
                          size: 38,
                          iconColor: context.appTheme.onBackground.withOpacity(0.65),
                          inkColor: context.appTheme.onBackground.withOpacity(0.25),
                          backgroundColor: Colors.transparent,
                          onTap: widget.onTapRightIcon,
                        )
                      : Gap.noGap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselContent extends StatefulWidget {
  const _CarouselContent({
    super.key,
    required this.text,
    this.subText,
    required this.isActive,
    this.onChange,
  });

  final bool isActive;
  final String text;
  final String? subText;
  final ValueChanged<double>? onChange;

  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  final _key = GlobalKey();

  @override
  void didUpdateWidget(covariant _CarouselContent oldWidget) {
    if (widget.isActive && !oldWidget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        double width = _key.currentContext!.size!.width;
        widget.onChange?.call(width);
      });
    } else if (widget.isActive && oldWidget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.text != oldWidget.text) {
          double width = _key.currentContext!.size!.width;
          widget.onChange?.call(width);
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.isActive ? 1 : 0.7,
      duration: k250msDuration,
      child: AnimatedContainer(
        duration: k250msDuration,
        margin: EdgeInsets.only(
          //top: widget.isActive ? 0 : 10,
          left: widget.isActive ? 0 : 15,
          right: widget.isActive ? 0 : 15,
        ),
        //color: Colors.green,
        child: AnimatedOpacity(
          duration: k250msDuration,
          opacity: widget.isActive ? 1 : 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  key: _key,
                  widget.text,
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 20,
                  ),
                ),
              ),
              widget.subText != null
                  ? AnimatedContainer(
                      duration: k250msDuration,
                      margin: EdgeInsets.only(
                        top: 3,
                        left: widget.isActive ? 0 : 30,
                        right: widget.isActive ? 0 : 30,
                      ),
                      child: FittedBox(
                        child: Text(
                          widget.subText!,
                          style: kNormalTextStyle.copyWith(
                            color: context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground.withOpacity(0.6)
                                : context.appTheme.onSecondary.withOpacity(0.6),
                            height: 0.99,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    )
                  : Gap.noGap,
            ],
          ),
        ),
      ),
    );
  }
}
