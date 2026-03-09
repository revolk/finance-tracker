import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

const _boxName = 'transactions';
const _uuid = Uuid();

final hiveBoxProvider = Provider<Box<Transaction>>((ref) {
  return Hive.box<Transaction>(_boxName);
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final Box<Transaction> _box;

  TransactionsNotifier(this._box) : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final tx = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    await _box.put(tx.id, tx);
    _load();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _load();
  }

  Future<void> update(Transaction updated) async {
    await _box.put(updated.id, updated);
    _load();
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref.watch(hiveBoxProvider));
});

final totalIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

final monthlyDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final txs = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - (5 - i));
    final monthTxs = txs.where((t) =>
        t.date.year == month.year && t.date.month == month.month);
    final income  = monthTxs.where((t) => t.type == TransactionType.income) .fold(0.0, (s, t) => s + t.amount);
    final expense = monthTxs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
    return {'month': month, 'income': income, 'expense': expense};
  });
});

final categoryBreakdownProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final txs = ref.watch(transactionsProvider)
      .where((t) => t.type == TransactionType.expense);
  final Map<String, double> map = {};
  for (final t in txs) {
    map[t.category] = (map[t.category] ?? 0) + t.amount;
  }
  return map.entries
      .map((e) => {'category': e.key, 'amount': e.value})
      .toList()
    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
});

final themeProvider = StateProvider<bool>((ref) => true);