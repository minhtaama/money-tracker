import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/edit_category_tag.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/custom_text_form_field.dart';
import '../../domain/category_tag.dart';

class CategoryTagSelector extends ConsumerStatefulWidget {
  const CategoryTagSelector(
      {super.key,
      this.category,
      required this.onTagSelected,
      this.onTagDeSelected,
      this.fading,
      this.initialChosenTag});
  final Color? fading;
  final ValueSetter<CategoryTag?> onTagSelected;

  /// Optional callback when de-select a tag
  final VoidCallback? onTagDeSelected;
  final Category? category;
  final CategoryTag? initialChosenTag;

  @override
  ConsumerState<CategoryTagSelector> createState() => _CategoryTagSelectorState();
}

class _CategoryTagSelectorState extends ConsumerState<CategoryTagSelector> {
  late final categoryRepo = ref.watch(categoryRepositoryRealmProvider);

  final _key = GlobalKey();

  late final FocusNode _focusNode = FocusNode();

  late Category? _currentCategory = widget.category;

  late List<CategoryTag>? _tags = categoryRepo.getTagList(_currentCategory);

  late CategoryTag? _chosenTag =
      widget.initialChosenTag == CategoryTag.noTag ? null : widget.initialChosenTag;

  late bool _showTextField = _tags == null || _tags!.isEmpty;

  @override
  void initState() {
    _focusNode.addListener(_listener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoryTagSelector oldWidget) {
    if (widget.category != oldWidget.category) {
      _currentCategory = widget.category;
      _tags = categoryRepo.getTagList(_currentCategory);
      _showTextField = _tags == null || _tags!.isEmpty;
    }

    if (widget.initialChosenTag != oldWidget.initialChosenTag && widget.initialChosenTag != null) {
      _chosenTag = widget.initialChosenTag == CategoryTag.noTag ? null : widget.initialChosenTag;
    } else if (_currentCategory == null || _currentCategory != oldWidget.category) {
      _chosenTag = null;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_listener);
    _focusNode.dispose();
    super.dispose();
  }

  void _listener() {
    if (_focusNode.hasPrimaryFocus) {
      setState(() {
        _showTextField = true;
      });
    } else {
      setState(() {
        _showTextField = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoryTagsChangesRealmProvider(_currentCategory)).whenData((_) {
      _tags = categoryRepo.getTagList(_currentCategory);
    });

    return LayoutBuilder(builder: (context, constraint) {
      return Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            key: _key,
            children: [
              _tags != null && widget.category != null
                  ? Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ShaderMask(
                          shaderCallback: (Rect rect) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                widget.fading ?? context.appTheme.background1,
                                Colors.transparent,
                                Colors.transparent,
                                widget.fading ?? context.appTheme.background1
                              ],
                              stops: const [0.0, 0.03, 0.97, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstOut,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(
                              _tags!.length,
                              (index) {
                                return CategoryTagWidget(
                                  categoryTag: _tags![index],
                                  onTap: (tag) {
                                    categoryRepo.reorderTagToTop(widget.category!, index);
                                    setState(
                                      () {
                                        _chosenTag = tag;
                                        _tags = categoryRepo.getTagList(widget.category!);
                                        widget.onTagSelected(_chosenTag);
                                      },
                                    );
                                  },
                                  onLongPress: (tag) => showCustomModal(
                                    context: context,
                                    child: EditCategoryTag(
                                      tag,
                                      category: widget.category!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                  : Gap.noGap,
              AnimatedContainer(
                duration: k250msDuration,
                curve: Curves.easeOut,
                width: _tags == null || _currentCategory == null || _tags!.isEmpty || _showTextField
                    ? constraint.maxWidth
                    : _chosenTag != null
                        ? 0
                        : 50,
                child: ClipRect(
                  child: AddCategoryTagButton(
                      focusNode: _focusNode,
                      category: widget.category,
                      onEditingComplete: (tag) {
                        categoryRepo.reorderTagToTop(widget.category!, _tags!.length - 1);
                        setState(
                          () {
                            _chosenTag = tag;
                            _tags = categoryRepo.getTagList(widget.category!);
                            widget.onTagSelected(_chosenTag);
                          },
                        );
                      }),
                ),
              ),
            ],
          ),
          CardItem(
            width: _chosenTag != null ? constraint.maxWidth : 0,
            height: 50,
            elevation: 0,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(horizontal: _chosenTag != null ? 12 : 0),
            color: _currentCategory?.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: _ChosenTag(
                    chosenTag: _chosenTag?.name,
                    category: _currentCategory,
                  ),
                ),
                Flexible(
                  child: RoundedIconButton(
                    iconPath: AppIcons.closeLight,
                    iconColor: context.appTheme.isDarkTheme
                        ? context.appTheme.onSecondary
                        : context.appTheme.onPrimary,
                    backgroundColor: Colors.transparent,
                    size: 35,
                    iconPadding: 7,
                    onTap: () {
                      setState(() {
                        _chosenTag = null;
                      });
                      widget.onTagDeSelected?.call();
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ChosenTag extends StatelessWidget {
  const _ChosenTag({
    this.chosenTag,
    required this.category,
  });

  final String? chosenTag;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    return Text(
      chosenTag != null ? chosenTag! : '',
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: kHeader2TextStyle.copyWith(
        color: category?.iconColor,
        fontSize: 18,
      ),
    );
  }
}

class CategoryTagWidget extends StatelessWidget {
  const CategoryTagWidget(
      {super.key, required this.categoryTag, required this.onTap, required this.onLongPress});
  final CategoryTag categoryTag;
  final ValueSetter<CategoryTag> onTap;
  final ValueSetter<CategoryTag> onLongPress;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 175, minHeight: 35),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: CustomInkWell(
            inkColor: AppColors.greyBgr(context),
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(categoryTag),
            onLongPress: () => onLongPress(categoryTag),
            child: CardItem(
              elevation: 0,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.greyBgr(context),
              alignment: Alignment.center,
              child: Text(
                categoryTag.name,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddCategoryTagButton extends ConsumerStatefulWidget {
  const AddCategoryTagButton(
      {super.key, this.focusNode, this.category, required this.onEditingComplete});
  final FocusNode? focusNode;
  final Category? category;
  final ValueSetter<CategoryTag> onEditingComplete;

  @override
  ConsumerState<AddCategoryTagButton> createState() => _AddCategoryTagButtonState();
}

class _AddCategoryTagButtonState extends ConsumerState<AddCategoryTagButton> {
  late final TextEditingController _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late final categoryRepo = ref.read(categoryRepositoryRealmProvider);

  late List<CategoryTag>? _tags = categoryRepo.getTagList(widget.category);

  String? _newTag;

  @override
  void didUpdateWidget(covariant AddCategoryTagButton oldWidget) {
    _tags = categoryRepo.getTagList(widget.category);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomTextFormField(
        autofocus: false,
        focusNode: widget.focusNode,
        focusColor: context.appTheme.primary,
        controller: _controller,
        withOutlineBorder: true,
        enabled: widget.category == null || widget.category is DeletedCategory ? false : true,
        maxLength: 40,
        maxLines: 1,
        hintText: widget.category == null || widget.category is DeletedCategory
            ? context.loc.chooseCategoryFirst
            : context.loc.addNewCategoryTag,
        validator: (value) {
          if (_tags != null && _tags!.map((e) => e.name.toLowerCase()).contains(value?.toLowerCase())) {
            return context.loc.alreadyHasSameTag;
          }
          return null;
        },
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8, bottom: 2),
          child: SvgIcon(
            AppIcons.addLight,
            color: context.appTheme.onBackground.withOpacity(widget.category == null ? 0.2 : 0.5),
          ),
        ),
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          _newTag = value;
        },
        onTapOutside: () {
          _newTag = null;
          _controller.text = '';
        },
        onEditingComplete: () {
          if (widget.category != null && _newTag != null && _formKey.currentState!.validate()) {
            final categoryRepo = ref.read(categoryRepositoryRealmProvider);

            CategoryTag? newTag = categoryRepo.writeNewTag(name: _newTag!, category: widget.category!);

            categoryRepo.reorderTagToTop(
                widget.category!, categoryRepo.getTagList(widget.category)!.length - 1);

            widget.onEditingComplete(newTag!);

            _newTag = null;
            _controller.text = '';
          }
          if (!_formKey.currentState!.validate()) {
            _newTag = null;
            _controller.text = '';
          }
        },
      ),
    );
  }
}
