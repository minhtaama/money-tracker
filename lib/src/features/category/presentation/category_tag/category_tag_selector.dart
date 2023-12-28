import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
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
  const CategoryTagSelector({Key? key, this.category, required this.onTagSelected, this.fading}) : super(key: key);
  final Color? fading;
  final ValueSetter<CategoryTag?> onTagSelected;
  final Category? category;

  @override
  ConsumerState<CategoryTagSelector> createState() => _CategoryTagListState();
}

class _CategoryTagListState extends ConsumerState<CategoryTagSelector> {
  late final categoryRepo = ref.watch(categoryRepositoryRealmProvider);

  final _key = GlobalKey();

  late final FocusNode _focusNode = FocusNode();

  late Category? currentCategory = widget.category;

  late List<CategoryTag>? _tags = categoryRepo.getTagList(currentCategory);

  CategoryTag? _chosenTag;

  late bool _showTextField = _tags == null || _tags!.isEmpty;
  double _rowWidth = 1;

  @override
  void initState() {
    _focusNode.addListener(_listener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _rowWidth = _key.currentContext!.size!.width;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoryTagSelector oldWidget) {
    currentCategory = widget.category;
    _tags = categoryRepo.getTagList(currentCategory);
    _showTextField = _tags == null || _tags!.isEmpty;
    if (currentCategory == null) {
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
    ref.watch(categoryTagsChangesRealmProvider(currentCategory)).whenData((_) {
      _tags = categoryRepo.getTagList(currentCategory);
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      key: _key,
      children: [
        AnimatedContainer(
          duration: k250msDuration,
          curve: Curves.easeOut,
          width: _chosenTag != null ? _rowWidth : 0,
          child: CardItem(
            elevation: 0,
            margin: EdgeInsets.zero,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: context.appTheme.isDarkTheme
                ? context.appTheme.secondary500.withOpacity(0.8)
                : context.appTheme.primary,
            child: Row(
              children: [
                Expanded(
                  child: ChosenTag(chosenTag: _chosenTag?.name),
                ),
                AnimatedContainer(
                  duration: k250msDuration,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: _chosenTag != null ? 30 : 0,
                  child: FittedBox(
                    clipBehavior: Clip.antiAlias,
                    child: RoundedIconButton(
                      iconPath: AppIcons.close,
                      iconColor:
                          context.appTheme.isDarkTheme ? context.appTheme.onSecondary : context.appTheme.onPrimary,
                      backgroundColor: Colors.transparent,
                      iconPadding: 7,
                      onTap: () {
                        setState(() {
                          _chosenTag = null;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
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
                          widget.fading ?? context.appTheme.background500,
                          Colors.transparent,
                          Colors.transparent,
                          widget.fading ?? context.appTheme.background500
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
                            onLongPress: (tag) => showCustomModalBottomSheet(
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
          width: _showTextField || _chosenTag != null || _tags == null || currentCategory == null || _tags!.isEmpty
              ? 0
              : 16,
          height: 25,
          child: _showTextField || _chosenTag != null || _tags == null || currentCategory == null
              ? null
              : Gap.verticalDivider(context),
        ),
        AnimatedContainer(
          duration: k250msDuration,
          curve: Curves.easeOut,
          width: _tags == null || currentCategory == null || _tags!.isEmpty || _showTextField
              ? _rowWidth
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
    );
  }
}

class ChosenTag extends StatelessWidget {
  const ChosenTag({
    super.key,
    required String? chosenTag,
  }) : _chosenTag = chosenTag;

  final String? _chosenTag;

  @override
  Widget build(BuildContext context) {
    return EasyRichText(
      _chosenTag != null ? '# $_chosenTag' : '',
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      defaultStyle: kHeader2TextStyle.copyWith(
        color: context.appTheme.isDarkTheme ? context.appTheme.onSecondary : context.appTheme.onPrimary,
        fontSize: 18,
      ),
      patternList: [
        EasyRichTextPattern(
          targetString: '#',
          hasSpecialCharacters: true,
          style: kHeader4TextStyle.copyWith(
            color: context.appTheme.isDarkTheme ? context.appTheme.onSecondary : context.appTheme.onPrimary,
            fontSize: 18,
          ),
        )
      ],
    );
  }
}

class CategoryTagWidget extends StatelessWidget {
  const CategoryTagWidget({Key? key, required this.categoryTag, required this.onTap, required this.onLongPress})
      : super(key: key);
  final CategoryTag categoryTag;
  final ValueSetter<CategoryTag> onTap;
  final ValueSetter<CategoryTag> onLongPress;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 175),
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
              child: EasyRichText(
                '# ${categoryTag.name}',
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                defaultStyle: kHeader2TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.5),
                  fontSize: 13,
                ),
                patternList: [
                  EasyRichTextPattern(
                    targetString: '#',
                    hasSpecialCharacters: true,
                    style: kHeader4TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddCategoryTagButton extends ConsumerStatefulWidget {
  const AddCategoryTagButton({Key? key, this.focusNode, this.category, required this.onEditingComplete})
      : super(key: key);
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
        enabled: widget.category == null ? false : true,
        maxLength: 40,
        maxLines: 1,
        hintText: widget.category == null ? 'Choose a category first' : 'New category tag ...',
        validator: (value) {
          if (_tags != null && _tags!.map((e) => e.name.toLowerCase()).contains(value?.toLowerCase())) {
            return 'Already has same tag';
          }
          return null;
        },
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8, bottom: 2),
          child: SvgIcon(
            AppIcons.add,
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

            categoryRepo.reorderTagToTop(widget.category!, categoryRepo.getTagList(widget.category)!.length - 1);

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
