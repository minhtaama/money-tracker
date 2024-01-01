import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../features/calculator_input/application/calculator_service.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

class MoneyCarousel extends StatefulWidget {
  const MoneyCarousel({
    super.key,
    required this.controller,
    required this.initialPageIndex,
    this.onPageChange,
    this.leftIconPath,
    this.rightIconPath,
    this.onTapRightIcon,
    this.onTapLeftIcon,
    this.showCurrency = true,
    this.showPrefixSign = true,
    required this.amountBuilder,
    required this.titleBuilder,
  });

  final PageController controller;
  final void Function(int)? onPageChange;
  final int initialPageIndex;
  final String? leftIconPath;
  final String? rightIconPath;
  final VoidCallback? onTapRightIcon;
  final VoidCallback? onTapLeftIcon;
  final bool showCurrency;
  final bool showPrefixSign;

  /// Safe to use `ref.watch` or `ref.listen` inside this builder (do not use
  /// `setState()` to update state).
  ///
  /// This function returns the display amount based on `dayBeginOfMonth`
  /// and `dayEndOfMonth` (which is calculated based on the `pageIndex` of [PageView])
  ///
  final double Function(WidgetRef ref, DateTime dayBeginOfMonth, DateTime dayEndOfMonth) amountBuilder;

  /// Build the small title under amount
  final String Function(String month) titleBuilder;

  @override
  State<MoneyCarousel> createState() => _MoneyCarouselState();
}

class _MoneyCarouselState extends State<MoneyCarousel> {
  late int _currentPageIndex = widget.controller.initialPage;
  late double _betweenButtonsGap = 0;

  late final DateTime _today = DateTime.now().onlyYearMonth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          PageView.builder(
            controller: widget.controller,
            onPageChanged: (page) {
              setState(() {
                _currentPageIndex = page;
              });
              widget.onPageChange?.call(page);
            },
            //physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
              DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

              String pageMonth =
                  DateTime(_today.year, _today.month + (pageIndex - widget.initialPageIndex))
                      .getFormattedDate(hasDay: false, hasYear: false, type: DateTimeType.ddmmmmyyyy);

              return Consumer(
                builder: (context, ref, child) {
                  double amount = widget.amountBuilder(ref, dayBeginOfMonth, dayEndOfMonth);

                  return _CarouselContent(
                    isActive: _currentPageIndex == pageIndex,
                    isShowValue: context.currentSettings.showBalanceInHomeScreen,
                    showCurrency: true,
                    showPrefixSign: widget.showPrefixSign,
                    amount: amount,
                    text: widget.titleBuilder(pageMonth),
                    onChange: (width) {
                      setState(() {
                        _betweenButtonsGap = width.clamp(100, 195) + 30;
                      });
                    },
                  );
                },
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
                          iconPadding: 12,
                          iconColor: context.appTheme.isDarkTheme
                              ? context.appTheme.onBackground
                              : context.appTheme.onSecondary,
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
                          iconPadding: 12,
                          iconColor: context.appTheme.isDarkTheme
                              ? context.appTheme.onBackground
                              : context.appTheme.onSecondary,
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
    required this.amount,
    required this.text,
    required this.isActive,
    required this.isShowValue,
    required this.showPrefixSign,
    required this.showCurrency,
    this.onChange,
  });

  final bool isActive;
  final bool isShowValue;
  final bool showCurrency;
  final bool showPrefixSign;
  final String text;
  final double amount;
  final ValueChanged<double>? onChange;

  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  final _key = GlobalKey();

  String _prefixSign(BuildContext context) {
    if (widget.amount.roundBySetting(context) == 0 || !widget.isShowValue || !widget.showPrefixSign) {
      return '';
    }
    if (widget.amount.roundBySetting(context) > 0) {
      return '+ ';
    } else {
      return '- ';
    }
  }

  String _currency(BuildContext context) {
    if (!widget.isShowValue || !widget.showCurrency) {
      return '';
    }

    return '${context.currentSettings.currency.symbol} ';
  }

  @override
  void initState() {
    if (widget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.isShowValue) {
          double width = _key.currentContext!.size!.width;
          widget.onChange?.call(width);
        } else {
          widget.onChange?.call(100);
        }
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _CarouselContent oldWidget) {
    if (widget.isActive && !oldWidget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.isShowValue && oldWidget.isShowValue) {
          double width = _key.currentContext!.size!.width;
          widget.onChange?.call(width);
        }
      });
    } else if (widget.isActive && oldWidget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (!widget.isShowValue && oldWidget.isShowValue) {
          widget.onChange?.call(100);
        } else if (widget.isShowValue && !oldWidget.isShowValue || widget.amount != oldWidget.amount) {
          double width = _key.currentContext!.size!.width;
          widget.onChange?.call(width);
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: k250msDuration,
      margin: EdgeInsets.only(
        top: widget.isActive ? 0 : 15,
        left: widget.isActive ? 0 : 15,
        right: widget.isActive ? 0 : 15,
      ),
      //color: Colors.green,
      child: AnimatedOpacity(
        duration: k250msDuration,
        opacity: widget.isActive ? 1 : 0.5,
        child: Column(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  key: _key,
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _prefixSign(context),
                      style: kHeader3TextStyle.copyWith(
                        color: context.appTheme.isDarkTheme
                            ? context.appTheme.onBackground.withOpacity(1)
                            : context.appTheme.onSecondary.withOpacity(1),
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      _currency(context),
                      style: kHeader3TextStyle.copyWith(
                        color: context.appTheme.isDarkTheme
                            ? context.appTheme.onBackground.withOpacity(0.6)
                            : context.appTheme.onSecondary.withOpacity(0.6),
                        fontSize: 20,
                      ),
                    ),
                    EasyRichText(
                      CalService.formatCurrency(context, widget.amount, isAbs: true),
                      defaultStyle: kHeader3TextStyle.copyWith(
                          color: context.appTheme.isDarkTheme
                              ? context.appTheme.onBackground
                              : context.appTheme.onSecondary,
                          fontSize: 23,
                          letterSpacing: 1),
                      textAlign: TextAlign.right,
                      patternList: [
                        EasyRichTextPattern(
                          targetString: r'[0-9]+',
                          style: kHeader2TextStyle.copyWith(
                            color: context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground
                                : context.appTheme.onSecondary,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: k250msDuration,
              margin: EdgeInsets.only(
                left: widget.isActive ? 0 : 30,
                right: widget.isActive ? 0 : 30,
              ),
              child: FittedBox(
                child: Text(
                  widget.text,
                  style: kHeader4TextStyle.copyWith(
                    color: context.appTheme.isDarkTheme
                        ? context.appTheme.onBackground.withOpacity(0.6)
                        : context.appTheme.onSecondary.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
