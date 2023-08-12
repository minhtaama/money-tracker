import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/custom_section.dart';
import '../../../common_widgets/custom_text_form_field.dart';
import '../../../common_widgets/icon_with_text_button.dart';
import '../../../common_widgets/modal_bottom_sheets.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../data/category_repo.dart';
import '../domain/category_isar.dart';

class EditCategoryTag extends ConsumerStatefulWidget {
  const EditCategoryTag({Key? key, required this.category, required this.index}) : super(key: key);
  final CategoryIsar category;
  final int index;

  @override
  ConsumerState<EditCategoryTag> createState() => _EditCategoryTagState();
}

class _EditCategoryTagState extends ConsumerState<EditCategoryTag> {
  late String newTag = widget.category.tags[widget.index]!;

  late final List<String> _tags = widget.category.tags.whereType<String>().toList();

  final _formKey = GlobalKey<FormState>();

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
            hintText: widget.category.tags[widget.index]!,
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
              if (_tags.map((e) => e.toLowerCase()).contains(value?.toLowerCase())) {
                return 'Already has same tag';
              }
              return null;
            },
            onChanged: (value) {
              newTag = value;
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
                        'Are you sure that you want to delete tag "${widget.category.tags[widget.index]!}"?',
                    onConfirm: () {
                      final categoryRepo = ref.read(categoryRepositoryProvider);
                      //categoryRepository.delete(widget.currentCategory);
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
                  final categoryRepository = ref.read(categoryRepositoryProvider);
                  // await categoryRepository.edit(
                  //   widget.currentCategory,
                  //   iconCategory: newIconCategory,
                  //   iconIndex: newIconIndex,
                  //   name: newName,
                  //   colorIndex: newColorIndex,
                  // );
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
