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

  String get _iconPath {
    return switch (transactionType) {
      TransactionType.income => AppIcons.income,
      TransactionType.expense => AppIcons.expense,
      TransactionType.transfer => AppIcons.transfer,
      TransactionType.creditSpending => AppIcons.receiptDollar,
      TransactionType.creditPayment => AppIcons.handCoin,
      TransactionType.creditCheckpoint => AppIcons.receiptEdit,
      TransactionType.installmentToPay => AppIcons.installment,
    };
  }

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CardItem(
          height: 50,
          width: 50,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: EdgeInsets.zero,
          color: _color(context).withOpacity(0.2),
          borderRadius: BorderRadius.circular(1000),
          child: FittedBox(
            child: SvgIcon(
              _iconPath,
              color: _color(context),
            ),
          ),
        ),
        Gap.w16,
        Flexible(
          child: _NeumorphicEditWrap(
            isEditMode: isEditMode,
            isEdited: isEdited,
            onTap: onEditModeTap,
            child: FittedBox(
              child: MoneyAmount(
                amount: amount,
                noAnimation: true,
                style: kHeader1TextStyle.copyWith(
                  color: _color(context),
                ),
                symbolStyle: kHeader2TextStyle.copyWith(
                  color: _color(context),
                ),
              ),
            ),
          ),
        ),
      ],
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
    return _NeumorphicEditWrap(
      isEditMode: isEditMode,
      isEdited: isEdited,
      withPadding: true,
      child: AnimatedCrossFade(
          duration: k250msDuration,
          firstChild: Transform.translate(
            offset: const Offset(0, -5),
            child: CustomCheckbox(
              initialValue: (initialValues[0] as bool),
              label: 'Installment payment'.hardcoded,
              onChanged: onToggle,
              optionalWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InlineTextFormField(
                    prefixText: 'Payment Period:'.hardcoded,
                    suffixText: 'month(s)'.hardcoded,
                    onChanged: onMonthOutput,
                    hintText: initialValues[2] != null ? (initialValues[2] as int).toString() : '',
                  ),
                  Gap.h8,
                  InlineTextFormField(
                    prefixText: 'Amount:'.hardcoded,
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
                  Gap.h8,
                  CustomCheckbox(
                    label: 'Payment start from next statement',
                    initialValue: (initialValues[3] as bool?) ?? transaction.paymentStartFromNextStatement,
                    onChanged: onChangePaymentStartFromNextStatement,
                  ),
                ],
              ),
            ),
          ),
          secondChild: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Gap.w12,
                RoundedIconButton(
                  iconPath: transaction.hasInstallment ? AppIcons.installment : AppIcons.handCoin,
                  backgroundColor: Colors.transparent,
                  iconColor: context.appTheme.negative,
                  iconPadding: 0,
                  size: 26,
                ),
                Gap.w12,
                transaction.hasInstallment
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installment payment in ${transaction.monthsToPay} months'.hardcoded,
                            style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                          ),
                          Gap.h2,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              TxnAmount(
                                transaction: transaction,
                                fontSize: 18,
                                color: context.appTheme.negative,
                                showPaymentAmount: true,
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
                        'Pay before due date'.hardcoded,
                        style: kHeader3TextStyle.copyWith(color: context.appTheme.negative, fontSize: 16),
                      ),
              ],
            ),
          ),
          crossFadeState: isEditMode ? CrossFadeState.showFirst : CrossFadeState.showSecond),
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
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: _NeumorphicEditWrap(
        isEditMode: isEditMode,
        isEdited: isEdited,
        onTap: onEditModeTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${formatter.format(dateTime.hour)}:${formatter.format(dateTime.minute)}',
              style: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 13),
            ),
            Gap.w8,
            Flexible(
              child: Text(
                dateTime.toLongDate(context),
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 13),
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

    return _NeumorphicEditWrap(
      isEditMode: isEditMode,
      isEdited: isEdited,
      onTap: onEditModeTap,
      withPadding: false,
      child: ClipRRect(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: bgColor.addDark(0.1)),
            borderRadius: BorderRadius.circular(16),
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
                    account is CreditAccountInfo ? 'CREDIT ACCOUNT:' : 'ACCOUNT:',
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
    return _NeumorphicEditWrap(
      isEditMode: isEditMode,
      isEdited: isEdited,
      onTap: onEditModeTap,
      withPadding: false,
      child: Container(
        decoration: BoxDecoration(
          border: isEditMode ? null : Border.all(color: AppColors.greyBorder(context)),
          borderRadius: BorderRadius.circular(16),
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
                          ? Text(
                              '# ${categoryTag!.name}',
                              style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 15),
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
    return _NeumorphicEditWrap(
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

class _NeumorphicEditWrap extends StatelessWidget {
  const _NeumorphicEditWrap({
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
    final topLeftShadow = context.appTheme.isDarkTheme ? context.appTheme.background0.addWhite(0.04) : AppColors.white;
    final bottomRightShadow = context.appTheme.isDarkTheme ? AppColors.black : context.appTheme.onBackground;
    final containerColor = context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;

    return Stack(
      children: [
        AnimatedContainer(
          duration: k250msDuration,
          curve: Curves.easeOut,
          padding: isEditMode && withPadding ? const EdgeInsets.symmetric(vertical: 4, horizontal: 6) : EdgeInsets.zero,
          margin: isEditMode ? const EdgeInsets.only(left: 4, right: 8, top: 8) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isEditMode
                    ? bottomRightShadow.withOpacity(context.appTheme.isDarkTheme ? 0.6 : 0.2)
                    : bottomRightShadow.withOpacity(0),
                offset: const Offset(3, 3),
                blurRadius: 8,
              ),
              BoxShadow(
                color: isEditMode ? topLeftShadow.withOpacity(0.8) : topLeftShadow.withOpacity(0),
                offset: const Offset(-4, -4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: CustomInkWell(
              onTap: isEditMode ? onTap : null,
              inkColor: AppColors.grey(context),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedPadding(
                duration: k250msDuration,
                curve: Curves.easeOut,
                padding: isEditMode && withPadding
                    ? const EdgeInsets.symmetric(vertical: 4, horizontal: 6)
                    : EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
        ),
        Positioned(
          top: 1,
          right: 4,
          child: AnimatedOpacity(
            opacity: isEditMode ? 1 : 0,
            curve: Curves.easeOut,
            duration: k250msDuration,
            child: RoundedIconButton(
              iconPath: AppIcons.edit,
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

class _NeumorphicEditCardWrap extends StatelessWidget {
  const _NeumorphicEditCardWrap(
      {required this.isEditMode,
      this.isEdited = false,
      this.onTap,
      required this.backgroundColor,
      required this.child});
  final bool isEditMode;
  final bool isEdited;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topLeftShadow = context.appTheme.isDarkTheme ? context.appTheme.background0.addWhite(0.04) : AppColors.white;
    final bottomRightShadow = context.appTheme.isDarkTheme ? AppColors.black : context.appTheme.onBackground;
    final bgEditColor = context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Stack(
        children: [
          CardItem(
            margin: isEditMode ? const EdgeInsets.only(left: 4, right: 8, top: 8) : EdgeInsets.zero,
            elevation: 0,
            padding: EdgeInsets.zero,
            color: isEditMode ? bgEditColor : backgroundColor.addDark(context.appTheme.isDarkTheme ? 0.3 : 0.0),
            boxShadow: [
              BoxShadow(
                color: isEditMode
                    ? bottomRightShadow.withOpacity(context.appTheme.isDarkTheme ? 0.6 : 0.2)
                    : bottomRightShadow.withOpacity(0),
                offset: const Offset(3, 3),
                blurRadius: 8,
              ),
              BoxShadow(
                color: isEditMode ? topLeftShadow.withOpacity(0.8) : topLeftShadow.withOpacity(0),
                offset: const Offset(-4, -4),
                blurRadius: 4,
              ),
            ],
            constraints: const BoxConstraints(minHeight: 65, minWidth: double.infinity),
            child: CustomInkWell(
              onTap: isEditMode ? onTap : null,
              inkColor: AppColors.grey(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: child,
              ),
            ),
          ),
          Positioned(
            top: 1,
            right: 4,
            child: AnimatedOpacity(
              opacity: isEditMode ? 1 : 0,
              duration: k250msDuration,
              curve: Curves.easeOut,
              child: RoundedIconButton(
                iconPath: AppIcons.edit,
                iconColor: isEdited ? context.appTheme.onNegative : context.appTheme.onAccent,
                backgroundColor: isEdited ? context.appTheme.negative : context.appTheme.accent2,
                size: 20,
                iconPadding: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.isEditMode, required this.onTap});

  final bool isEditMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topLeftShadow = context.appTheme.isDarkTheme ? context.appTheme.background0.addWhite(0.04) : AppColors.white;
    final bottomRightShadow = context.appTheme.isDarkTheme ? AppColors.black : context.appTheme.onBackground;
    final containerColor = context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;

    return CardItem(
      width: isEditMode ? 75 : 40,
      height: 40,
      borderRadius: BorderRadius.circular(isEditMode ? 16 : 100),
      color: containerColor,
      elevation: 0,
      boxShadow: [
        BoxShadow(
          color: isEditMode
              ? bottomRightShadow.withOpacity(context.appTheme.isDarkTheme ? 0.6 : 0.2)
              : bottomRightShadow.withOpacity(0),
          offset: const Offset(3, 3),
          blurRadius: 8,
        ),
        BoxShadow(
          color: isEditMode ? topLeftShadow.withOpacity(0.8) : topLeftShadow.withOpacity(0),
          offset: const Offset(-4, -4),
          blurRadius: 4,
        ),
      ],
      padding: isEditMode ? const EdgeInsets.symmetric(vertical: 4, horizontal: 4) : EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: CustomInkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        inkColor: context.appTheme.onBackground,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: k250msDuration,
              opacity: isEditMode ? 0 : 1,
              child: FittedBox(
                child: SvgIcon(
                  AppIcons.edit,
                  color: context.appTheme.onBackground,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: k250msDuration,
              opacity: isEditMode ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: SvgIcon(
                          AppIcons.edit,
                          color: context.appTheme.onBackground,
                        ),
                      ),
                      Gap.w8,
                      Text(
                        'DONE',
                        style: kHeader2TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
    final containerColor = context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;

    return CardItem(
      width: isEditMode ? 0 : 40,
      height: isEditMode ? 0 : 40,
      color: containerColor,
      elevation: 0,
      margin: EdgeInsets.only(left: isEditMode ? 0 : 6),
      padding: EdgeInsets.zero,
      child: CustomInkWell(
        onTap: () async {
          isDisable
              ? showErrorDialog(context, disableText)
              : showConfirmModal(
                  context: context,
                  label: 'Delete this transaction?'.hardcoded,
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
                AppIcons.delete,
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
        title: 'Edit Category'.hardcoded,
      ),
      body: [
        _ModelWithIconEditSelector(
          title: 'Change Category:'.hardcoded,
          withBottomGap: false,
          list: _categoryList,
          selectedItem: _selectedCategory,
          onItemTap: (category) => setState(() {
            _selectedCategory = category;
            _selectedTag = CategoryTag.noTag;
          }),
        ),
        Gap.h16,
        TextHeader('Change Tag:'.hardcoded),
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
        bigButtonIcon: AppIcons.done,
        bigButtonLabel: context.loc.done,
        onBigButtonTap: () => context.pop<List<dynamic>>([_selectedCategory, _selectedTag]),
      ),
    );
  }
}
