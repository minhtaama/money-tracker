import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../domain/account_base.dart';

class EditRegularAccountModalScreen extends ConsumerStatefulWidget {
  const EditRegularAccountModalScreen(this.regularAccount, {super.key});
  final RegularAccount regularAccount;

  @override
  ConsumerState<EditRegularAccountModalScreen> createState() => _EditRegularAccountModalScreenState();
}

class _EditRegularAccountModalScreenState extends ConsumerState<EditRegularAccountModalScreen> {
  late String newName;
  late String newIconCategory;
  late int newIconIndex;
  late int newColorIndex;

  @override
  void initState() {
    newName = widget.regularAccount.name;
    newIconCategory = widget.regularAccount.databaseObject.iconCategory;
    newIconIndex = widget.regularAccount.databaseObject.iconIndex;
    newColorIndex = widget.regularAccount.databaseObject.colorIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Edit credit account'.hardcoded,
      isWrapByCard: false,
      sections: [
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[newColorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[newColorIndex][1],
              initialIconCategory: widget.regularAccount.databaseObject.iconCategory,
              initialIconIndex: widget.regularAccount.databaseObject.iconIndex,
              onTap: (iconC, iconI) {
                newIconCategory = iconC;
                newIconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[newColorIndex][0],
                hintText: widget.regularAccount.name,
                onChanged: (value) {
                  newName = value;
                },
              ),
            ),
          ],
        ),
        Gap.h24,
        ColorSelectListView(
          initialColorIndex: widget.regularAccount.databaseObject.colorIndex,
          onColorTap: (index) {
            setState(() {
              newColorIndex = index;
            });
          },
        ),
        Gap.h24,
        Row(
          children: [
            RoundedIconButton(
              size: 55,
              iconPath: AppIcons.delete,
              iconPadding: 15,
              backgroundColor: AppColors.greyBgr(context),
              iconColor: context.appTheme.onBackground,
              onTap: () async {
                showConfirmModal(
                  context: context,
                  label: 'Are you sure that you want to delete account "${widget.regularAccount.name}"?'.hardcoded,
                  subLabel: '1 more confirmation to delete this account'.hardcoded,
                  onConfirm: () {
                    showConfirmModal(
                      context: context,
                      onlyIcon: true,
                      label: 'Transactions relate to this account will appear as of "deleted account".'.hardcoded,
                      subLabel: 'Last warning. Hold the delete button to confirm'.hardcoded,
                      onConfirm: () async {
                        context.go(RoutePath.accounts);
                        final accountRepo = ref.read(accountRepositoryProvider);
                        await Future.delayed(k550msDuration, () => accountRepo.delete(widget.regularAccount));
                      },
                    );
                  },
                );
              },
            ),
            const Spacer(),
            IconWithTextButton(
              iconPath: AppIcons.edit,
              label: 'Done',
              backgroundColor: context.appTheme.accent1,
              onTap: () {
                final accountRepo = ref.read(accountRepositoryProvider);

                accountRepo.editRegularAccount(
                  widget.regularAccount,
                  iconCategory: newIconCategory,
                  iconIndex: newIconIndex,
                  name: newName,
                  colorIndex: newColorIndex,
                );

                context.pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
