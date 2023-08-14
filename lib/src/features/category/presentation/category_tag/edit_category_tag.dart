import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../../common_widgets/custom_section.dart';
import '../../../../common_widgets/custom_text_form_field.dart';
import '../../../../common_widgets/icon_with_text_button.dart';
import '../../../../common_widgets/modal_bottom_sheets.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../data/category_repo.dart';
import '../../domain/category_isar.dart';
import '../../domain/category_tag_isar.dart';


class EditCategoryTag extends ConsumerStatefulWidget {
  const EditCategoryTag(this.tag, {Key? key, required this.category})
      : super(key: key);

  final CategoryTagIsar tag;
  final CategoryIsar category;

  @override
  ConsumerState<EditCategoryTag> createState() => _EditCategoryTagState();
}

class _EditCategoryTagState extends ConsumerState<EditCategoryTag> {
  final _formKey = GlobalKey<FormState>();

  late final categoryRepo = ref.watch(categoryRepositoryProvider);

  late final List<CategoryTagIsar> _tags =
      categoryRepo.getTagsSortedByOrder(widget.category)!;

  late String _newName = widget.tag.name;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Edit Tag',
        isWrapByCard: false,
        children: [
          CustomTextFormField(
            autofocus: false,
            focusColor: context.appTheme.primary,
            hintText: widget.tag.name,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 8, top: 2),
              child: Text(
                '#',
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative.withOpacity(0.5),
                  fontSize: 20,
                ),
              ),
            ),
            validator: (value) {
              if (_tags
                  .map((e) => e.name.toLowerCase())
                  .contains(value?.toLowerCase())) {
                return 'Already has same tag';
              }
              return null;
            },
            onChanged: (value) {
              _newName = value;
            },
          ),
          Gap.h24,
          Row(
            children: [
              RoundedIconButton(
                size: 55,
                iconPath: AppIcons.delete,
                iconPadding: 15,
                backgroundColor: AppColors.grey,
                iconColor: context.appTheme.backgroundNegative,
                onTap: () {
                  showConfirmModalBottomSheet(
                    context: context,
                    label:
                        'Are you sure that you want to delete tag "${widget.tag.name}"?',
                    onConfirm: () {
                      categoryRepo.deleteTag(widget.tag);
                      context.pop();
                    },
                  );
                },
              ),
              const Expanded(child: SizedBox()),
              IconWithTextButton(
                iconPath: AppIcons.edit,
                label: 'Done',
                backgroundColor: context.appTheme.accent,
                onTap: () async {
                  await categoryRepo.editTag(widget.tag, name: _newName);
                  if (mounted) {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
