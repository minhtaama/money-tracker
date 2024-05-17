import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'dart:math' as math;
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../domain/transaction_base.dart';

class TxnHomeCategoryIcon extends StatelessWidget {
  const TxnHomeCategoryIcon({super.key, required this.transaction, this.size});

  final BaseTransaction transaction;
  final double? size;

  @override
  Widget build(BuildContext context) {
    Color color() {
      if (transaction is IBaseTransactionWithCategory) {
        if (transaction is Income && (transaction as Income).isInitialTransaction) {
          return AppColors.greyBgr(context);
        }
        return (transaction as IBaseTransactionWithCategory).category.backgroundColor;
      }

      return AppColors.greyBgr(context);
    }

    Widget? child() {
      if (transaction is IBaseTransactionWithCategory) {
        if (transaction is Income && (transaction as Income).isInitialTransaction) {
          return SvgIcon(
            AppIcons.add,
            color: context.appTheme.onBackground,
          );
        }
        return SvgIcon(
          (transaction as IBaseTransactionWithCategory).category.iconPath,
          color: (transaction as IBaseTransactionWithCategory).category.iconColor,
        );
      }

      if (transaction is Transfer) {
        return SvgIcon(
          AppIcons.transfer,
          color: context.appTheme.onBackground,
        );
      }

      if (transaction is CreditPayment) {
        return SvgIcon(
          AppIcons.handCoin,
          color: context.appTheme.onBackground,
        );
      }

      return null;
    }

    return Container(
      height: size ?? 32,
      width: size ?? 32,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color(),
        borderRadius: BorderRadius.circular(100),
      ),
      child: child(),
    );
  }
}

class TxnInstallmentIcon extends StatelessWidget {
  const TxnInstallmentIcon({
    super.key,
    this.size = 18,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return HelpButton(
      title: 'Installment Payment'.hardcoded,
      text:
          'This transaction has been registered for installment payments, so you won\'t have to pay in this statement cycle; instead, you only need to settle the installment amount from next statement cycle.'
              .hardcoded,
      iconPath: AppIcons.installment,
      size: size,
    );
  }
}

class TxnAdjustmentIcon extends StatelessWidget {
  const TxnAdjustmentIcon({
    super.key,
    this.size = 18,
    required this.transaction,
  });

  final double size;
  final CreditPayment transaction;

  bool _showIcon(BuildContext context) {
    if (context.appSettings.showDecimalDigits) {
      if (transaction.adjustment.roundBySetting(context) == 0.00) {
        return false;
      }
    } else {
      if (transaction.adjustment.roundBySetting(context) == 0) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _showIcon(context)
        ? HelpButton(
            title:
                'Adjust amount: ${transaction.adjustment > 0 ? '+' : '-'} ${CalService.formatCurrency(context, transaction.adjustment, isAbs: true)} ${context.appSettings.currency.code}'
                    .hardcoded,
            text: 'This payment is adjusted to align with the actual credit balance'.hardcoded,
            iconPath: AppIcons.edit,
            size: size,
          )
        : Gap.noGap;
  }
}

class TxnCategoryIcon extends StatelessWidget {
  const TxnCategoryIcon({super.key, required this.transaction, this.color});

  final IBaseTransactionWithCategory transaction;
  final Color? color;

  String get _iconPath {
    if (transaction is Income && _isInitial(transaction)) {
      return AppIcons.add;
    }
    return transaction.category.iconPath;
  }

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      _iconPath,
      size: 20,
      color: color ?? context.appTheme.onBackground.withOpacity(_isInitial(transaction) ? 0.5 : 1),
    );
  }
}

class TxnCategoryName extends StatelessWidget {
  const TxnCategoryName({super.key, required this.transaction, this.fontSize});

  final IBaseTransactionWithCategory transaction;
  final double? fontSize;

  String get _name {
    if (transaction is Income && _isInitial(transaction)) {
      return 'Initial Balance';
    }
    return transaction.category.name;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name,
      style: kHeader2TextStyle.copyWith(
        fontSize: fontSize ?? 13,
        color: context.appTheme.onBackground,
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnCategoryTag extends StatelessWidget {
  const TxnCategoryTag({super.key, required this.transaction, this.fontSize});

  final BaseTransaction transaction;
  final double? fontSize;

  String? get _categoryTag {
    final txn = transaction;
    switch (txn) {
      case IBaseTransactionWithCategory():
        return (txn as IBaseTransactionWithCategory).categoryTag?.name;
      case Transfer() || CreditPayment() || CreditCheckpoint():
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _categoryTag != null
        ? Row(
            children: [
              Transform.translate(
                offset: const Offset(0, 1),
                child: SvgIcon(
                  AppIcons.arrowBendDown,
                  size: 15,
                  color: context.appTheme.onBackground,
                ),
              ),
              Text(
                _categoryTag!,
                style: kHeader3TextStyle.copyWith(
                  fontSize: fontSize ?? 12,
                  color: context.appTheme.onBackground,
                ),
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ],
          )
        : Gap.noGap;
  }
}

class TxnAccountIcon extends ConsumerWidget {
  const TxnAccountIcon({super.key, required this.transaction, this.useAccountIcon = false});

  final BaseTransaction transaction;
  final bool useAccountIcon;

  String _iconPath(WidgetRef ref) {
    if (useAccountIcon) {
      return transaction.account.iconPath;
    }

    if (transaction.account is DeletedAccount) {
      return AppIcons.defaultIcon;
    }

    return switch (transaction) {
      Income() => AppIcons.download,
      Expense() => AppIcons.upload,
      CreditPayment() => AppIcons.upload,
      CreditSpending() => AppIcons.credit,
      Transfer() || CreditCheckpoint() => throw StateError('No Icon'),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return transaction is Transfer || transaction is CreditCheckpoint
        ? Gap.noGap
        : Transform.translate(
            offset: const Offset(0, -1.5),
            child: SvgIcon(
              _iconPath(ref),
              size: 14,
              color: context.appTheme.onBackground.withOpacity(transaction.account is DeletedAccount ? 0.25 : 0.65),
            ),
          );
  }
}

class TxnAccountName extends ConsumerWidget {
  const TxnAccountName({super.key, required this.transaction, this.fontSize});

  final BaseTransaction transaction;
  final double? fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool deletedAccount = transaction.account is DeletedAccount;

    String name() {
      if (deletedAccount) {
        return 'Deleted account'.hardcoded;
      }
      if (transaction is CreditPayment) {
        return (transaction as CreditPayment).transferAccount.name;
      }

      return transaction.account.name;
    }

    return Text(
      name(),
      style: kHeader4TextStyle.copyWith(
        color: context.appTheme.onBackground.withOpacity(deletedAccount ? 0.25 : 0.65),
        fontSize: fontSize ?? 11,
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnToAccountName extends ConsumerWidget {
  const TxnToAccountName({super.key, required this.transaction});

  final ITransferable transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool deletedAccount = transaction.transferAccount is DeletedAccount;

    String name() {
      if (deletedAccount) {
        return 'Deleted account'.hardcoded;
      }
      if (transaction is CreditPayment) {
        return (transaction as CreditPayment).account.name;
      }

      return (transaction as Transfer).transferAccount.name;
    }

    return Text(
      name(),
      style: kHeader2TextStyle.copyWith(
          color: context.appTheme.onBackground.withOpacity(transaction.transferAccount is DeletedAccount ? 0.25 : 1),
          fontSize: 12),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnAmount extends StatelessWidget {
  const TxnAmount({super.key, required this.transaction, this.fontSize, this.color, this.showPaymentAmount = false})
      : assert(showPaymentAmount == true ? transaction is CreditSpending : true);

  final BaseTransaction transaction;
  final double? fontSize;
  final bool showPaymentAmount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MoneyAmount(
      amount: showPaymentAmount ? (transaction as CreditSpending).paymentAmount! : transaction.amount,
      noAnimation: true,
      style: kHeader3TextStyle.copyWith(
        color: color ?? _color(context, transaction),
        fontSize: fontSize ?? 13,
      ),
    );

    //
    // final List<Widget> children = [
    //   Text(
    //     CalService.formatCurrency(context,
    //         showPaymentAmount ? (transaction as CreditSpending).paymentAmount! : transaction.amount),
    //     softWrap: false,
    //     overflow: TextOverflow.fade,
    //     style: kHeader3TextStyle.copyWith(
    //         color: color ?? _color(context, transaction), fontSize: fontSize ?? 13),
    //   ),
    //   Gap.w2,
    //   Text(
    //     context.appSettings.currency.symbol,
    //     style: kNormalTextStyle.copyWith(
    //         color: color ?? _color(context, transaction), fontSize: fontSize ?? 12),
    //   ),
    // ];
    //
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.end,
    //   children: context.appSettings.currencyType == CurrencyType.symbolAfter
    //       ? children
    //       : children.reversed.toList(),
    // );
  }
}

class TxnNote extends StatelessWidget {
  const TxnNote({super.key, required this.transaction});

  final BaseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return transaction.note != null && transaction.note!.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(left: 15.5, top: 8),
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: context.appTheme.onBackground.withOpacity(0.3), width: 1)),
            ),
            child: EasyRichText(
              'Note: ${transaction.note!}',
              defaultStyle: kHeader4TextStyle.copyWith(
                color: context.appTheme.onBackground.withOpacity(0.65),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
              patternList: [
                EasyRichTextPattern(
                  targetString: 'Note:',
                  style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        : Gap.noGap;
  }
}

class TxnTransferLine extends StatelessWidget {
  const TxnTransferLine(
      {super.key, this.height = 27, this.width = 14, this.adjustY = 1, this.strokeWidth = 1, this.opacity = 0.65});

  final double height;
  final double adjustY;
  final double width;
  final double strokeWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRect(
        child: CustomPaint(
          painter: _TransferLinePainter(context, strokeWidth, opacity, height: height, width: width, adjustY: adjustY),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////

Color _color(BuildContext context, BaseTransaction transaction) {
  return switch (transaction) {
    Income() => context.appTheme.positive,
    Expense() => context.appTheme.negative,
    CreditSpending() => context.appTheme.onBackground,
    CreditPayment() => context.appTheme.negative,
    Transfer() => context.appTheme.onBackground,
    CreditCheckpoint() => AppColors.grey(context),
  };
}

bool _isInitial(IBaseTransactionWithCategory transaction) {
  if (transaction is Income && transaction.isInitialTransaction) {
    return true;
  }
  return false;
}

class _TransferLinePainter extends CustomPainter {
  _TransferLinePainter(this.context, this.strokeWidth, this.opacity,
      {this.height = 30, required this.width, required this.adjustY});

  final BuildContext context;
  final double height;
  final double width;
  final double adjustY;
  final double strokeWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    double arrowXOffset = 3;
    double arrowYOffset = 3;

    double cornerSize = 14;

    ///// DO NOT CHANGE ANYTHING UNDER THIS LINE /////

    double startX = 1;
    double startY = arrowYOffset + adjustY;
    double endX = width - 1;
    double endY = height - arrowYOffset - adjustY;

    Offset arrowHead = Offset(endX, endY);
    Offset upperTail = Offset(arrowHead.dx - arrowXOffset, arrowHead.dy - arrowYOffset);
    Offset lowerTail = Offset(arrowHead.dx - arrowXOffset, arrowHead.dy + arrowYOffset);

    Offset lineTopBegin = Offset(startX + cornerSize / 2, startY);
    Offset lineTopEnd = Offset(endX - 1, startY);
    Offset lineMiddleBegin = Offset(startX, startY + cornerSize / 2);
    Offset lineMiddleEnd = Offset(startX, endY - cornerSize / 2);
    Offset lineBottomBegin = Offset(startX + cornerSize / 2, endY);
    Offset lineBottomEnd = Offset(endX - 1, endY);

    final corner1 = Rect.fromLTWH(startX, startY, cornerSize, cornerSize);
    final corner2 = Rect.fromLTWH(startX, endY - cornerSize, cornerSize, cornerSize);
    const startAngle1 = math.pi;
    const startAngle2 = math.pi / 2;
    const sweepAngle = math.pi / 2;
    const useCenter = false;

    final paint = Paint()
      ..color = context.appTheme.onBackground.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(corner1, startAngle1, sweepAngle, useCenter, paint);
    canvas.drawArc(corner2, startAngle2, sweepAngle, useCenter, paint);

    canvas.drawLine(lineTopBegin, lineTopEnd, paint);
    canvas.drawLine(lineMiddleBegin, lineMiddleEnd, paint);
    canvas.drawLine(lineBottomBegin, lineBottomEnd, paint);

    canvas.drawLine(arrowHead, upperTail, paint);
    canvas.drawLine(arrowHead, lowerTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
