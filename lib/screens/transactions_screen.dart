import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionType? _filter;

  @override
  Widget build(BuildContext context, ) {
    final all = ref.watch(transactionsProvider);
    final filtered = _filter == null
        ? all
        : all.where((t) => t.type == _filter).toList();

    final Map<String, List<Transaction>> grouped = {};
    for (final tx in filtered) {
      final key = DateFormat('d MMMM yyyy').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(children: [
              _FilterChip(
                label: 'All',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: '💸 Expense',
                selected: _filter == TransactionType.expense,
                onTap: () => setState(() =>
                    _filter = _filter == TransactionType.expense
                        ? null
                        : TransactionType.expense),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: '💰 Income',
                selected: _filter == TransactionType.income,
                onTap: () => setState(() =>
                    _filter = _filter == TransactionType.income
                        ? null
                        : TransactionType.income),
              ),
            ]),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? const EmptyState(message: 'No transactions found')
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...grouped.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        ),
                        ...entry.value.map((tx) => TransactionTile(
                              tx: tx,
                              onDelete: () => ref
                                  .read(transactionsProvider.notifier)
                                  .delete(tx.id),
                            )),
                      ],
                    )),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(.3),
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey)),
      ),
    );
  }
}