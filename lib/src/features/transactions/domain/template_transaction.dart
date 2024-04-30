import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';

import '../../../../persistent/base_model.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';

@immutable
class TemplateTransaction extends BaseModel<TemplateTransactionDb> {
  final TransactionType type;

  final DateTime? dateTime;

  final double? amount;

  final String? note;

  final AccountInfo? account;

  final AccountInfo? toAccount;

  final Category? category;

  final CategoryTag? categoryTag;

  const TemplateTransaction._(
    super._databaseObject,
    this.type,
    this.amount,
    this.note,
    this.account,
    this.toAccount,
    this.category,
    this.categoryTag, {
    this.dateTime,
  });

  static TemplateTransaction fromDatabase(TemplateTransactionDb templateTransactionDb) {
    return TemplateTransaction._(
      templateTransactionDb,
      TransactionType.fromDatabaseValue(templateTransactionDb.type),
      templateTransactionDb.amount,
      templateTransactionDb.note,
      Account.fromDatabaseInfoOnly(templateTransactionDb.account),
      Account.fromDatabaseInfoOnly(templateTransactionDb.transferAccount),
      Category.fromDatabase(templateTransactionDb.category),
      CategoryTag.fromDatabase(templateTransactionDb.categoryTag),
      dateTime: templateTransactionDb.dateTime?.toLocal(),
    );
  }

  TemplateTransaction withDateTime(DateTime dateTime) {
    return TemplateTransaction._(
      databaseObject,
      type,
      amount,
      note,
      account,
      toAccount,
      category,
      categoryTag,
      dateTime: dateTime,
    );
  }
}
