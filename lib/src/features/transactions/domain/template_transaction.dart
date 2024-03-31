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
    this.dateTime,
    this.amount,
    this.note,
    this.account,
    this.toAccount,
    this.category,
    this.categoryTag,
  );

  static TemplateTransaction fromDatabase(TemplateTransactionDb templateTransactionDb) {
    return TemplateTransaction._(
      templateTransactionDb,
      TransactionType.fromDatabaseValue(templateTransactionDb.type),
      templateTransactionDb.dateTime?.toLocal(),
      templateTransactionDb.amount,
      templateTransactionDb.note,
      Account.fromDatabaseInfoOnly(templateTransactionDb.account),
      Account.fromDatabaseInfoOnly(templateTransactionDb.transferAccount),
      Category.fromDatabase(templateTransactionDb.category),
      CategoryTag.fromDatabase(templateTransactionDb.categoryTag),
    );
  }
}
