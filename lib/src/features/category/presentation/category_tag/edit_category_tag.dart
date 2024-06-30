import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/custom_text_form_field.dart';
import '../../../../common_widgets/modal_and_dialog.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../data/category_repo.dart';
import '../../domain/category_tag.dart';

class EditCategoryTag extends ConsumerStatefulWidget {
  const EditCategoryTag(this.tag, {super.key, required this.category});

  final CategoryTag tag;
  final Category category;

  @override
  ConsumerState<EditCategoryTag> createState() => _EditCategoryTagState();
}

class _EditCategoryTagState extends ConsumerState<EditCategoryTag> {
  final _formKey = GlobalKey<FormState>();

  late final categoryRepo = ref.watch(categoryRepositoryRealmProvider);

  late final List<CategoryTag> _tags = categoryRepo.getTagList(widget.category)!;

  late String _newName = widget.tag.name;

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      formKey: _formKey,
      header: ModalHeader(
        title: context.loc.editTag,
      ),
      body: [
        CustomTextFormField(
          autofocus: false,
          focusColor: context.appTheme.primary,
          hintText: widget.tag.name,
          textInputAction: TextInputAction.done,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8, top: 2),
            child: Text(
              '#',
              style: kHeader3TextStyle.copyWith(
                color: context.appTheme.onBackground.withOpacity(0.5),
                fontSize: 20,
              ),
            ),
          ),
          validator: (value) {
            if (_tags.map((e) => e.name.toLowerCase()).contains(value?.toLowerCase())) {
              return context.loc.alreadyHasSameTag;
            }
            return null;
          },
          onChanged: (value) {
            _newName = value;
          },
        ),
      ],
      footer: ModalFooter(
        smallButtonIcon: AppIcons.deleteBulk,
        onSmallButtonTap: () {
          showConfirmModal(
            context: context,
            label: context.loc.areYouSureToDeleteTag(widget.tag.name),
            onConfirm: () {
              categoryRepo.deleteTag(widget.tag);
              context.pop();
            },
          );
        },
        onBigButtonTap: () {
          categoryRepo.editTag(widget.tag, name: _newName);
          context.pop();
        },
        isBigButtonDisabled: false,
      ),
    );
  }
}
