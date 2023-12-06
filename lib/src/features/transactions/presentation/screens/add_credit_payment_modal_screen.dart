import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/credit_payment_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../accounts/domain/statement/statement.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../selectors/forms.dart';

class AddCreditPaymentModalScreen extends ConsumerStatefulWidget {
  const AddCreditPaymentModalScreen({super.key});

  @override
  ConsumerState<AddCreditPaymentModalScreen> createState() => _AddCreditPaymentModalScreenState();
}

class _AddCreditPaymentModalScreenState extends ConsumerState<AddCreditPaymentModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  Statement? _statement;

  ////////////////////// VALUE OUTPUT TO DATABASE /////////////////////////
  DateTime? _dateTime;
  String? _note;

  CreditAccount? _creditAccount;
  RegularAccount? _fromRegularAccount;

  double? get _outputAmount => CalService.formatToDouble(_calOutputFormattedAmount);

  //TODO: CONTINUE HERE!!!!!

  CreditPaymentType _type = CreditPaymentType.underMinimum;
  double? _adjustedBalance;
  ///////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Credit Payment',
        crossAxisAlignment: CrossAxisAlignment.start,
        isWrapByCard: false,
        sectionsClipping: false,
        sections: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CreditDateTimeFormSelector(
                  creditAccount: _creditAccount,
                  disableText: 'Choose credit account first'.hardcoded,
                  initialDate: _dateTime,
                  isForPayment: true,
                  onChanged: (dateTime, statement) {
                    if (dateTime != null) {
                      _dateTime = dateTime;
                    }
                    _statement = statement;
                    setState(() {});
                  },
                  validator: (_) => _dateTimeValidator(),
                ),
              ),
              Gap.w24,
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextHeader('Pay to credit account:'.hardcoded),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.credit,
                      validator: (_) => _creditAccountValidator(),
                      onChangedAccount: (newAccount) {
                        setState(() {
                          _creditAccount = newAccount as CreditAccount?;
                          if (_creditAccount == null) {
                            _statement = null;
                            _dateTime = null;
                          }
                        });
                      },
                    ),
                    Gap.h8,
                    const TextHeader('Payment account:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.regular,
                      validator: (_) => _fromRegularAccountValidator(),
                      onChangedAccount: (newAccount) {
                        setState(() {
                          _fromRegularAccount = newAccount as RegularAccount;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          !_hidePayment ? Gap.h16 : Gap.noGap,
          HideableContainer(
            hidden: _hidePayment,
            child: Column(
              children: [
                CreditInfo(
                  isForPayment: true,
                  chosenDateTime: _dateTime?.onlyYearMonthDay,
                  noBorder: false,
                  statement: _statement,
                ),
                Gap.h16,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CurrencyIcon(),
                    Gap.w16,
                    Expanded(
                      child: CalculatorInput(
                        hintText: 'Payment Amount',
                        controller: _controller,
                        focusColor: context.appTheme.primary,
                        validator: (_) => _calculatorValidator(context),
                        formattedResultOutput: (value) {
                          setState(() {
                            _controller.text = value;
                          });
                        },
                      ),
                    ),
                    Gap.w8,
                  ],
                ),
                Gap.h16,
              ],
            ),
          ),
          _statement != null
              ? _PaymentAmountInfo(
                  statement: _statement,
                  minimumPayment: 150,
                  onChange: (value) {
                    print(value);
                  },
                  // onMinimumPaymentTap: () {},
                  // onFullPaymentTap: () {
                  //   _controller.text = _fullPaymentFormattedAmount(context);
                  // },
                )
              : Gap.noGap,
          Gap.h16,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'OPTIONAL:',
              style: kHeader2TextStyle.copyWith(
                fontSize: 11,
                color: context.appTheme.backgroundNegative.withOpacity(0.4),
              ),
            ),
          ),
          Gap.h4,
          CustomTextFormField(
            autofocus: false,
            focusColor: context.appTheme.accent,
            withOutlineBorder: true,
            maxLines: 3,
            hintText: 'Note ...',
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              _note = value;
            },
          ),
          Gap.h16,
          BottomButtons(isBigButtonDisabled: _isButtonDisable, onBigButtonTap: _submit)
        ],
      ),
    );
  }
}

extension _FunctionsAndGetters on _AddCreditPaymentModalScreenState {
  bool get _hidePayment => _statement == null;

  String get _calOutputFormattedAmount => _controller.text;

  double get _fullPaymentAmount =>
      _statement == null || _dateTime == null ? 0 : _statement!.getFullPaymentAmountAt(_dateTime!);

  String _fullPaymentFormattedAmount(BuildContext context) =>
      CalService.formatCurrency(context, _fullPaymentAmount, forceWithDecimalDigits: true);

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditPayment(
            dateTime: _dateTime!,
            amount: _outputAmount!,
            account: _creditAccount!,
            fromAccount: _fromRegularAccount!,
            note: _note,
            type: _type,
            adjustedBalance: _adjustedBalance,
          );
      context.pop();
    }
  }
}

extension _Validators on _AddCreditPaymentModalScreenState {
  bool get _isButtonDisable =>
      CalService.formatToDouble(_calOutputFormattedAmount) == null ||
      CalService.formatToDouble(_calOutputFormattedAmount) == 0 ||
      _fromRegularAccount == null;

  String? _dateTimeValidator() {
    if (_dateTime == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _calculatorValidator(BuildContext context) {
    if (_outputAmount == null || _outputAmount == 0) {
      return 'Invalid amount'.hardcoded;
    }
    if (_statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }
    // if (_outputAmount! > CalService.formatToDouble(_fullPaymentFormattedAmount(context))!) {
    //   return 'Value is higher than full payment amount'.hardcoded;
    // }
    return null;
  }

  String? _creditAccountValidator() {
    if (_creditAccount == null) {
      return 'Must specify a credit account';
    }
    return null;
  }

  String? _fromRegularAccountValidator() {
    if (_fromRegularAccount == null) {
      return 'Must be specify for payment';
    }
    return null;
  }
}

class _PaymentAmountInfo extends StatefulWidget {
  const _PaymentAmountInfo({
    required this.statement,
    required this.minimumPayment,
    required this.onChange,
  });
  final Statement? statement;
  final double minimumPayment;
  final ValueSetter<CreditPaymentType> onChange;

  @override
  State<_PaymentAmountInfo> createState() => _PaymentAmountInfoState();
}

class _PaymentAmountInfoState extends State<_PaymentAmountInfo> {
  final _ancestorKey = GlobalKey();
  final _firstKey = GlobalKey();
  final _middleKey = GlobalKey();
  final _lastKey = GlobalKey();

  Offset _containerOffset = Offset.zero;
  double _containerWidth = 0;
  double _containerWidthAtFirst = 0;
  double _containerWidthAtMiddle = 0;
  double _animatedContainerWidth = 0;

  CreditPaymentType? _type;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        RenderBox ancestorRenderBox = _ancestorKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox firstRenderBox = _firstKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox middleRenderBox = _middleKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox lastRenderBox = _lastKey.currentContext?.findRenderObject() as RenderBox;

        Offset firstOffset = firstRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);
        Offset middleOffset = middleRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);
        Offset lastOffset = lastRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);

        setState(() {
          _containerOffset = Offset(0, firstOffset.dy).translate(0.3, 0);
          _containerWidth = lastOffset.dx - _containerOffset.dx + 35 - 0.3;
          _containerWidthAtFirst = firstOffset.dx - _containerOffset.dx + 35 - 0.3;
          _containerWidthAtMiddle = middleOffset.dx - _containerOffset.dx + 35 - 0.3;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          key: _ancestorKey,
          alignment: Alignment.topLeft,
          children: [
            Positioned(
              top: _containerOffset.dy,
              left: _containerOffset.dx,
              child: Container(
                height: 35,
                width: _containerWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: AppColors.grey(context).withOpacity(0.6),
                ),
              ),
            ),
            Positioned(
              top: _containerOffset.dy,
              left: _containerOffset.dx,
              child: AnimatedContainer(
                duration: k150msDuration,
                height: 35,
                width: _animatedContainerWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: context.appTheme.primary.withOpacity(0.55),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Button(
                    iconKey: _firstKey,
                    iconPath: AppIcons.minus,
                    label: '< Min',
                    isSelected: _type != null,
                    onTap: () {
                      setState(() {
                        _animatedContainerWidth = _containerWidthAtFirst;
                        _type = CreditPaymentType.underMinimum;
                        widget.onChange(_type!);
                      });
                    },
                  ),
                  _Button(
                    iconKey: _middleKey,
                    iconPath: AppIcons.installment,
                    label: '≥ Min',
                    isSelected: _type == CreditPaymentType.minimumOrHigher || _type == CreditPaymentType.full,
                    onTap: () {
                      setState(() {
                        _animatedContainerWidth = _containerWidthAtMiddle;
                        _type = CreditPaymentType.minimumOrHigher;
                        widget.onChange(_type!);
                      });
                    },
                  ),
                  _Button(
                    iconKey: _lastKey,
                    iconPath: AppIcons.done,
                    label: 'Full',
                    isSelected: _type == CreditPaymentType.full,
                    onTap: () {
                      setState(() {
                        _animatedContainerWidth = _containerWidth;
                        _type = CreditPaymentType.full;
                        widget.onChange(_type!);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Button extends StatefulWidget {
  const _Button({
    this.iconKey,
    required this.iconPath,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.isDisable = false,
  });
  final Key? iconKey;
  final String iconPath;
  final String label;
  final bool isSelected;
  final bool isDisable;
  final VoidCallback? onTap;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool _isSelected = false;
  bool _isDisable = false;

  @override
  void didUpdateWidget(covariant _Button oldWidget) {
    setState(() {
      _isSelected = widget.isSelected;
      _isDisable = widget.isDisable;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInkWell(
          key: widget.iconKey,
          onTap: _isDisable ? null : widget.onTap,
          child: AnimatedContainer(
            duration: k250msDuration,
            curve: Curves.easeInOut,
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: _isSelected
                  ? context.appTheme.primary.withOpacity(_isDisable ? 0.7 : 1)
                  : AppColors.greyBgr(context).withOpacity(_isDisable ? 0.7 : 1),
            ),
            child: SvgIcon(
              widget.iconPath,
              color: _isSelected
                  ? context.appTheme.primaryNegative.withOpacity(_isDisable ? 0.3 : 1)
                  : context.appTheme.backgroundNegative.withOpacity(_isDisable ? 0.3 : 1),
            ),
          ),
        ),
        Gap.h4,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 50),
          child: Text(
            widget.label,
            style: kHeader2TextStyle.copyWith(
                fontSize: 11, color: context.appTheme.backgroundNegative.withOpacity(_isDisable ? 0.3 : 1)),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
