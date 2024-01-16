part of 'transaction_details_modal_screen.dart';

/////////////// SCREEN COMPONENTS /////////////////

class _Amount extends ConsumerWidget {
  const _Amount({
    required this.isEditMode,
    required this.transactionType,
    required this.amount,
    this.onEditModeTap,
  });

  final bool isEditMode;
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
    };
  }

  Color _color(BuildContext context) {
    return switch (transactionType) {
      TransactionType.income => context.appTheme.positive,
      TransactionType.expense => context.appTheme.negative,
      TransactionType.transfer => context.appTheme.onBackground,
      TransactionType.creditSpending => context.appTheme.negative,
      TransactionType.creditPayment => context.appTheme.negative,
      TransactionType.creditCheckpoint => AppColors.grey(context),
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
            onTap: onEditModeTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CalService.formatCurrency(context, amount),
                  style: kHeader1TextStyle.copyWith(
                    color: _color(context),
                  ),
                ),
                Gap.w8,
                Text(
                  context.appSettings.currency.code,
                  style: kHeader4TextStyle.copyWith(color: _color(context), fontSize: kHeader1TextStyle.fontSize),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({required this.isEditMode, required this.dateTime, this.onEditModeTap});

  final bool isEditMode;
  final DateTime dateTime;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: _NeumorphicEditWrap(
        isEditMode: isEditMode,
        onTap: onEditModeTap,
        child: Row(
          children: [
            Text(
              '${dateTime.hour}:${dateTime.minute}',
              style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.onBackground, fontSize: kHeader4TextStyle.fontSize),
            ),
            Gap.w8,
            Text(
              dateTime.getFormattedDate(format: DateTimeFormat.mmmmddyyyy),
              style: kHeader4TextStyle.copyWith(
                color: context.appTheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.isEditMode, required this.account, this.onEditModeTap});
  final bool isEditMode;
  final Account account;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    return _NeumorphicEditCardWrap(
      isEditMode: isEditMode,
      onTap: onEditModeTap,
      backgroundColor: account.backgroundColor,
      child: Stack(
        children: [
          Positioned(
            right: 1.0,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(-120.0, -30.0)
                ..scale(7.0),
              child: SvgIcon(
                account.iconPath,
                color: isEditMode ? account.backgroundColor.withOpacity(0.55) : account.iconColor.withOpacity(0.55),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account is CreditAccount ? 'CREDIT ACCOUNT:' : 'ACCOUNT:',
                style: kHeader2TextStyle.copyWith(
                    color: isEditMode
                        ? context.appTheme.onBackground.withOpacity(0.6)
                        : account.iconColor.withOpacity(0.6),
                    fontSize: 11),
              ),
              Gap.h4,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      account.name,
                      style: kHeader2TextStyle.copyWith(
                          color: isEditMode ? context.appTheme.onBackground : account.iconColor, fontSize: 20),
                    ),
                  ),
                  Gap.w48,
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.isEditMode, required this.category, this.categoryTag, this.onEditModeTap});

  final bool isEditMode;
  final Category category;
  final CategoryTag? categoryTag;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    return _NeumorphicEditCardWrap(
      isEditMode: isEditMode,
      onTap: onEditModeTap,
      backgroundColor: category.backgroundColor.withOpacity(0.35),
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
                    categoryTag != null
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
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.isEditMode, required this.note, this.onEditModeTap});
  final bool isEditMode;
  final String note;
  final VoidCallback? onEditModeTap;

  @override
  Widget build(BuildContext context) {
    return _NeumorphicEditWrap(
      isEditMode: isEditMode,
      onTap: onEditModeTap,
      withPadding: false,
      child: CardItem(
        color: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        border: isEditMode ? null : Border.all(color: context.appTheme.onBackground.withOpacity(0.5)),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOTE:',
              style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 11),
            ),
            Gap.h4,
            Text(
              note,
              style: kHeader4TextStyle.copyWith(
                color: context.appTheme.onBackground,
                fontSize: 16,
              ),
            ),
          ],
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
    required this.child,
  });

  final bool isEditMode;
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
                padding: isEditMode ? const EdgeInsets.symmetric(vertical: 4, horizontal: 6) : EdgeInsets.zero,
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
              iconColor: context.appTheme.onAccent,
              backgroundColor: context.appTheme.accent2,
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
      {required this.isEditMode, this.onTap, required this.backgroundColor, required this.child});
  final bool isEditMode;
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
                iconColor: context.appTheme.onAccent,
                backgroundColor: context.appTheme.accent2,
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

class _ModelWithIconSelector<T extends BaseModelWithIcon> extends StatelessWidget {
  const _ModelWithIconSelector(
      {super.key, required this.title, required this.isDisable, this.selectedItem, required this.list});

  final String title;
  final List<T> list;
  final T? selectedItem;
  final bool Function(T element) isDisable;

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
                    ignoring: isDisable(element),
                    child: IconWithTextButton(
                      iconPath: element.iconPath,
                      label: element.name,
                      isDisabled: isDisable(element),
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
                      onTap: () => selectedItem == element ? context.pop<T>(null) : context.pop<T>(element),
                      height: null,
                      width: null,
                    ),
                  );
                }),
              ),
              Gap.h32,
              Gap.h32,
            ],
          )
        : Column(
            children: [
              Gap.h8,
              IconWithText(
                header: 'No account.\n Tap here to create a first one'.hardcoded,
                headerSize: 14,
                iconPath: AppIcons.accounts,
                onTap: () {
                  context.pop();
                  context.push(RoutePath.addAccount);
                },
              ),
              Gap.h48,
            ],
          );
  }
}
