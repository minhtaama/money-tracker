import 'package:money_tracker_app/src/features/category/domain/income_category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class Transaction {
  final double amount;
  final TransactionType transactionType;
  final IncomeCategory category;
  final IncomeCategory? transferToCategory;
  final String? note;
  final DateTime dateTime;

  Transaction(
    this.amount,
    this.transactionType, {
    required this.dateTime,
    required this.category,
    this.transferToCategory,
    this.note,
  });
}
