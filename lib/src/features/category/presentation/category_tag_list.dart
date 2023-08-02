import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_text_form_field.dart';
import '../domain/category_isar.dart';

class CategoryTagList extends StatefulWidget {
  const CategoryTagList({Key? key, this.category, required this.onCreate, this.fading})
      : super(key: key);
  final Color? fading;
  final VoidCallback onCreate;
  final CategoryIsar? category;

  @override
  State<CategoryTagList> createState() => _CategoryTagListState();
}

class _CategoryTagListState extends State<CategoryTagList> {
  final _key = GlobalKey();

  late final List<String>? _tags = widget.category?.tags;
  // late final List<String>? _tags = ['Hello', 'How are you?', 'Im fine thank you'];
  late final FocusNode _focusNode = FocusNode();

  bool _showTextField = false;
  double _rowWidth = 1;

  String? _newTag;

  String? _chosenTag;

  @override
  void initState() {
    _focusNode.addListener(_listener);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _rowWidth = _key.currentContext!.size!.width;
    });
    super.initState();
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      key: _key,
      children: [
        AnimatedContainer(
          duration: k250msDuration,
          curve: Curves.easeOut,
          width: _chosenTag != null ? _rowWidth : 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _chosenTag = null;
              });
            },
            child: CardItem(
              elevation: 0,
              margin: EdgeInsets.zero,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: context.appTheme.primary.withOpacity(0.8),
              alignment: Alignment.center,
              child: Text(
                _chosenTag != null ? '# $_chosenTag' : '',
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: kHeader1TextStyle.copyWith(
                  color: context.appTheme.primaryNegative,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    widget.fading ?? context.appTheme.background,
                    Colors.transparent,
                    Colors.transparent,
                    widget.fading ?? context.appTheme.background
                  ],
                  stops: const [0.0, 0.03, 0.97, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _tags != null
                    ? List.generate(
                        _tags!.length,
                        (index) => CategoryTag(
                          name: _tags![index],
                          onTap: (tag) {
                            setState(() {
                              _chosenTag = tag;
                            });
                          },
                        ),
                      )
                    : [],
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: k250msDuration,
          width: _showTextField || _chosenTag != null || _tags == null ? 0 : 16,
          height: 25,
          child: _showTextField || _chosenTag != null || _tags == null ? null : const VerticalDivider(),
        ),
        //TODO: Add callbacks
        AnimatedContainer(
          duration: k250msDuration,
          curve: Curves.easeOut,
          width: _tags == null
              ? _rowWidth
              : _showTextField
                  ? _rowWidth
                  : _chosenTag != null
                      ? 0
                      : 50,
          child: ClipRect(
            child: CustomTextFormField(
              autofocus: false,
              focusNode: _focusNode,
              focusColor: context.appTheme.accent,
              withOutlineBorder: true,
              maxLength: 40,
              maxLines: 1,
              hintText: 'New category tag ...',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 8, bottom: 2),
                child: SvgIcon(
                  AppIcons.add,
                  color: context.appTheme.backgroundNegative.withOpacity(0.5),
                ),
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                _newTag = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryTag extends StatelessWidget {
  const CategoryTag({Key? key, required this.name, required this.onTap}) : super(key: key);
  final String name;
  final ValueSetter<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 175),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: GestureDetector(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 10));
              onTap(name);
            },
            child: CardItem(
              elevation: 0,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.grey.withOpacity(0.15),
              alignment: Alignment.center,
              child: Text(
                '# $name',
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative.withOpacity(0.5),
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
