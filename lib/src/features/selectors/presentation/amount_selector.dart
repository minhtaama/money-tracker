import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
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
  });

  final ValueChanged<double> onChanged;
  final TransactionType transactionType;
  final double? initialValue;
  final bool isCentered;
  final Widget? suffix;

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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.appTheme.onBackground.withOpacity(0.45),
            ),
          ),
        ),
        child: CustomInkWell(
          inkColor: context.appTheme.onBackground,
          onTap: _changeAmount,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment:
                    widget.isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  MoneyAmount(
                    amount: _currentAmount ?? 0,
                    noAnimation: true,
                    style: kHeader1TextStyle.copyWith(
                      color: _color(context),
                      fontSize: 40,
                    ),
                    symbolStyle: kHeader2TextStyle.copyWith(
                      color: _color(context),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.suffix ??
                      SvgIcon(
                        AppIcons.editLight,
                        color: _color(context),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
