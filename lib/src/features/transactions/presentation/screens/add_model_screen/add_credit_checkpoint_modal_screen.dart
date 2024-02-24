import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/help_box.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/checkpoint_installments_list.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/inline_text_form_field.dart';
import '../../../../accounts/domain/account_base.dart';
import '../../../../accounts/domain/statement/base_class/statement.dart';
import '../../../../calculator_input/presentation/calculator_input.dart';
import '../../../../selectors/presentation/date_time_selector/date_time_selector.dart';

class AddCreditCheckpointModalScreen extends ConsumerStatefulWidget {
  const AddCreditCheckpointModalScreen({super.key, required this.account});

  final CreditAccount account;

  @override
  ConsumerState<AddCreditCheckpointModalScreen> createState() => _AddCreditCheckpointModalScreenState();
}

class _AddCreditCheckpointModalScreenState extends ConsumerState<AddCreditCheckpointModalScreen> {
  final _formKey = GlobalKey<FormState>();

  late Statement? _statement;

  double _unpaidInstallmentsAmount = 0;

  ////////////////////// OUTPUT TO DATABASE VALUE ///////////////////////
  late DateTime _dateTime;

  List<Installment> _finishedInstallments = [];

  late final CreditAccount _creditAccount = widget.account;

  double? get _outputAmount => CalService.formatToDouble(_calOutputFormattedAmount);
  ///////////////////////////////////////////////////////////////////////

  String _calOutputFormattedAmount = '0';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _dateTime = DateTime.now().copyWith(day: _creditAccount.statementDay, month: DateTime.now().month + 1);
    _statement = _creditAccount.statementAt(_dateTime);
    super.initState();
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditCheckpoint(
          dateTime: _dateTime,
          amount: _outputAmount!,
          account: _creditAccount,
          finishedInstallments: _finishedInstallments.map((e) => e.txn).toList());
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Checkpoint',
        crossAxisAlignment: CrossAxisAlignment.start,
        isWrapByCard: false,
        sectionsClipping: false,
        sections: [
          HelpBox(
            isShow: true,
            iconPath: AppIcons.fykFace,
            header: 'For your knowledge'.hardcoded,
            text: 'Add [transactions has installment payment going through this checkpoint] first, if any.'.hardcoded,
          ),
          Gap.h8,
          Row(
            children: [
              Text(
                'Checkpoint at:',
                style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
              ),
              DateSelector(
                initial: _dateTime,
                selectableDayPredicate: (dateTime) => dateTime.day == _creditAccount.statementDay,
                onChanged: (dateTime) {
                  setState(() {
                    _dateTime = dateTime;
                    _statement = _creditAccount.statementAt(_dateTime);
                  });
                },
                labelBuilder: (dateTime) {
                  return dateTime != null ? dateTime.getFormattedDate() : '--';
                },
              ),
            ],
          ),
          Gap.h8,
          InlineTextFormField(
            prefixText: 'Oustd. Balance:',
            suffixText: context.appSettings.currency.code,
            widget: CalculatorInput(
              fontSize: 18,
              isDense: true,
              textAlign: TextAlign.end,
              focusColor: context.appTheme.secondary1,
              hintText: '',
              initialValue: '0',
              validator: (_) => _oustdBalanceValidator(),
              formattedResultOutput: (value) => _calOutputFormattedAmount = value,
            ),
          ),
          Gap.h16,
          _statement != null
              ? CheckpointInstallmentsList(
                  statement: _statement!,
                  onMarkAsDone: (list, totalUnpaid) {
                    _finishedInstallments = List.from(list);
                    _unpaidInstallmentsAmount = totalUnpaid;
                  },
                )
              : Gap.noGap,
          Gap.h24,
          BottomButtons(isBigButtonDisabled: _isButtonDisable, onBigButtonTap: _submit)
        ],
      ),
    );
  }
}

extension _Validators on _AddCreditCheckpointModalScreenState {
  bool get _isButtonDisable =>
      CalService.formatToDouble(_calOutputFormattedAmount) == null ||
      CalService.formatToDouble(_calOutputFormattedAmount) == 0;

  String? _oustdBalanceValidator() {
    if (CalService.formatToDouble(_calOutputFormattedAmount)! < _unpaidInstallmentsAmount.roundBySetting(context)) {
      return 'Must higher than unpaid installments amount'.hardcoded;
    }

    return null;
  }
}
