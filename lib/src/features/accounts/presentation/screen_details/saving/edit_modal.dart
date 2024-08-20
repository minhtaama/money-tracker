import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/inline_text_form_field.dart';
import '../../../../calculator_input/application/calculator_service.dart';
import '../../../../calculator_input/presentation/calculator_input.dart';
import '../../../../selectors/presentation/date_time_selector/date_time_selector.dart';
import '../../../domain/account_base.dart';

class EditSavingModalScreen extends ConsumerStatefulWidget {
  const EditSavingModalScreen(this.savingAccount, {super.key});
  final SavingAccount savingAccount;

  @override
  ConsumerState<EditSavingModalScreen> createState() => _EditRegularAccountModalScreenState();
}

class _EditRegularAccountModalScreenState extends ConsumerState<EditSavingModalScreen> {
  late String _newName;
  late String _newIconCategory;
  late int _newIconIndex;
  late int _newColorIndex;

  late String _calculatorOutput = '';
  late DateTime? _targetSavingDate;

  @override
  void initState() {
    _newName = widget.savingAccount.name;
    _newIconCategory = widget.savingAccount.databaseObject.iconCategory;
    _newIconIndex = widget.savingAccount.databaseObject.iconIndex;
    _newColorIndex = widget.savingAccount.databaseObject.colorIndex;
    _targetSavingDate = widget.savingAccount.targetDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      header: ModalHeader(
        title: context.loc.editSavingAccount,
      ),
      body: [
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[_newColorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[_newColorIndex][1],
              initialIconCategory: widget.savingAccount.databaseObject.iconCategory,
              initialIconIndex: widget.savingAccount.databaseObject.iconIndex,
              onTap: (iconC, iconI) {
                _newIconCategory = iconC;
                _newIconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[_newColorIndex][0],
                hintText: widget.savingAccount.name,
                onChanged: (value) {
                  _newName = value;
                },
              ),
            ),
          ],
        ),
        Gap.h24,
        ColorSelectListView(
          initialColorIndex: widget.savingAccount.databaseObject.colorIndex,
          onColorTap: (index) {
            setState(() {
              _newColorIndex = index;
            });
          },
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyBorder(context)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap.h8,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InlineTextFormField(
                  prefixText: 'Target amount:'.hardcoded,
                  suffixText: context.appSettings.currency.code,
                  widget: CalculatorInput(
                    fontSize: 18,
                    isDense: true,
                    textAlign: TextAlign.end,
                    formattedResultOutput: (value) => _calculatorOutput = value,
                    focusColor: context.appTheme.secondary1,
                    hintText: CalService.formatNumberInGroup(widget.savingAccount.targetAmount.toString()),
                    title: context.loc.saving,
                  ),
                ),
              ),
              Gap.h16,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Target date:',
                      style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
                    ),
                    DateSelector(
                      initial: _targetSavingDate,
                      selectableDayPredicate: (date) => date.isAfter(DateTime.now()),
                      onChangedNullable: (dateTime) {
                        setState(() {
                          _targetSavingDate = dateTime;
                        });
                      },
                      labelBuilder: (dateTime) {
                        return dateTime != null ? 'Until ${dateTime.toShortDate(context)}' : 'No target date';
                      },
                    ),
                  ],
                ),
              ),
              Gap.h8,
            ],
          ),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: false,
        smallButtonIcon: AppIcons.deleteLight,
        bigButtonIcon: AppIcons.doneLight,
        bigButtonLabel: context.loc.done,
        onSmallButtonTap: () async {
          showConfirmModal(
            context: context,
            label: context.loc.areYouSureToDeleteRegularAccount1(widget.savingAccount.name),
            subLabel: context.loc.deleteAccountConfirm1,
            onConfirm: () {
              showConfirmModal(
                context: context,
                label: context.loc.areYouSureToDeleteRegularAccount2,
                subLabel: context.loc.deleteAccountConfirm2,
                onConfirm: () async {
                  context.pop();
                  final accountRepo = ref.read(accountRepositoryProvider);
                  await Future.delayed(k550msDuration, () => accountRepo.delete(widget.savingAccount));
                },
              );
            },
          );
        },
        onBigButtonTap: () {
          final accountRepo = ref.read(accountRepositoryProvider);

          accountRepo.editSavingAccount(
            widget.savingAccount,
            iconCategory: _newIconCategory,
            iconIndex: _newIconIndex,
            name: _newName,
            colorIndex: _newColorIndex,
            targetAmount: CalService.formatToDouble(_calculatorOutput),
            targetDate: () => _targetSavingDate,
          );

          context.pop();
        },
      ),
    );
  }
}
