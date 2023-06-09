import 'package:money_tracker_app/src/features/category/model/income_category.dart';
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

  Transaction copyWith(
    double? amount,
    TransactionType? transactionType, {
    IncomeCategory? category,
    IncomeCategory? transferToCategory,
    String? note,
    DateTime? dateTime,
  }) {
    return Transaction(
      amount ?? this.amount,
      transactionType ?? this.transactionType,
      category: category ?? this.category,
      transferToCategory: transferToCategory ?? this.transferToCategory,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          transactionType == other.transactionType &&
          category == other.category &&
          transferToCategory == other.transferToCategory &&
          note == other.note &&
          dateTime == other.dateTime;

  @override
  int get hashCode =>
      amount.hashCode ^
      transactionType.hashCode ^
      category.hashCode ^
      transferToCategory.hashCode ^
      note.hashCode ^
      dateTime.hashCode;

  @override
  String toString() {
    return 'Transaction{amount: $amount, transactionType: $transactionType, category: $category, transferToCategory: $transferToCategory, note: $note, dateTime: $dateTime}';
  }
}
