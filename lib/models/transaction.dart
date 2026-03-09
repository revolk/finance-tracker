import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });
}

class AppCategories {
  static const List<Map<String, dynamic>> expense = [
    {'name': 'Food',        'emoji': '🍔', 'color': 0xFFFF6B6B},
    {'name': 'Transport',   'emoji': '🚗', 'color': 0xFF4ECDC4},
    {'name': 'Shopping',    'emoji': '🛍️', 'color': 0xFFFFE66D},
    {'name': 'Bills',       'emoji': '💡', 'color': 0xFF95E1D3},
    {'name': 'Health',      'emoji': '💊', 'color': 0xFFF38181},
    {'name': 'Education',   'emoji': '📚', 'color': 0xFF6C63FF},
    {'name': 'Gaming',      'emoji': '🎮', 'color': 0xFF2ECC71},
    {'name': 'Other',       'emoji': '📦', 'color': 0xFFBDBDBD},
  ];

  static const List<Map<String, dynamic>> income = [
    {'name': 'Salary',      'emoji': '💼', 'color': 0xFF2ECC71},
    {'name': 'Freelance',   'emoji': '💻', 'color': 0xFF3498DB},
    {'name': 'Investment',  'emoji': '📈', 'color': 0xFFE67E22},
    {'name': 'Gift',        'emoji': '🎁', 'color': 0xFF9B59B6},
    {'name': 'Other',       'emoji': '💰', 'color': 0xFFBDBDBD},
  ];

  static Map<String, dynamic> find(String name) {
    final all = [...expense, ...income];
    return all.firstWhere(
      (c) => c['name'] == name,
      orElse: () => {'name': name, 'emoji': '📦', 'color': 0xFFBDBDBD},
    );
  }
}