import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/money_amount.dart';
import '../../../utils/enums.dart';
import '../../calculator_input/presentation/calculator_input.dart';

class AmountSelector extends ConsumerStatefulWidget {
  const AmountSelector({
    super.key,
    required this.transactionType,
    this.initialValue,
    required this.onChanged,
    required this.isCentered,
    required this.suffix,
    required this.prefix,
    required this.errorText,
  });

  final ValueChanged<double> onChanged;
  final TransactionType transactionType;
  final double? initialValue;
  final bool isCentered;
  final Widget? suffix;
  final String? prefix;
  final String? errorText;

  @override
  ConsumerState<AmountSelector> createState() => _AmountSelectorState();
}

class _AmountSelectorState extends ConsumerState<AmountSelector> {
  double? _currentAmount;

  @override
  void didUpdateWidget(covariant AmountSelector oldWidget) {
    if (widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _currentAmount = widget.initialValue;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  Color _color(BuildContext context) {
    return switch (widget.transactionType) {
      TransactionType.income => context.appTheme.positive,
      TransactionType.expense => context.appTheme.negative,
      TransactionType.transfer => context.appTheme.onBackground,
      TransactionType.creditSpending => context.appTheme.onBackground,
      TransactionType.creditPayment => context.appTheme.negative,
      TransactionType.creditCheckpoint => context.appTheme.onBackground,
      TransactionType.installmentToPay => context.appTheme.negative,
    };
  }

  void _changeAmount() async {
    final title = switch (widget.transactionType) {
      TransactionType.expense => context.loc.expense,
      TransactionType.income => context.loc.income,
      TransactionType.transfer => context.loc.transfer,
      TransactionType.creditSpending => context.loc.creditSpending,
      TransactionType.creditPayment => context.loc.creditPayment,
      _ => throw StateError('This is only for creating transactions')
    };

    final newAmount = await showCalculatorModalScreen(
      context,
      title: title,
      initialValue: _currentAmount ?? widget.initialValue,
    );

    if (newAmount != null) {
      setState(() {
        _currentAmount = CalService.formatToDouble(newAmount);
        widget.onChanged(_currentAmount!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _color(context).withOpacity(0.0),
            _color(context).withOpacity(0.1),
          ],
          stops: const [0.35, 1],
        ),
        border: Border.all(
          color: _color(context).withOpacity(0.45),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: CustomInkWell(
        inkColor: _color(context).withOpacity(0.15),
        onTap: _changeAmount,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  MoneyAmount(
                    amount: _currentAmount ?? 0,
                    noAnimation: true,
                    style: kHeader1TextStyle.copyWith(
                      color: _color(context),
                      fontSize: 31,
                      letterSpacing: 0.99,
                    ),
                    symbolStyle: kHeader3TextStyle.copyWith(
                      color: _color(context),
                      fontSize: 20,
                    ),
                  ),
                  HideableContainer(
                    hide: widget.errorText == null,
                    child: Transform.translate(
                      offset: const Offset(0, 1.5),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: SvgIcon(
                                    AppIcons.warningBulk,
                                    color: context.appTheme.negative,
                                    size: 18,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: widget.errorText ?? '',
                                style: kHeader3TextStyle.copyWith(
                                  color: context.appTheme.negative,
                                  fontSize: 13,
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 6,
                child: widget.suffix ?? Gap.noGap,
              ),
              Positioned(
                left: 6,
                child: widget.prefix != null
                    ? SvgIcon(
                        widget.prefix!,
                        color: _color(context),
                        size: 30,
                      )
                    : Gap.noGap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
