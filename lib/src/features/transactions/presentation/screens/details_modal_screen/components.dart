part of 'transaction_details_modal_screen.dart';

/////////////// SCREEN COMPONENTS /////////////////

class _Amount extends ConsumerWidget {
  const _Amount({
    required this.isEditMode,
    this.isEdited = false,
    required this.transactionType,
    required this.amount,
    this.onEditModeTap,
  });

  final bool isEditMode;
  final bool isEdited;
  final TransactionType transactionType;
  final double amount;
  final VoidCallback? onEditModeTap;

  Color _color(BuildContext context) {
    return switch (transactionType) {
      TransactionType.income => context.appTheme.positive,
      TransactionType.expense => context.appTheme.negative,
      TransactionType.transfer => context.appTheme.onBackground,
      TransactionType.creditSpending => context.appTheme.onBackground,
      TransactionType.creditPayment => context.appTheme.negative,
      TransactionType.creditCheckpoint => context.appTheme.onBackground,
      TransactionType.installmentToPay => context.appTheme.negative,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: _EditWrap(
        isEditMode: isEditMode,
        isEdited: isEdited,
        onTap: onEditModeTap,
        child: FittedBox(
          child: MoneyAmount(
            amount: amount,
            noAnimation: true,
            style: kHeader1TextStyle.copyWith(
              color: _color(context),
              fontSize: 40,
            ),
            symbolStyle: kHeader2TextStyle.copyWith(
              color: _color(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstallmentOfSpendingDetails extends StatelessWidget {
  const _InstallmentOfSpendingDetails({
    super.key,
    required this.isEditMode,
    required this.isEdited,
    this.installmentController,
    required this.transaction,
    required this.initialValues,
    required this.onToggle,
    required this.onFormattedInstallmentOutput,
    required this.onMonthOutput,
    required this.onChangePaymentStartFromNextStatement,
  });

  final bool isEditMode;
  final bool isEdited;
  final TextEditingController? installmentController;
  final CreditSpending transaction;

  /// index 0: [bool] - installmentToggle
  ///
  /// index 1: [double]? - installmentAmount
  ///
  /// index 2: [int]? - month to pay
  ///
  /// index 3: [bool]? - start payment from next statement
  final List<dynamic> initialValues;
  final ValueSetter<bool> onToggle;
  final ValueSetter<String> onFormattedInstallmentOutput;
  final ValueSetter<String> onMonthOutput;
  final ValueSetter<bool> onChangePaymentStartFromNextStatement;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _EditWrap(
        isEditMode: isEditMode,
        isEdited: isEdited,
        withPadding: true,
        child: AnimatedCrossFade(
            duration: k250msDuration,
            firstChild: Transform.translate(
              offset: const Offset(0, -5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CustomCheckbox(
                  initialValue: (initialValues[0] as bool),
                  label: context.loc.installmentPayment,
                  onChanged: onToggle,
                  optionalWidgetDecoration: false,
                  optionalWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InlineTextFormField(
                        prefixText: context.loc.installmentPeriod,
                        suffixText: context.loc.monthS,
                        onChanged: onMonthOutput,
                        hintText: initialValues[2] != null ? (initialValues[2] as int).toString() : '',
                      ),
                      Gap.h8,
                      InlineTextFormField(
                        prefixText: context.loc.amount,
                        suffixText: context.appSettings.currency.code,
                        widget: CalculatorInput(
                            controller: installmentController,
                            fontSize: 18,
                            isDense: true,
                            textAlign: TextAlign.end,
                            formattedResultOutput: onFormattedInstallmentOutput,
                            focusColor: context.appTheme.secondary1,
                            hintText: initialValues[1] != null
                                ? CalService.formatNumberInGroup((initialValues[1] as double).toString())
                                : ''),
                      ),
                      Gap.h12,
                      CustomCheckbox(
                        label: context.loc.startPaymentInNextStatement,
                        initialValue: (initialValues[3] as bool?) ?? transaction.paymentStartFromNextStatement,
                        onChanged: onChangePaymentStartFromNextStatement,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            secondChild: Container(
              child: transaction.hasInstallment
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          context.loc.installmentPaymentIn(transaction.monthsToPay.toString()),
                          style: kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Flexible(
                              child: TxnAmount(
                                transaction: transaction,
                                fontSize: 20,
                                color: context.appTheme.negative,
                                showPaymentAmount: true,
                              ),
                            ),
                            Text(
                              '/month'.hardcoded,
                              style: kHeader3TextStyle.copyWith(
                                fontSize: 16,
                                color: context.appTheme.onBackground,
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  : Text(
                      context.loc.payBeforeDueDate,
                      style: kHeader3TextStyle.copyWith(color: context.appTheme.negative, fontSize: 16),
                    ),
            ),
            crossFadeState: isEditMode ? CrossFadeState.showFirst : CrossFadeState.showSecond),
      ),
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({required this.isEditMode, this.isEdited = false, required this.dateTime, this.onEditModeTap});

  final bool isEditMode;
  final bool isEdited;
  final DateTime dateTime;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('00');
    return Center(
      child: _EditWrap(
        isEditMode: isEditMode,
        isEdited: isEdited,
        onTap: onEditModeTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              '${formatter.format(dateTime.hour)}:${formatter.format(dateTime.minute)}',
              style: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
            ),
            Gap.w8,
            Flexible(
              child: Text(
                dateTime.toLongDate(context),
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.isEditMode, this.isEdited = false, required this.account, this.onEditModeTap});
  final bool isEditMode;
  final bool isEdited;
  final BaseAccount account;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = account.backgroundColor.withOpacity(0.2).addDark(context.appTheme.isDarkTheme ? 0.2 : 0.0);

    return _EditWrap(
      isEditMode: isEditMode,
      isEdited: isEdited,
      onTap: onEditModeTap,
      withPadding: false,
      child: ClipRRect(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: bgColor.addDark(0.1)),
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgColor, bgColor.withOpacity(0)],
              stops: const [0, 0.8],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 1.0,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(-100.0, -20.0)
                    ..scale(5.0),
                  child: SvgIcon(
                    account.iconPath,
                    color: isEditMode ? account.backgroundColor.addDark(0.2) : account.backgroundColor.addDark(0.2),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account is CreditAccountInfo
                        ? context.loc.creditAccount.toUpperCase()
                        : account is SavingAccountInfo
                            ? context.loc.savingAccounts.toUpperCase()
                            : context.loc.account.toUpperCase(),
                    style:
                        kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 11),
                  ),
                  Gap.h4,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          account.name,
                          style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 20),
                        ),
                      ),
                      Gap.w48,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.isEditMode, this.isEdited = false, required this.category, this.categoryTag, this.onEditModeTap});

  final bool isEditMode;
  final bool isEdited;
  final Category category;
  final CategoryTag? categoryTag;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    return _EditWrap(
      isEditMode: isEditMode,
      isEdited: isEdited,
      onTap: onEditModeTap,
      withPadding: false,
      child: Container(
        decoration: BoxDecoration(
          border: isEditMode ? null : Border.all(color: AppColors.greyBorder(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATEGORY:',
              style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 11),
            ),
            Gap.h8,
            Row(
              children: [
                RoundedIconButton(
                  iconPath: category.iconPath,
                  size: 50,
                  iconPadding: 7,
                  backgroundColor: category.backgroundColor,
                  iconColor: category.iconColor,
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.name,
                        style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 20),
                      ),
                      categoryTag != null && categoryTag != CategoryTag.noTag
                          ? Row(
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, 1),
                                  child: SvgIcon(
                                    AppIcons.arrowBendDownLight,
                                    size: 20,
                                    color: context.appTheme.onBackground,
                                  ),
                                ),
                                Gap.w4,
                                Text(
                                  categoryTag!.name,
                                  style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 15),
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.isEditMode, this.isEdited = false, required this.note, this.onEditModeChanged});
  final bool isEditMode;
  final bool isEdited;
  final String? note;
  final void Function(String)? onEditModeChanged;

  @override
  Widget build(BuildContext context) {
    return _EditWrap(
      isEditMode: isEditMode,
      isEdited: isEdited,
      child: AnimatedOpacity(
        duration: k250msDuration,
        opacity: (note == null || note!.isEmpty) && !isEditMode ? 0 : 1,
        child: HideableContainer(
          hide: (note == null || note!.isEmpty) && !isEditMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'NOTE:',
                  style:
                      kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 11),
                ),
              ),
              Gap.h4,
              CustomTextFormField(
                autofocus: false,
                enabled: isEditMode,
                focusColor: context.appTheme.accent1,
                withOutlineBorder: true,
                hintText: 'Add note ...',
                initialValue: note,
                textInputAction: TextInputAction.done,
                onChanged: onEditModeChanged ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///////////// COMPONENTS FOR EDIT MODE ///////////

class _EditWrap extends StatelessWidget {
  const _EditWrap({
    required this.isEditMode,
    this.onTap,
    this.withPadding = true,
    this.isEdited = false,
    required this.child,
  });

  final bool isEditMode;
  final bool isEdited;
  final VoidCallback? onTap;
  final bool withPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final containerColor = context.appTheme.background0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: k250msDuration,
          curve: Curves.easeOut,
          margin: isEditMode ? const EdgeInsets.only(left: 4, right: 8, top: 8) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.appTheme.onBackground.withOpacity(isEditMode ? 0.15 : 0),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: CustomInkWell(
              onTap: isEditMode ? onTap : null,
              inkColor: AppColors.grey(context),
              borderRadius: BorderRadius.circular(7),
              child: AnimatedPadding(
                duration: k250msDuration,
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                    vertical: isEditMode && withPadding ? 4 : 0, horizontal: isEditMode && withPadding ? 6 : 0),
                child: child,
              ),
            ),
          ),
        ),
        Positioned(
          top: 1,
          right: -2,
          child: AnimatedOpacity(
            opacity: isEditMode ? 1 : 0,
            curve: Curves.easeOut,
            duration: k250msDuration,
            child: RoundedIconButton(
              iconPath: AppIcons.editLight,
              iconColor: isEdited ? context.appTheme.onNegative : context.appTheme.onAccent,
              backgroundColor: isEdited ? context.appTheme.negative : context.appTheme.accent2,
              size: 20,
              iconPadding: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.isEditMode, required this.onTap});

  final bool isEditMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final containerColor = context.appTheme.background0;

    return CardItem(
      width: 50,
      height: 50,
      color: containerColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      margin: EdgeInsets.zero,
      child: CustomInkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(1000),
        inkColor: context.appTheme.onBackground,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: k250msDuration,
              opacity: isEditMode ? 0 : 1,
              child: SvgIcon(
                AppIcons.editLight,
                color: context.appTheme.onBackground,
              ),
            ),
            AnimatedOpacity(
              duration: k250msDuration,
              opacity: isEditMode ? 1 : 0,
              child: SvgIcon(
                AppIcons.doneLight,
                color: context.appTheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton(
      {required this.isEditMode, required this.onConfirm, this.isDisable = false, this.disableText = ''});

  final bool isEditMode;
  final bool isDisable;
  final String disableText;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final containerColor = context.appTheme.background0;

    return CardItem(
      width: isEditMode ? 0 : 40,
      height: isEditMode ? 0 : 40,
      color: containerColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: CustomInkWell(
        onTap: () async {
          isDisable
              ? showErrorDialog(context, disableText)
              : showConfirmModal(
                  context: context,
                  label: context.loc.deleteTransactionConfirm1,
                  confirmLabel: 'Yes, delete'.hardcoded,
                  onConfirm: onConfirm,
                );
        },
        borderRadius: BorderRadius.circular(1000),
        inkColor: context.appTheme.onBackground,
        child: AnimatedOpacity(
          duration: k250msDuration,
          opacity: isEditMode ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              child: SvgIcon(
                AppIcons.deleteLight,
                color: context.appTheme.onBackground.withOpacity(isDisable ? 0.3 : 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////// SELECTORS /////////////////////////////////////

class _ModelWithIconEditSelector<T extends BaseModelWithIcon> extends StatelessWidget {
  const _ModelWithIconEditSelector({
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextHeader(title),
              Gap.h8,
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
                      borderRadius: BorderRadius.circular(8),
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
                iconPath: AppIcons.accountsBulk,
              ),
              withBottomGap ? Gap.h48 : Gap.noGap,
            ],
          );
  }
}

class _CategoryEditSelector extends ConsumerStatefulWidget {
  const _CategoryEditSelector({required this.transaction, required this.category, required this.tag});

  final BaseTransaction transaction;
  final Category? category;
  final CategoryTag? tag;

  @override
  ConsumerState<_CategoryEditSelector> createState() => _CategoryEditSelectorState();
}

class _CategoryEditSelectorState extends ConsumerState<_CategoryEditSelector> {
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
  void didUpdateWidget(covariant _CategoryEditSelector oldWidget) {
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
    return ModalContent(
      header: ModalHeader(
        title: context.loc.editCategory,
      ),
      body: [
        _ModelWithIconEditSelector(
          title: context.loc.chooseCategory,
          withBottomGap: false,
          list: _categoryList,
          selectedItem: _selectedCategory,
          onItemTap: (category) => setState(() {
            _selectedCategory = category;
            _selectedTag = CategoryTag.noTag;
          }),
        ),
        Gap.h16,
        TextHeader(context.loc.chooseTag),
        Gap.h16,
        CategoryTagSelector(
          category: _selectedCategory,
          initialChosenTag: _selectedTag,
          onTagSelected: (tag) => setState(() {
            _selectedTag = tag;
          }),
          onTagDeSelected: () => setState(() {
            _selectedTag = CategoryTag.noTag;
          }),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: false,
        bigButtonIcon: AppIcons.doneLight,
        bigButtonLabel: context.loc.done,
        onBigButtonTap: () => context.pop<List<dynamic>>([_selectedCategory, _selectedTag]),
      ),
    );
  }
}
