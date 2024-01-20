part of 'transaction_details_modal_screen.dart';

class _ModelWithIconSelector<T extends BaseModelWithIcon> extends StatelessWidget {
  const _ModelWithIconSelector({
    super.key,
    required this.title,
    this.isDisable,
    this.selectedItem,
    required this.list,
    this.onItemTap,
    this.withBottomGap = true,
  });

  final String title;
  final List<T> list;
  final T? selectedItem;
  final bool Function(T element)? isDisable;
  final ValueSetter<T>? onItemTap;
  final bool withBottomGap;

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap.h16,
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  title,
                  style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground),
                ),
              ),
              Gap.h16,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(list.length, (index) {
                  final element = list[index];
                  return IgnorePointer(
                    ignoring: isDisable != null ? isDisable!(element) : false,
                    child: IconWithTextButton(
                      iconPath: element.iconPath,
                      label: element.name,
                      isDisabled: isDisable != null ? isDisable!(element) : false,
                      labelSize: 18,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: Border.all(
                        color: selectedItem == element
                            ? element.backgroundColor
                            : context.appTheme.onBackground.withOpacity(0.4),
                      ),
                      backgroundColor: selectedItem == element ? element.backgroundColor : Colors.transparent,
                      color: selectedItem == element ? element.iconColor : context.appTheme.onBackground,
                      inkColor: element.backgroundColor,
                      onTap: onItemTap != null
                          ? () => onItemTap?.call(element)
                          : () => selectedItem == element ? context.pop<T>(null) : context.pop<T>(element),
                      height: null,
                      width: null,
                    ),
                  );
                }),
              ),
              withBottomGap ? Gap.h32 : Gap.noGap,
              withBottomGap ? Gap.h32 : Gap.noGap,
            ],
          )
        : Column(
            children: [
              Gap.h8,
              IconWithText(
                header: 'No data'.hardcoded,
                headerSize: 14,
                iconPath: AppIcons.accounts,
              ),
              withBottomGap ? Gap.h48 : Gap.noGap,
            ],
          );
  }
}

class _CategorySelector extends ConsumerStatefulWidget {
  const _CategorySelector({super.key, required this.transaction, required this.category, required this.tag});

  final BaseTransaction transaction;
  final Category? category;
  final CategoryTag? tag;

  @override
  ConsumerState<_CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<_CategorySelector> {
  late Category? _selectedCategory = widget.category;
  late CategoryTag? _selectedTag = widget.tag;

  late final _categoryType = switch (widget.transaction) {
    Expense() || CreditSpending() => CategoryType.expense,
    Income() => CategoryType.income,
    CreditCheckpoint() ||
    Transfer() ||
    CreditPayment() =>
      throw StateError('Can not call this function with this type'),
  };

  late final _categoryList = ref.read(categoryRepositoryRealmProvider).getList(_categoryType);

  @override
  void didUpdateWidget(covariant _CategorySelector oldWidget) {
    if (widget.category != oldWidget.category) {
      _selectedCategory = widget.category;
    }
    if (widget.tag != oldWidget.tag) {
      _selectedTag = widget.tag;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelWithIconSelector(
          title: 'Choose Category:'.hardcoded,
          withBottomGap: false,
          list: _categoryList,
          selectedItem: _selectedCategory,
          onItemTap: (category) => setState(() {
            _selectedCategory = category;
            _selectedTag = null;
          }),
        ),
        Gap.h16,
        Text(
          'Choose Tag:'.hardcoded,
          style: kHeader2TextStyle,
        ),
        Gap.h16,
        CategoryTagSelector(
          category: _selectedCategory,
          initialChosenTag: _selectedTag,
          onTagSelected: (tag) => setState(() {
            _selectedTag = tag;
          }),
        ),
        Gap.h24,
        Row(
          children: [
            const Spacer(),
            IconWithTextButton(
              iconPath: AppIcons.done,
              label: 'Done',
              backgroundColor: context.appTheme.accent2,
              color: context.appTheme.onAccent,
              height: 55,
              width: 130,
              onTap: () => context.pop<List<dynamic>>([_selectedCategory, _selectedTag]),
            ),
          ],
        ),
        Gap.h32,
      ],
    );
  }
}
