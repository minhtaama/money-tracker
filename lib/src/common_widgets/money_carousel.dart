import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../features/calculator_input/application/calculator_service.dart';
import '../features/transactions/data/transaction_repo.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

class MoneyCarousel extends StatefulWidget {
  const MoneyCarousel({
    super.key,
    required this.controller,
    required this.initialPageIndex,
    this.leftIconPath,
    this.rightIconPath,
    this.onTapRightIcon,
    this.onTapLeftIcon,
  });

  final PageController controller;
  final int initialPageIndex;
  final String? leftIconPath;
  final String? rightIconPath;
  final VoidCallback? onTapRightIcon;
  final VoidCallback? onTapLeftIcon;

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
            },
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
              DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

              return Consumer(
                builder: (context, ref, child) {
                  final transactionRepository = ref.read(transactionRepositoryRealmProvider);

                  String pageMonth = DateTime(_today.year, _today.month + (pageIndex - widget.initialPageIndex))
                      .getFormattedDate(hasDay: false, hasYear: false, type: DateTimeType.ddmmmmyyyy);

                  double amount = transactionRepository.getNetCashflow(dayBeginOfMonth, dayEndOfMonth);

                  ref.listen(transactionChangesRealmProvider(DateTimeRange(start: dayBeginOfMonth, end: dayEndOfMonth)),
                      (_, __) {
                    setState(() {
                      amount = transactionRepository.getNetCashflow(dayBeginOfMonth, dayEndOfMonth);
                    });
                  });

                  return CarouselContent(
                    isActive: _currentPageIndex == pageIndex,
                    isShowValue: context.currentSettings.showBalanceInHomeScreen,
                    amount: amount,
                    text: 'Cashflow in $pageMonth',
                    onActive: (width) {
                      setState(() {
                        _betweenButtonsGap = width.clamp(90, 220) + 20;
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
                          size: 32,
                          iconPadding: 4,
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
                          size: 32,
                          iconPadding: 4,
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

class CarouselContent extends StatefulWidget {
  const CarouselContent({
    super.key,
    required this.amount,
    required this.text,
    required this.isActive,
    this.isShowValue = true,
    this.onActive,
  });
  final bool isActive;
  final bool isShowValue;
  final String text;
  final double amount;
  final ValueChanged<double>? onActive;

  @override
  State<CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<CarouselContent> {
  final _key = GlobalKey();

  String _symbol(BuildContext context) {
    if (widget.amount.roundBySetting(context) == 0 || !widget.isShowValue) {
      return '';
    }
    if (widget.amount.roundBySetting(context) > 0) {
      return '+';
    } else {
      return '-';
    }
  }

  @override
  void initState() {
    if (widget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.isShowValue) {
          double width = _key.currentContext!.size!.width;
          widget.onActive?.call(width);
        } else {
          widget.onActive?.call(50);
        }
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CarouselContent oldWidget) {
    if (widget.isActive && !oldWidget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.isShowValue && oldWidget.isShowValue) {
          double width = _key.currentContext!.size!.width;
          widget.onActive?.call(width);
        }
      });
    } else if (widget.isActive && oldWidget.isActive) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (!widget.isShowValue && oldWidget.isShowValue) {
          widget.onActive?.call(50);
        } else if (widget.isShowValue && !oldWidget.isShowValue) {
          double width = _key.currentContext!.size!.width;
          widget.onActive?.call(width);
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
                child: Row(
                  key: _key,
                  children: [
                    Transform.translate(
                      offset: const Offset(-2, 3),
                      child: Text(
                        _symbol(context),
                        style: kHeader3TextStyle.copyWith(
                          color: context.appTheme.isDarkTheme
                              ? context.appTheme.onBackground.withOpacity(0.6)
                              : context.appTheme.onSecondary.withOpacity(0.6),
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.right,
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
