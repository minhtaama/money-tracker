import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/txn_components.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_section.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../category/domain/category.dart';
import '../../domain/transaction_base.dart';

class TransactionDetailsModalScreen extends ConsumerStatefulWidget {
  const TransactionDetailsModalScreen({super.key, required this.objectIdHexString});

  final String objectIdHexString;

  @override
  ConsumerState<TransactionDetailsModalScreen> createState() => _TransactionDetailsModalScreenState();
}

class _TransactionDetailsModalScreenState extends ConsumerState<TransactionDetailsModalScreen> {
  bool _isEditMode = false;

  late BaseTransaction _transaction;

  @override
  void initState() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    _transaction = txnRepo.getTransaction(widget.objectIdHexString);
    super.initState();
  }

  String get _title {
    return switch (_transaction) {
      Income() => (_transaction as Income).isInitialTransaction ? 'Initial Balance'.hardcoded : 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
      CreditSpending() => 'Credit Spending'.hardcoded,
      CreditPayment() => 'Credit Payment'.hardcoded,
      CreditCheckpoint() => 'Credit Checkpoint'.hardcoded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: _title,
      subTitle: _DateTime(isEditMode: _isEditMode, transaction: _transaction),
      subIcons: _EditButton(
        isEditMode: _isEditMode,
        onTap: () => setState(() {
          _isEditMode = !_isEditMode;
        }),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(isEditMode: _isEditMode, transaction: _transaction),
        Gap.h8,
        _transaction is CreditSpending ? Gap.h8 : Gap.noGap,
        Gap.divider(context, indent: 6),
        Row(
          children: [
            _transaction is Transfer
                ? const TxnTransferLine(
                    height: 100,
                    width: 30,
                    strokeWidth: 1.5,
                    opacity: 0.5,
                  )
                : Gap.noGap,
            _transaction is Transfer ? Gap.w4 : Gap.noGap,
            Expanded(
              child: Column(
                children: [
                  _AccountCard(isEditMode: _isEditMode, model: _transaction.account!),
                  switch (_transaction) {
                    IBaseTransactionWithCategory() =>
                      _transaction is Income && (_transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              isEditMode: _isEditMode,
                              model: (_transaction as IBaseTransactionWithCategory).category!,
                              categoryTag: (_transaction as IBaseTransactionWithCategory).categoryTag,
                            ),
                    Transfer() =>
                      _AccountCard(isEditMode: _isEditMode, model: (_transaction as Transfer).transferAccount!),
                    CreditPayment() || CreditCheckpoint() => Gap.noGap,
                  },
                ],
              ),
            ),
          ],
        ),
        _transaction.note != null ? _Note(isEditMode: _isEditMode, note: _transaction.note!) : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}

/////////////// SCREEN COMPONENTS /////////////////

class _Amount extends ConsumerWidget {
  const _Amount({required this.isEditMode, required this.transaction});

  final bool isEditMode;
  final BaseTransaction transaction;

  String get _iconPath {
    return switch (transaction) {
      Income() => AppIcons.download,
      Expense() => AppIcons.upload,
      Transfer() => AppIcons.transfer,
      CreditSpending() => AppIcons.upload,
      CreditPayment() => AppIcons.upload,
      CreditCheckpoint() => AppIcons.transfer
    };
  }

  Color _color(BuildContext context) {
    return switch (transaction) {
      Income() => context.appTheme.positive,
      Expense() => context.appTheme.negative,
      Transfer() => context.appTheme.onBackground,
      CreditSpending() => context.appTheme.negative,
      CreditPayment() => context.appTheme.negative,
      CreditCheckpoint() => AppColors.grey(context),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CalService.formatCurrency(context, transaction.amount),
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
  const _DateTime({required this.isEditMode, required this.transaction});

  final bool isEditMode;
  final BaseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: _NeumorphicEditWrap(
        isEditMode: isEditMode,
        onTap: () => print('tapped'),
        child: Row(
          children: [
            Text(
              '${transaction.dateTime.hour}:${transaction.dateTime.minute}',
              style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.onBackground, fontSize: kHeader4TextStyle.fontSize),
            ),
            Gap.w8,
            Text(
              transaction.dateTime.getFormattedDate(format: DateTimeFormat.mmmmddyyyy),
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
  const _AccountCard({required this.isEditMode, required this.model});
  final bool isEditMode;
  final Account model;

  @override
  Widget build(BuildContext context) {
    return _NeumorphicEditCardWrap(
      isEditMode: isEditMode,
      onTap: () => print('tapped'),
      backgroundColor: model.backgroundColor,
      child: Stack(
        children: [
          Positioned(
            right: 1.0,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(-120.0, -30.0)
                ..scale(7.0),
              child: SvgIcon(
                model.iconPath,
                color: isEditMode ? model.backgroundColor.withOpacity(0.55) : model.iconColor.withOpacity(0.55),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model is CreditAccount ? 'CREDIT ACCOUNT:' : 'ACCOUNT:',
                style: kHeader2TextStyle.copyWith(
                    color:
                        isEditMode ? context.appTheme.onBackground.withOpacity(0.6) : model.iconColor.withOpacity(0.6),
                    fontSize: 11),
              ),
              Gap.h4,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      model.name,
                      style: kHeader2TextStyle.copyWith(
                          color: isEditMode ? context.appTheme.onBackground : model.iconColor, fontSize: 20),
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
  const _CategoryCard({required this.isEditMode, required this.model, this.categoryTag});

  final bool isEditMode;
  final Category model;
  final CategoryTag? categoryTag;

  @override
  Widget build(BuildContext context) {
    return _NeumorphicEditCardWrap(
      isEditMode: isEditMode,
      backgroundColor: model.backgroundColor.withOpacity(0.35),
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
                iconPath: model.iconPath,
                size: 50,
                iconPadding: 7,
                backgroundColor: model.backgroundColor,
                iconColor: model.iconColor,
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model.name,
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
  const _Note({required this.isEditMode, required this.note});
  final bool isEditMode;
  final String note;

  @override
  Widget build(BuildContext context) {
    return _NeumorphicEditWrap(
      isEditMode: isEditMode,
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
